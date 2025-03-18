/*
  # Fix storage policies for widget files

  1. Changes
    - Drop existing policies
    - Create separate policies for each operation
    - Ensure proper user isolation
    - Allow public read access
  
  2. Security
    - Maintain proper user isolation through folder structure
    - Enable public read access for widget files
    - Allow authenticated users full CRUD access to their own files
*/

-- Drop existing policies
DROP POLICY IF EXISTS "authenticated_users_manage_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "public_read_widget_files" ON storage.objects;

-- Create separate policies for each operation
CREATE POLICY "users_can_insert_widget_files"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  );

CREATE POLICY "users_can_update_widget_files"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  );

CREATE POLICY "users_can_delete_widget_files"
  ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  );

CREATE POLICY "users_can_select_widget_files"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = COALESCE((storage.foldername(name))[1], '')
  );

CREATE POLICY "public_can_read_widget_files"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');

-- Ensure widget-files bucket exists with proper configuration
DO $$ 
BEGIN
  -- Create or update bucket
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'widget-files',
    'widget-files',
    true,
    5242880, -- 5MB
    ARRAY[
      'application/javascript',
      'text/javascript',
      'application/x-javascript',
      'text/css'
    ]::text[]
  )
  ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY[
      'application/javascript',
      'text/javascript',
      'application/x-javascript',
      'text/css'
    ]::text[];

  -- Ensure bucket is public
  UPDATE storage.buckets
  SET public = true
  WHERE id = 'widget-files';
END $$;