/*
  # Fix widget storage policies and access

  1. Changes
    - Drop existing widget storage policies
    - Create new simplified policies for proper ID handling
    - Update bucket configuration
    - Add specific policy for demo chatbot files

  2. Security
    - Allow public read access to all widget files
    - Restrict file management to authenticated users
    - Special handling for demo chatbot
*/

-- Drop existing policies
DROP POLICY IF EXISTS "widget_files_manage_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_read_policy" ON storage.objects;

-- Create new policies
CREATE POLICY "widget_files_manage_own"
  ON storage.objects
  FOR ALL TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    (
      -- Allow access if file is in user's folder
      auth.uid()::text = (storage.foldername(name))[1]
      OR
      -- Allow access if file belongs to demo chatbot
      (storage.foldername(name))[1] = 'a54a2bd1-cf6a-4af7-8435-c256c10794e7'
    )
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    (
      auth.uid()::text = (storage.foldername(name))[1]
      OR
      (storage.foldername(name))[1] = 'a54a2bd1-cf6a-4af7-8435-c256c10794e7'
    )
  );

CREATE POLICY "widget_files_public_read"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');

-- Update bucket configuration
UPDATE storage.buckets
SET 
  public = true,
  file_size_limit = 5242880, -- 5MB
  allowed_mime_types = ARRAY[
    'application/javascript',
    'text/javascript',
    'application/x-javascript',
    'text/css'
  ]::text[]
WHERE id = 'widget-files';