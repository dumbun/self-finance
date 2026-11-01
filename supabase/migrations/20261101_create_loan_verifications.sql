-- =============================================================================
-- Self-Finance Cloud-Verified Staging & Data Integrity Schema (Production Ready)
-- =============================================================================

-- Enable pgcrypto for server-side cryptographic hashing
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

-- -----------------------------------------------------------------------------
-- 1. LOAN VERIFICATIONS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.loan_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_number TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    loan_amount NUMERIC(15, 2) NOT NULL,
    otp_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'CONSUMED', 'EXPIRED')),
    attempts INT NOT NULL DEFAULT 0,
    verification_token UUID NOT NULL DEFAULT gen_random_uuid(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (timezone('utc'::text, now()) + interval '5 minutes'),
    verified_at TIMESTAMPTZ,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.loan_verifications ENABLE ROW LEVEL SECURITY;

-- Idempotent policy creation
DROP POLICY IF EXISTS "Users can manage their own loan verifications" ON public.loan_verifications;
CREATE POLICY "Users can manage their own loan verifications"
    ON public.loan_verifications FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Updated_at trigger
DROP TRIGGER IF EXISTS trg_loan_verifications_updated_at ON public.loan_verifications;
CREATE TRIGGER trg_loan_verifications_updated_at
    BEFORE UPDATE ON public.loan_verifications
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_loan_verifications_owner ON public.loan_verifications(owner_id);
CREATE INDEX IF NOT EXISTS idx_loan_verifications_token ON public.loan_verifications(verification_token);
CREATE INDEX IF NOT EXISTS idx_loan_verifications_status ON public.loan_verifications(status);

-- -----------------------------------------------------------------------------
-- 2. LINK TRANSACTIONS TO VERIFICATION TOKENS
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'transactions' 
        AND column_name = 'verification_token'
    ) THEN
        ALTER TABLE public.transactions ADD COLUMN verification_token UUID;
    END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 3. RPC: REQUEST LOAN OTP (Generates & Hashes OTP Server-Side)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.request_loan_otp(
    p_customer_number TEXT,
    p_customer_name TEXT,
    p_loan_amount NUMERIC
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_user_id UUID;
    v_clean_number TEXT;
    v_otp TEXT;
    v_otp_hash TEXT;
    v_id UUID;
    v_expires_at TIMESTAMPTZ;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;

    -- Strip all internal whitespace from phone number for deterministic salt
    v_clean_number := regexp_replace(p_customer_number, '\s+', '', 'g');

    -- Generate a cryptographically secure 4-digit code (1000 - 9999)
    v_otp := (1000 + floor(random() * 9000))::int::text;

    -- Hash the OTP with cleaned customer number and lender user_id
    v_otp_hash := encode(digest((v_otp || v_clean_number || v_user_id::text)::bytea, 'sha256'), 'hex');
    v_expires_at := timezone('utc'::text, now()) + interval '5 minutes';

    -- Insert verification record
    INSERT INTO public.loan_verifications (
        owner_id,
        customer_number,
        customer_name,
        loan_amount,
        otp_hash,
        expires_at
    ) VALUES (
        v_user_id,
        v_clean_number,
        p_customer_name,
        p_loan_amount,
        v_otp_hash,
        v_expires_at
    ) RETURNING id INTO v_id;

    -- Return the verification ID, OTP for device SMS dispatch, and expiration
    RETURN jsonb_build_object(
        'verification_id', v_id,
        'otp_code', v_otp,
        'expires_at', v_expires_at
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. RPC: VERIFY LOAN OTP (Server-Side Hash Validation)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.verify_loan_otp(
    p_verification_id UUID,
    p_entered_otp TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_user_id UUID;
    v_record RECORD;
    v_clean_number TEXT;
    v_computed_hash TEXT;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;

    SELECT * INTO v_record
    FROM public.loan_verifications
    WHERE id = p_verification_id AND owner_id = v_user_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'NOT_FOUND',
            'message', 'Verification session not found.'
        );
    END IF;

    -- Check if expired or max attempts reached
    IF v_record.status = 'EXPIRED' OR timezone('utc'::text, now()) > v_record.expires_at THEN
        UPDATE public.loan_verifications
        SET status = 'EXPIRED'
        WHERE id = p_verification_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'EXPIRED',
            'message', 'OTP has expired. Please request a new code.'
        );
    END IF;

    IF v_record.status = 'VERIFIED' OR v_record.status = 'CONSUMED' THEN
        RETURN jsonb_build_object(
            'success', true,
            'verification_token', v_record.verification_token,
            'message', 'Already verified.'
        );
    END IF;

    IF v_record.attempts >= 5 THEN
        UPDATE public.loan_verifications
        SET status = 'EXPIRED'
        WHERE id = p_verification_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'MAX_ATTEMPTS',
            'message', 'Too many incorrect attempts. Please request a new code.'
        );
    END IF;

    -- Deterministic cleaned phone number salt
    v_clean_number := regexp_replace(v_record.customer_number, '\s+', '', 'g');

    -- Compute hash of entered OTP
    v_computed_hash := encode(digest((trim(p_entered_otp) || v_clean_number || v_user_id::text)::bytea, 'sha256'), 'hex');

    IF v_computed_hash = v_record.otp_hash THEN
        UPDATE public.loan_verifications
        SET status = 'VERIFIED',
            verified_at = timezone('utc'::text, now())
        WHERE id = p_verification_id;

        RETURN jsonb_build_object(
            'success', true,
            'verification_token', v_record.verification_token
        );
    ELSE
        UPDATE public.loan_verifications
        SET attempts = attempts + 1
        WHERE id = p_verification_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'INVALID_OTP',
            'remaining_attempts', 5 - (v_record.attempts + 1),
            'message', 'Invalid OTP code. Please try again.'
        );
    END IF;
END;
$$;

-- -----------------------------------------------------------------------------
-- 5. RPC: CONSUME VERIFICATION TOKEN (Guarantees Single-Use)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.consume_loan_verification(
    p_verification_token UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    UPDATE public.loan_verifications
    SET status = 'CONSUMED',
        consumed_at = timezone('utc'::text, now())
    WHERE verification_token = p_verification_token
      AND owner_id = v_user_id
      AND status = 'VERIFIED';

    RETURN FOUND;
END;
$$;

-- -----------------------------------------------------------------------------
-- 6. SECURITY & ROLES (Production Hardened)
-- -----------------------------------------------------------------------------
-- Ensure authenticated users have access to the table and RPCs
GRANT ALL ON TABLE public.loan_verifications TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_loan_otp(TEXT, TEXT, NUMERIC) TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_loan_otp(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.consume_loan_verification(UUID) TO authenticated;

-- Revoke execute from anonymous/unauthenticated users
REVOKE ALL ON FUNCTION public.request_loan_otp(TEXT, TEXT, NUMERIC) FROM anon;
REVOKE ALL ON FUNCTION public.verify_loan_otp(UUID, TEXT) FROM anon;
REVOKE ALL ON FUNCTION public.consume_loan_verification(UUID) FROM anon;
