/*
  # Add storage policies for widget uploads

  1. Security
    - Enable storage policies for widgets bucket
    - Allow authenticated users to read and write widget files
    - Allow public read access to widget files
*/

-- Create policy to allow authenticated users to upload files
CREATE POLICY "Allow authenticated users to upload widgets" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'widgets' AND
    (storage.foldername(name))[1] IS NULL
  );

-- Create policy to allow authenticated users to update files
CREATE POLICY "Allow authenticated users to update widgets" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'widgets')
  WITH CHECK (bucket_id = 'widgets');

-- Create policy to allow authenticated users to read files
CREATE POLICY "Allow authenticated users to read widgets" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'widgets');

-- Create policy to allow public to read files
CREATE POLICY "Allow public to read widgets" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widgets');

-- Create policy to allow authenticated users to delete files
CREATE POLICY "Allow authenticated users to delete widgets" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'widgets');