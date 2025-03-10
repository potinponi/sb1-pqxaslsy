/*
  # Add logo storage bucket

  1. New Storage Bucket
    - Create 'logos' bucket for storing custom logos
    - Set file size limit to 1MB
    - Allow only image formats
  
  2. Security
    - Enable public read access
    - Restrict uploads to authenticated users
*/

-- Create logos bucket if it doesn't exist
DO $$ 
BEGIN
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'logos',
    'logos',
    true,
    1048576, -- 1MB
    ARRAY[
      'image/jpeg',
      'image/png',
      'image/webp'
    ]::text[]
  )
  ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 1048576,
    allowed_mime_types = ARRAY[
      'image/jpeg',
      'image/png',
      'image/webp'
    ]::text[];

  -- Create storage policies
  CREATE POLICY "Allow authenticated users to upload logos" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'logos' AND
      (storage.foldername(name))[1] IS NULL
    );

  CREATE POLICY "Allow public to read logos" ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'logos');

  CREATE POLICY "Allow authenticated users to delete logos" ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'logos');
END $$;