-- =============================================================================
-- Self-Finance Supabase Storage: finance-files bucket and RLS policies
-- =============================================================================

-- 1. Create private bucket if it doesn't already exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'finance-files',
    'finance-files',
    false,
    10485760, -- 10MB limit per file
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = false,
    file_size_limit = 10485760;

-- Note: RLS is already enabled by default on storage.objects in Supabase.

-- 2. Policy: Authenticated users can view their own files
-- Path format: <owner_id>/customers/<customer_uuid>/photo.jpg
DROP POLICY IF EXISTS "Users can view their own finance files" ON storage.objects;
CREATE POLICY "Users can view their own finance files"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'finance-files'
        AND (storage.foldername(name))[1] = (select auth.uid())::text
    );

-- 3. Policy: Authenticated users can upload their own files
DROP POLICY IF EXISTS "Users can upload their own finance files" ON storage.objects;
CREATE POLICY "Users can upload their own finance files"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'finance-files'
        AND (storage.foldername(name))[1] = (select auth.uid())::text
    );

-- 4. Policy: Authenticated users can update their own files
DROP POLICY IF EXISTS "Users can update their own finance files" ON storage.objects;
CREATE POLICY "Users can update their own finance files"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'finance-files'
        AND (storage.foldername(name))[1] = (select auth.uid())::text
    )
    WITH CHECK (
        bucket_id = 'finance-files'
        AND (storage.foldername(name))[1] = (select auth.uid())::text
    );

-- 5. Policy: Authenticated users can delete their own files
DROP POLICY IF EXISTS "Users can delete their own finance files" ON storage.objects;
CREATE POLICY "Users can delete their own finance files"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'finance-files'
        AND (storage.foldername(name))[1] = (select auth.uid())::text
    );
