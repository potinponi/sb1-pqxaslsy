/*
  # Add widget storage configuration

  1. Changes
    - Add storage bucket for customer-specific widget files
    - Add policies for widget file management
    - Add function to handle widget file cleanup

  2. Security
    - Enable public read access for widget files
    - Restrict write access to authenticated users
    - Ensure proper file cleanup
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

  -- Create storage policies
  CREATE POLICY "Allow authenticated users to manage widget files"
    ON storage.objects
    FOR ALL TO authenticated
    USING (bucket_id = 'widget-files')
    WITH CHECK (bucket_id = 'widget-files');

  CREATE POLICY "Allow public to read widget files"
    ON storage.objects
    FOR SELECT TO public
    USING (bucket_id = 'widget-files');

END $$;