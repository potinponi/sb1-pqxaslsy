/*
  # Fix storage policies for widget files

  1. Changes
    - Add policies for customer-specific widget file management
    - Restrict users to their own folders
    - Allow public read access
    
  2. Security
    - Users can only manage files in their own directory
    - Public read access for all widget files
*/

-- Create widget-files bucket if it doesn't exist
DO $$ 
BEGIN
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'widget-files',
    'widget-files',
    true,
    5242880, -- 5MB
    ARRAY[
      'application/javascript',
      'text/javascript',
      'text/css'
    ]::text[]
  )
  ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY[
      'application/javascript',
      'text/javascript',
      'text/css'
    ]::text[];

  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Allow authenticated users to manage widget files" ON storage.objects;
  DROP POLICY IF EXISTS "Allow public to read widget files" ON storage.objects;

  -- Create new policies
  CREATE POLICY "Allow authenticated users to manage widget files"
    ON storage.objects
    FOR ALL TO authenticated 
    USING (
      bucket_id = 'widget-files' AND
      (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
      bucket_id = 'widget-files' AND
      (storage.foldername(name))[1] = auth.uid()::text
    );

  CREATE POLICY "Allow public to read widget files"
    ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'widget-files');

END $$;