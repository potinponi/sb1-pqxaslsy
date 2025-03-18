/*
  # Fix RLS Policies and Table Relationships

  1. Changes
    - Add user_id to chatbots table
    - Update RLS policies for proper data isolation
    - Fix storage policies for widget files
    - Add proper indexes for performance

  2. Security
    - Users can only access their own data
    - Public can read specific chatbots
    - Proper storage access control
*/

-- Add user_id to chatbots if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chatbots' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE chatbots ADD COLUMN user_id uuid REFERENCES auth.users(id);
    CREATE INDEX chatbots_user_id_idx ON chatbots(user_id);
  END IF;
END $$;

-- Drop existing chatbot policies
DROP POLICY IF EXISTS "Public can read specific chatbots" ON chatbots;
DROP POLICY IF EXISTS "Users can manage own chatbots" ON chatbots;

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
DROP POLICY IF EXISTS "widget_files_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_delete_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_public_select_policy" ON storage.objects;

-- Create new storage policies with proper folder-level access
CREATE POLICY "widget_files_insert_policy"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "widget_files_update_policy"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  )
  WITH CHECK (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "widget_files_delete_policy"
  ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "widget_files_select_policy"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "widget_files_public_select_policy"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');

-- Update widget-files bucket configuration
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

-- Create function to handle updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger to chatbots table
DROP TRIGGER IF EXISTS update_chatbots_updated_at ON chatbots;
CREATE TRIGGER update_chatbots_updated_at
  BEFORE UPDATE ON chatbots
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();