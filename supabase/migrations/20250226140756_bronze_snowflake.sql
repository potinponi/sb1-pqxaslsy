-- Create chatbot-icons bucket if it doesn't exist
DO $$ 
BEGIN
  -- Create bucket
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'chatbot-icons',
    'chatbot-icons',
    true,
    1048576, -- 1MB
    ARRAY[
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp'
    ]::text[]
  )
  ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 1048576,
    allowed_mime_types = ARRAY[
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp'
    ]::text[];

  -- Create storage policies
  CREATE POLICY "Allow authenticated users to upload icons" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
      bucket_id = 'chatbot-icons' AND
      (storage.foldername(name))[1] IS NULL
    );

  CREATE POLICY "Allow authenticated users to update icons" ON storage.objects
    FOR UPDATE TO authenticated
    USING (bucket_id = 'chatbot-icons')
    WITH CHECK (bucket_id = 'chatbot-icons');

  CREATE POLICY "Allow public to read icons" ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'chatbot-icons');

  CREATE POLICY "Allow authenticated users to delete icons" ON storage.objects
    FOR DELETE TO authenticated
    USING (bucket_id = 'chatbot-icons');
END $$;