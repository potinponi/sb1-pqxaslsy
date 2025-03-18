/*
  # Fix storage policies and folder access

  1. Changes
    - Simplify storage policies to one policy per operation
    - Ensure proper folder-level access control
    - Fix public read access for widget files
    - Update bucket configuration
*/

-- Drop all existing widget-files policies
DROP POLICY IF EXISTS "widget_files_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_delete_policy" ON storage.objects;
DROP POLICY IF EXISTS "authenticated_users_read_own_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "allow_public_widget_file_access" ON storage.objects;

-- Create simplified policies
CREATE POLICY "widget_files_manage_policy"
  ON storage.objects
  FOR ALL TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "widget_files_read_policy"
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