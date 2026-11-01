-- =============================================================================
-- Production Backend Hardening: Data Integrity, Row Locking & Token Enforcement
-- =============================================================================

-- 1. Ensure verification_token has a UNIQUE constraint
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'uq_loan_verifications_token'
    ) THEN
        ALTER TABLE public.loan_verifications 
        ADD CONSTRAINT uq_loan_verifications_token UNIQUE (verification_token);
    END IF;
END $$;

-- 2. Add Index on transactions(verification_token)
CREATE INDEX IF NOT EXISTS idx_transactions_verification_token 
    ON public.transactions(verification_token);

-- 3. Hardened request_loan_otp with parameter validation
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

    -- Parameter validation
    IF p_customer_number IS NULL OR trim(p_customer_number) = '' THEN
        RAISE EXCEPTION 'Customer phone number is required.';
    END IF;

    IF p_loan_amount IS NULL OR p_loan_amount <= 0 THEN
        RAISE EXCEPTION 'Loan amount must be greater than zero.';
    END IF;

    -- Strip all internal whitespace from phone number for deterministic salt
    v_clean_number := regexp_replace(p_customer_number, '\s+', '', 'g');

    -- Generate a 4-digit code (1000 - 9999)
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
        COALESCE(p_customer_name, ''),
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

-- 4. Hardened verify_loan_otp with FOR UPDATE row lock to prevent race conditions
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

    -- Serialize concurrent verification requests using row lock
    SELECT * INTO v_record
    FROM public.loan_verifications
    WHERE id = p_verification_id AND owner_id = v_user_id
    FOR UPDATE;

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

-- 5. Trigger: Automatically enforce and consume verification_token on transactions
CREATE OR REPLACE FUNCTION public.trg_enforce_transaction_verification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_ver RECORD;
BEGIN
    IF NEW.verification_token IS NOT NULL THEN
        -- Allow re-upsert of the same transaction with the same token
        IF TG_OP = 'UPDATE' AND OLD.verification_token = NEW.verification_token THEN
            RETURN NEW;
        END IF;

        SELECT id, status, owner_id INTO v_ver
        FROM public.loan_verifications
        WHERE verification_token = NEW.verification_token
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Verification token % does not exist.', NEW.verification_token;
        END IF;

        IF v_ver.owner_id != NEW.owner_id THEN
            RAISE EXCEPTION 'Verification token does not belong to this user.';
        END IF;

        IF v_ver.status = 'CONSUMED' THEN
            -- Check if another transaction already used this token
            IF EXISTS (
                SELECT 1 FROM public.transactions 
                WHERE verification_token = NEW.verification_token 
                  AND id != NEW.id
            ) THEN
                RAISE EXCEPTION 'Verification token % has already been consumed by another transaction.', NEW.verification_token;
            END IF;
        ELSIF v_ver.status = 'VERIFIED' THEN
            -- Mark as consumed immediately upon linking to this transaction
            UPDATE public.loan_verifications
            SET status = 'CONSUMED',
                consumed_at = timezone('utc'::text, now())
            WHERE id = v_ver.id;
        ELSE
            RAISE EXCEPTION 'Verification token % is not in VERIFIED status (status: %).', NEW.verification_token, v_ver.status;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_transactions_verify_token ON public.transactions;
CREATE TRIGGER trg_transactions_verify_token
    BEFORE INSERT OR UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION public.trg_enforce_transaction_verification();
