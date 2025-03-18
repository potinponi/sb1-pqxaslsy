/*
  # Update widget_configs structure

  1. Changes
    - Add comprehensive theme configuration
    - Add flow configuration for chat behavior
    - Add updated_at trigger
    - Add RLS policies for proper access control

  2. Data Structure
    - theme: {
        primaryColor: string
        backgroundColor: string
        headerColor: string
        messageColor: string
        botMessageColor: string
        userMessageColor: string
        inputColor: string
        botTextColor: string
        userTextColor: string
        headerTextColor: string
        fontFamily: string
        borderRadius: string
        gradient?: {
          from: string
          to: string
        }
        showMessageIcons: boolean
        botIcon?: string
        userIcon?: string
        buttonIcon?: string
      }
    - flow: {
        welcomeMessage: string
        endMessage: string
        showEndScreen: boolean
        proactiveMessages?: {
          enabled: boolean
          messages: string[]
          delay: number
          interval: number
          maxMessages: number
        }
        options: {
          id: string
          label: string
          flow: {
            id: string
            type: string
            label: string
            required: boolean
          }[]
        }[]
      }
*/

-- Create widget_configs table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'widget_configs') THEN
    CREATE TABLE widget_configs (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
      theme jsonb NOT NULL DEFAULT '{
        "primaryColor": "#a7e154",
        "backgroundColor": "#1a1a1a",
        "headerColor": "#232323",
        "messageColor": "#232323",
        "botMessageColor": "#232323",
        "userMessageColor": "#a7e154",
        "inputColor": "#1a1a1a",
        "botTextColor": "#ffffff",
        "userTextColor": "#000000",
        "headerTextColor": "#ffffff",
        "fontFamily": "system-ui",
        "borderRadius": "0.5rem",
        "showMessageIcons": true
      }'::jsonb,
      flow jsonb NOT NULL DEFAULT '{
        "welcomeMessage": "Hello! 👋 How can I help you today?",
        "endMessage": "Thank you for your responses! We''ll be in touch soon.",
        "showEndScreen": true,
        "options": []
      }'::jsonb,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Enable RLS
    ALTER TABLE widget_configs ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create index for faster lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS widget_configs_chatbot_id_idx ON widget_configs(chatbot_id);

-- Create or replace the update function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_widget_configs_updated_at'
  ) THEN
    CREATE TRIGGER update_widget_configs_updated_at
      BEFORE UPDATE ON widget_configs
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Drop existing policies
DROP POLICY IF EXISTS "Public can read specific widget configs" ON widget_configs;
DROP POLICY IF EXISTS "Users can manage their own widget configs" ON widget_configs;

-- Create RLS policies
CREATE POLICY "Public can read specific widget configs"
  ON widget_configs
  FOR SELECT
  TO public
  USING (chatbot_id = 'a54a2bd1-cf6a-4af7-8435-c256c10794e7'::uuid);

CREATE POLICY "Users can manage their own widget configs"
  ON widget_configs
  FOR ALL
  TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ))
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));