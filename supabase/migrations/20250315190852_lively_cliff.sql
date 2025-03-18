/*
  # Fix Storage Policies for Widget Files

  1. Changes
    - Drop existing policies
    - Add new policies with proper folder-level access
    - Allow public read access
    - Fix bucket configuration
    
  2. Security
    - Users can only manage files in their own folders
    - Public read access for all widget files
    - Proper MIME type validation
*/

-- Drop existing policies
DROP POLICY IF EXISTS "users_can_insert_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "users_can_update_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "users_can_delete_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "users_can_select_widget_files" ON storage.objects;
DROP POLICY IF EXISTS "public_can_read_widget_files" ON storage.objects;

-- Create new policies
CREATE POLICY "widget_files_insert_policy"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'widget-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "widget_files_update_policy"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "widget_files_delete_policy"
  ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "widget_files_select_policy"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "widget_files_public_select_policy"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');

-- Ensure bucket exists with proper configuration
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