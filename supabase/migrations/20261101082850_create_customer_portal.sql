-- =============================================================================
-- Customer Portal Backend Schema & Secure RPCs
-- =============================================================================

-- 1. Create table for customer portal authentication sessions
CREATE TABLE IF NOT EXISTS public.customer_portal_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number TEXT NOT NULL,
    otp_hash TEXT NOT NULL,
    portal_token UUID DEFAULT gen_random_uuid(),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'EXPIRED')),
    attempts INT NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (timezone('utc'::text, now()) + interval '5 minutes'),
    token_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.customer_portal_sessions ENABLE ROW LEVEL SECURITY;

-- Block direct table access from client queries; access strictly through SECURITY DEFINER RPCs
DROP POLICY IF EXISTS "Block direct portal sessions access" ON public.customer_portal_sessions;
CREATE POLICY "Block direct portal sessions access"
    ON public.customer_portal_sessions FOR ALL
    USING (false);

CREATE INDEX IF NOT EXISTS idx_customer_portal_sessions_phone 
    ON public.customer_portal_sessions(phone_number);
CREATE INDEX IF NOT EXISTS idx_customer_portal_sessions_token 
    ON public.customer_portal_sessions(portal_token);

-- Updated_at trigger
DROP TRIGGER IF EXISTS trg_customer_portal_sessions_updated_at ON public.customer_portal_sessions;
CREATE TRIGGER trg_customer_portal_sessions_updated_at
    BEFORE UPDATE ON public.customer_portal_sessions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- -----------------------------------------------------------------------------
-- 2. RPC: REQUEST CUSTOMER PORTAL OTP
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.customer_portal_request_otp(
    p_phone_number TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_clean_phone TEXT;
    v_customer_id UUID;
    v_customer_name TEXT;
    v_otp TEXT;
    v_otp_hash TEXT;
    v_session_id UUID;
    v_expires_at TIMESTAMPTZ;
BEGIN
    IF p_phone_number IS NULL OR trim(p_phone_number) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'INVALID_PHONE',
            'message', 'Please enter a valid phone number.'
        );
    END IF;

    -- Strip whitespace
    v_clean_phone := regexp_replace(p_phone_number, '\s+', '', 'g');

    -- Verify that a customer exists with this contact number
    SELECT id, name INTO v_customer_id, v_customer_name
    FROM public.customers
    WHERE regexp_replace(contact_number, '\s+', '', 'g') = v_clean_phone
      AND deleted_at IS NULL
    ORDER BY created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'CUSTOMER_NOT_FOUND',
            'message', 'No customer record found with this phone number. Please contact your lender.'
        );
    END IF;

    -- Generate 4-digit OTP code (1000 - 9999)
    v_otp := (1000 + floor(random() * 9000))::int::text;

    -- Compute SHA-256 hash salted with phone number
    v_otp_hash := encode(digest((v_otp || v_clean_phone)::bytea, 'sha256'), 'hex');
    v_expires_at := timezone('utc'::text, now()) + interval '5 minutes';

    -- Insert session
    INSERT INTO public.customer_portal_sessions (
        phone_number,
        otp_hash,
        expires_at
    ) VALUES (
        v_clean_phone,
        v_otp_hash,
        v_expires_at
    ) RETURNING id INTO v_session_id;

    RETURN jsonb_build_object(
        'success', true,
        'session_id', v_session_id,
        'customer_name', v_customer_name,
        'otp_code', v_otp,
        'expires_at', v_expires_at
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- 3. RPC: VERIFY CUSTOMER PORTAL OTP
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.customer_portal_verify_otp(
    p_session_id UUID,
    p_entered_otp TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_session RECORD;
    v_computed_hash TEXT;
    v_token UUID;
    v_token_expiry TIMESTAMPTZ;
BEGIN
    -- Serialize concurrent verification requests using row lock
    SELECT * INTO v_session
    FROM public.customer_portal_sessions
    WHERE id = p_session_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'SESSION_NOT_FOUND',
            'message', 'Verification session expired or not found.'
        );
    END IF;

    IF v_session.status = 'EXPIRED' OR timezone('utc'::text, now()) > v_session.expires_at THEN
        UPDATE public.customer_portal_sessions
        SET status = 'EXPIRED'
        WHERE id = p_session_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'EXPIRED',
            'message', 'OTP has expired. Please request a new code.'
        );
    END IF;

    IF v_session.attempts >= 5 THEN
        UPDATE public.customer_portal_sessions
        SET status = 'EXPIRED'
        WHERE id = p_session_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'MAX_ATTEMPTS',
            'message', 'Too many incorrect attempts. Please request a new code.'
        );
    END IF;

    -- Compute hash of entered OTP
    v_computed_hash := encode(digest((trim(p_entered_otp) || v_session.phone_number)::bytea, 'sha256'), 'hex');

    IF v_computed_hash = v_session.otp_hash THEN
        v_token := gen_random_uuid();
        v_token_expiry := timezone('utc'::text, now()) + interval '30 days';

        UPDATE public.customer_portal_sessions
        SET status = 'VERIFIED',
            portal_token = v_token,
            token_expires_at = v_token_expiry
        WHERE id = p_session_id;

        RETURN jsonb_build_object(
            'success', true,
            'portal_token', v_token,
            'phone_number', v_session.phone_number,
            'expires_at', v_token_expiry
        );
    ELSE
        UPDATE public.customer_portal_sessions
        SET attempts = attempts + 1
        WHERE id = p_session_id;

        RETURN jsonb_build_object(
            'success', false,
            'error', 'INVALID_OTP',
            'remaining_attempts', 5 - (v_session.attempts + 1),
            'message', 'Invalid OTP code. Please try again.'
        );
    END IF;
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. RPC: GET CUSTOMER PORTAL DATA (Secure Read-Only Access)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.customer_portal_get_data(
    p_portal_token UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
    v_phone TEXT;
    v_customer_info JSONB;
    v_summary JSONB;
    v_loans JSONB;
    v_payments JSONB;
BEGIN
    -- Verify portal token validity and expiry
    SELECT phone_number INTO v_phone
    FROM public.customer_portal_sessions
    WHERE portal_token = p_portal_token
      AND status = 'VERIFIED'
      AND timezone('utc'::text, now()) <= token_expires_at;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'UNAUTHORIZED',
            'message', 'Session expired or invalid. Please sign in again.'
        );
    END IF;

    -- 1. Fetch primary customer profile
    SELECT jsonb_build_object(
        'name', name,
        'guardian_name', guardian_name,
        'contact_number', contact_number,
        'address', address,
        'photo_path', photo_path,
        'proof_path', proof_path,
        'created_at', created_at
    ) INTO v_customer_info
    FROM public.customers
    WHERE regexp_replace(contact_number, '\s+', '', 'g') = v_phone
      AND deleted_at IS NULL
    ORDER BY created_at DESC
    LIMIT 1;

    -- 2. Fetch all loans & associated collateral items for this customer
    SELECT COALESCE(jsonb_agg(loan_row), '[]'::jsonb) INTO v_loans
    FROM (
        SELECT 
            t.id AS transaction_id,
            t.amount,
            t.interest_rate,
            t.interest_amount,
            t.remaining_amount,
            t.transaction_date,
            t.transaction_type,
            t.signature_path,
            t.created_at,
            i.id AS item_id,
            i.name AS item_name,
            i.description AS item_description,
            i.pawn_amount,
            i.status AS item_status,
            i.pawned_date,
            i.expiry_date,
            i.photo_path AS item_photo_path
        FROM public.transactions t
        JOIN public.customers c ON t.customer_sync_id = c.id
        LEFT JOIN public.items i ON t.item_sync_id = i.id
        WHERE regexp_replace(c.contact_number, '\s+', '', 'g') = v_phone
          AND t.deleted_at IS NULL
        ORDER BY t.transaction_date DESC
    ) loan_row;

    -- 3. Fetch all payments across these loans
    SELECT COALESCE(jsonb_agg(payment_row), '[]'::jsonb) INTO v_payments
    FROM (
        SELECT 
            p.id AS payment_id,
            p.transaction_sync_id AS transaction_id,
            p.amount_paid,
            p.payment_type,
            p.payment_date,
            p.created_at
        FROM public.payments p
        JOIN public.transactions t ON p.transaction_sync_id = t.id
        JOIN public.customers c ON t.customer_sync_id = c.id
        WHERE regexp_replace(c.contact_number, '\s+', '', 'g') = v_phone
          AND p.deleted_at IS NULL
        ORDER BY p.payment_date DESC
    ) payment_row;

    -- 4. Compute financial summary stats
    SELECT jsonb_build_object(
        'total_loans', COUNT(t.id),
        'total_borrowed', COALESCE(SUM(t.amount), 0),
        'total_remaining', COALESCE(SUM(t.remaining_amount), 0),
        'total_paid', (
            SELECT COALESCE(SUM(p.amount_paid), 0)
            FROM public.payments p
            JOIN public.transactions t2 ON p.transaction_sync_id = t2.id
            JOIN public.customers c2 ON t2.customer_sync_id = c2.id
            WHERE regexp_replace(c2.contact_number, '\s+', '', 'g') = v_phone
              AND p.deleted_at IS NULL
        )
    ) INTO v_summary
    FROM public.transactions t
    JOIN public.customers c ON t.customer_sync_id = c.id
    WHERE regexp_replace(c.contact_number, '\s+', '', 'g') = v_phone
      AND t.deleted_at IS NULL;

    RETURN jsonb_build_object(
        'success', true,
        'customer', v_customer_info,
        'summary', v_summary,
        'loans', v_loans,
        'payments', v_payments
    );
END;
$$;

-- -----------------------------------------------------------------------------
-- 5. PERMISSIONS
-- -----------------------------------------------------------------------------
-- Allow unauthenticated callers to execute customer portal RPCs
GRANT EXECUTE ON FUNCTION public.customer_portal_request_otp(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_portal_verify_otp(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_portal_get_data(UUID) TO anon, authenticated;
