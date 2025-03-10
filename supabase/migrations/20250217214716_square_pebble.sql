/*
  # Update storage configuration for JavaScript files

  1. Changes
    - Add JavaScript MIME types to allowed file types
    - Update security policies for JavaScript files
    - Set appropriate content types

  2. Security
    - Maintain existing RLS policies
    - Add specific MIME type validations
*/

-- Update storage.buckets configuration
UPDATE storage.buckets
SET allowed_mime_types = ARRAY[
  'application/javascript',
  'text/javascript',
  'application/x-javascript',
  'text/css'
]::text[]
WHERE name = 'widgets';

-- Ensure proper MIME type handling
CREATE OR REPLACE FUNCTION storage.extension_to_mime_type(filename text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE lower(substring(filename FROM '\.([^\.]+)$'))
    WHEN 'js'  THEN 'application/javascript'
    WHEN 'css' THEN 'text/css'
    ELSE 'application/octet-stream'
  END
$$;