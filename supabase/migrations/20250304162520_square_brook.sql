/*
  # Add storage cleanup trigger

  1. New Functions
    - `get_file_info` - Extracts bucket and file name from storage URL
    - `clean_unused_icons` - Cleans up unused icon files
    - `handle_chatbot_icon_changes` - Manages icon cleanup on chatbot updates

  2. Changes
    - Add trigger on chatbots table for icon cleanup
    - Add helper functions for URL parsing and file management
*/

-- Helper function to extract file info from URL
CREATE OR REPLACE FUNCTION get_file_info(url text)
RETURNS TABLE (bucket_id text, file_name text)
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT 
    split_part(replace(url, 'https://ziuyjhndicmqxhetyxux.supabase.co/storage/v1/object/public/', ''), '/', 1),
    substring(url from '/public/[^/]+/(.*)$')
$$;

-- Function to clean up unused icons
CREATE OR REPLACE FUNCTION clean_unused_icons(old_url text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  file_info record;
BEGIN
  IF old_url IS NULL THEN
    RETURN;
  END IF;

  SELECT * INTO file_info FROM get_file_info(old_url);
  
  IF file_info.bucket_id IS NOT NULL AND file_info.file_name IS NOT NULL THEN
    -- Check if file is still referenced
    IF NOT EXISTS (
      SELECT 1 FROM chatbots 
      WHERE settings->'theme'->>'botIcon' = old_url 
         OR settings->'theme'->>'userIcon' = old_url
    ) THEN
      -- Delete file if not referenced
      DELETE FROM storage.objects
      WHERE bucket_id = file_info.bucket_id 
        AND name = file_info.file_name;
    END IF;
  END IF;
END;
$$;

-- Trigger function to handle icon changes
CREATE OR REPLACE FUNCTION handle_chatbot_icon_changes()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Handle bot icon changes
  IF (OLD.settings->'theme'->>'botIcon') IS DISTINCT FROM (NEW.settings->'theme'->>'botIcon') THEN
    PERFORM clean_unused_icons(OLD.settings->'theme'->>'botIcon');
  END IF;

  -- Handle user icon changes
  IF (OLD.settings->'theme'->>'userIcon') IS DISTINCT FROM (NEW.settings->'theme'->>'userIcon') THEN
    PERFORM clean_unused_icons(OLD.settings->'theme'->>'userIcon');
  END IF;

  RETURN NEW;
END;
$$;

-- Create or replace trigger
DROP TRIGGER IF EXISTS chatbot_icon_cleanup_trigger ON chatbots;
CREATE TRIGGER chatbot_icon_cleanup_trigger
  AFTER UPDATE ON chatbots
  FOR EACH ROW
  WHEN (
    (OLD.settings->'theme'->>'botIcon') IS DISTINCT FROM (NEW.settings->'theme'->>'botIcon') OR
    (OLD.settings->'theme'->>'userIcon') IS DISTINCT FROM (NEW.settings->'theme'->>'userIcon')
  )
  EXECUTE FUNCTION handle_chatbot_icon_changes();