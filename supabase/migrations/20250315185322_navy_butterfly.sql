/*
  # Fix storage policies for widget files

  1. Changes
    - Make widget-files bucket public
    - Allow authenticated users to manage their own files
    - Allow public read access to all widget files
    - Update bucket configuration for proper MIME types
  
  2. Security
    - Maintain proper user isolation
    - Enable public access for widget files
    - Ensure correct file permissions
*/

-- Drop existing storage policies
DROP POLICY IF EXISTS "Users can manage own widget files" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can read widget files" ON storage.objects;

-- Create new storage policies
CREATE POLICY "authenticated_users_manage_widget_files"
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

-- Ensure widget-files bucket exists with proper configuration
DO $$ 
BEGIN
  -- Create or update bucket
  INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
  VALUES (
    'widget-files',
    'widget-files',
    true, -- Make sure bucket is public
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

  -- Update bucket public access
  UPDATE storage.buckets
  SET public = true
  WHERE id = 'widget-files';
END $$;