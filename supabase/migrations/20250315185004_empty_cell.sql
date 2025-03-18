/*
  # Fix RLS policies for chatbots and storage

  1. Changes
    - Update chatbot policies to allow all authenticated users
    - Fix storage policies for widget files
    - Ensure proper access control while allowing saves
  
  2. Security
    - Allow authenticated users to manage their own chatbots
    - Allow public read access to specific chatbots
    - Maintain proper file access control
*/

-- Drop existing chatbot policies
DROP POLICY IF EXISTS "Public can read specific chatbots" ON chatbots;
DROP POLICY IF EXISTS "admin_can_manage_chatbots" ON chatbots;

-- Create new chatbot policies
CREATE POLICY "Public can read specific chatbots"
  ON chatbots
  FOR SELECT TO public
  USING (id = 'a54a2bd1-cf6a-4af7-8435-c256c10794e7'::uuid);

CREATE POLICY "Users can manage own chatbots"
  ON chatbots
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Drop existing storage policies
DROP POLICY IF EXISTS "authenticated_users_manage_own_widgets" ON storage.objects;
DROP POLICY IF EXISTS "public_read_widget_files" ON storage.objects;

-- Create new storage policies
CREATE POLICY "Users can manage own widget files"
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

CREATE POLICY "Anyone can read widget files"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');

-- Ensure widget-files bucket exists with proper configuration
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
END $$;