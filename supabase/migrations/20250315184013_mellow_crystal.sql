/*
  # Fix storage policies for widget files

  1. Changes
    - Drop existing policies
    - Create new policies with proper user scoping
    - Allow users to manage only their own folders
    - Maintain public read access
  
  2. Security
    - Scope access by user ID in folder path
    - Prevent access to other users' files
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated users to manage widget files" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to read widget files" ON storage.objects;

-- Create new policies with proper scoping
CREATE POLICY "authenticated_users_manage_own_widgets"
  ON storage.objects
  FOR ALL TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  );

CREATE POLICY "public_read_widget_files"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');