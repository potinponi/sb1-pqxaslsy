/*
  # Rename storage policies for clarity

  1. Changes
    - Rename policies to better reflect their purpose
    - No functional changes, just clearer naming
*/

-- Drop existing policies
DROP POLICY IF EXISTS "widget_files_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "widget_files_public_select_policy" ON storage.objects;

-- Recreate with clearer names
CREATE POLICY "authenticated_users_read_own_widget_files"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'widget-files' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "allow_public_widget_file_access"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'widget-files');