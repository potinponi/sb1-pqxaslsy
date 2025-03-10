/*
  # Create default chatbot

  1. Changes
    - Insert a default chatbot with a fixed UUID
    - Add function to get default chatbot ID
*/

-- Insert default chatbot with a fixed UUID
INSERT INTO chatbots (id, name)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'Default Chatbot'
) ON CONFLICT (id) DO NOTHING;

-- Create function to get default chatbot ID
CREATE OR REPLACE FUNCTION get_default_chatbot_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT '00000000-0000-0000-0000-000000000000'::uuid;
$$;