/*
  # Update theme settings structure

  1. Changes
    - Add message color fields to theme settings
    - Update existing theme settings with new defaults
  
  2. Notes
    - Preserves existing theme data
    - Adds new color fields for message customization
*/

-- Update existing chatbots with new theme structure
UPDATE chatbots
SET settings = jsonb_set(
  CASE 
    WHEN settings->>'theme' IS NULL THEN 
      jsonb_set(settings, '{theme}', '{
        "primaryColor": "#a7e154",
        "backgroundColor": "#1a1a1a",
        "headerColor": "#232323",
        "botMessageColor": "#232323",
        "userMessageColor": "#a7e154",
        "inputColor": "#1a1a1a",
        "fontFamily": "system-ui",
        "borderRadius": "0.5rem"
      }'::jsonb)
    ELSE settings
  END,
  '{theme}',
  settings->'theme' || '{
    "botMessageColor": "#232323",
    "userMessageColor": "#a7e154"
  }'::jsonb
)
WHERE settings->>'theme' IS NOT NULL 
  AND (
    settings->'theme'->>'botMessageColor' IS NULL 
    OR settings->'theme'->>'userMessageColor' IS NULL
  );