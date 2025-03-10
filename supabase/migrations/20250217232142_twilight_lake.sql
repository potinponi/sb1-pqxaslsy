/*
  # Update storage policies for anonymous access
  
  1. Changes
    - Allow anonymous uploads to widgets bucket
    - Maintain existing public read access
    - Update MIME type restrictions
  
  2. Security
    - Restrict uploads to specific file types
    - Maintain file size limits
    - Ensure proper bucket access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "widgets_upload_policy" ON storage.objects;
DROP POLICY IF EXISTS "widgets_update_policy" ON storage.objects;

-- Create new policies for anonymous access
CREATE POLICY "widgets_anon_upload_policy" ON storage.objects
  FOR INSERT TO anon
  WITH CHECK (
    bucket_id = 'widgets' AND
    (storage.foldername(name))[1] IS NULL AND
    (CASE lower(substring(name FROM '\.([^\.]+)$'))
      WHEN 'js'  THEN true
      WHEN 'css' THEN true
      ELSE false
    END)
  );

CREATE POLICY "widgets_anon_update_policy" ON storage.objects
  FOR UPDATE TO anon
  USING (bucket_id = 'widgets')
  WITH CHECK (
    bucket_id = 'widgets' AND
    (CASE lower(substring(name FROM '\.([^\.]+)$'))
      WHEN 'js'  THEN true
      WHEN 'css' THEN true
      ELSE false
    END)
  );

-- Update bucket configuration
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'application/javascript',
  'text/javascript',
  'application/x-javascript',
  'text/css'
]::text[]
WHERE id = 'widgets';