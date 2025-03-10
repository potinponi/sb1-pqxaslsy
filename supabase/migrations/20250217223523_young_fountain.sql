/*
  # Storage Configuration

  1. Storage
    - Configure widgets bucket
    - Set up storage policies
*/

-- Storage configuration
DO $$ 
BEGIN
  -- Create widgets bucket if it doesn't exist
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'widgets',
    'widgets',
    true,
    1048576, -- 1MB
    ARRAY[
      'application/javascript',
      'text/javascript',
      'application/x-javascript',
      'text/css'
    ]::text[]
  )
  ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 1048576,
    allowed_mime_types = ARRAY[
      'application/javascript',
      'text/javascript',
      'application/x-javascript',
      'text/css'
    ]::text[];

  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Allow authenticated users to upload widgets" ON storage.objects;
  DROP POLICY IF EXISTS "Allow authenticated users to update widgets" ON storage.objects;
  DROP POLICY IF EXISTS "Allow authenticated users to read widgets" ON storage.objects;
  DROP POLICY IF EXISTS "Allow public to read widgets" ON storage.objects;
  DROP POLICY IF EXISTS "Allow authenticated users to delete widgets" ON storage.objects;

  -- Create storage policies
  CREATE POLICY "widgets_upload_policy" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'widgets' AND
      (storage.foldername(name))[1] IS NULL
    );

  CREATE POLICY "widgets_update_policy" ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'widgets')
    WITH CHECK (bucket_id = 'widgets');

  CREATE POLICY "widgets_read_auth_policy" ON storage.objects
    FOR SELECT TO authenticated
    USING (bucket_id = 'widgets');

  CREATE POLICY "widgets_read_public_policy" ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'widgets');

  CREATE POLICY "widgets_delete_policy" ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'widgets');
END $$;