-- =============================================================================
-- Self-Finance Cloud Sync Schema with Row Level Security (RLS)
-- =============================================================================

-- Enable uuid extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Trigger function to automatically update `updated_at` on row updates
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 1. CUSTOMERS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    guardian_name TEXT NOT NULL DEFAULT '',
    address TEXT NOT NULL DEFAULT '',
    contact_number TEXT NOT NULL,
    photo_path TEXT NOT NULL DEFAULT '',
    proof_path TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access their own customers"
    ON public.customers FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_customers_owner ON public.customers(owner_id);
CREATE INDEX IF NOT EXISTS idx_customers_updated ON public.customers(updated_at);

-- -----------------------------------------------------------------------------
-- 2. ITEMS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_sync_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    pawned_date TIMESTAMPTZ NOT NULL,
    expiry_date TIMESTAMPTZ NOT NULL,
    pawn_amount NUMERIC(15, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'Active',
    photo_path TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access their own items"
    ON public.items FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER trg_items_updated_at
    BEFORE UPDATE ON public.items
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_items_owner ON public.items(owner_id);
CREATE INDEX IF NOT EXISTS idx_items_customer ON public.items(customer_sync_id);
CREATE INDEX IF NOT EXISTS idx_items_updated ON public.items(updated_at);

-- -----------------------------------------------------------------------------
-- 3. TRANSACTIONS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_sync_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    item_sync_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    transaction_date TIMESTAMPTZ NOT NULL,
    transaction_type TEXT NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    interest_rate NUMERIC(8, 2) NOT NULL,
    interest_amount NUMERIC(15, 2) NOT NULL,
    remaining_amount NUMERIC(15, 2) NOT NULL,
    signature_path TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access their own transactions"
    ON public.transactions FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER trg_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_transactions_owner ON public.transactions(owner_id);
CREATE INDEX IF NOT EXISTS idx_transactions_customer ON public.transactions(customer_sync_id);
CREATE INDEX IF NOT EXISTS idx_transactions_item ON public.transactions(item_sync_id);
CREATE INDEX IF NOT EXISTS idx_transactions_updated ON public.transactions(updated_at);

-- -----------------------------------------------------------------------------
-- 4. PAYMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transaction_sync_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    payment_date TIMESTAMPTZ NOT NULL,
    amount_paid NUMERIC(15, 2) NOT NULL,
    payment_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access their own payments"
    ON public.payments FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_payments_owner ON public.payments(owner_id);
CREATE INDEX IF NOT EXISTS idx_payments_transaction ON public.payments(transaction_sync_id);
CREATE INDEX IF NOT EXISTS idx_payments_updated ON public.payments(updated_at);

-- -----------------------------------------------------------------------------
-- 5. HISTORY
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_sync_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    contact_number TEXT NOT NULL,
    item_sync_id UUID,
    transaction_sync_id UUID,
    amount NUMERIC(15, 2) NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    event_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can access their own history"
    ON public.history FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER trg_history_updated_at
    BEFORE UPDATE ON public.history
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_history_owner ON public.history(owner_id);
CREATE INDEX IF NOT EXISTS idx_history_customer ON public.history(customer_sync_id);
CREATE INDEX IF NOT EXISTS idx_history_updated ON public.history(updated_at);
