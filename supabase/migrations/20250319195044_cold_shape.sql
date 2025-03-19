/*
  # Fix User ID Linking and Policies

  1. Changes
    - Update chatbots policies to use user_id for proper data isolation
    - Update widget_configs policies to link through chatbot ownership
    - Add policy for public access to specific chatbot
    
  2. Security
    - Ensure proper data isolation between users
    - Allow public access only to specific chatbot
    - Maintain proper access control through user_id
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Public can read specific chatbots" ON chatbots;
DROP POLICY IF EXISTS "Users can manage own chatbots" ON chatbots;
DROP POLICY IF EXISTS "Public can read specific widget configs" ON widget_configs;
DROP POLICY IF EXISTS "Users can manage their own widget configs" ON widget_configs;

-- Create new chatbot policies
CREATE POLICY "Public can read specific chatbots"
  ON chatbots
  FOR SELECT
  TO public
  USING (id = 'a54a2bd1-cf6a-4af7-8435-c256c10794e7'::uuid);

CREATE POLICY "Users can manage own chatbots"
  ON chatbots
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Create new widget_configs policies
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

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS chatbots_user_id_idx ON chatbots(user_id);
CREATE INDEX IF NOT EXISTS widget_configs_chatbot_id_idx ON widget_configs(chatbot_id);

-- Ensure user_id column exists
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chatbots' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE chatbots ADD COLUMN user_id uuid REFERENCES auth.users(id);
  END IF;
END $$;