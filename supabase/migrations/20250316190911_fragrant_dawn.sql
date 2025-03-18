/*
  # Fix widget_configs policies and access

  1. Changes
    - Add policies for widget_configs table
    - Allow public read access for specific chatbot
    - Allow authenticated users to manage their configs
    - Add index for faster lookups

  2. Security
    - Public can only read specific demo chatbot config
    - Users can only manage their own configs
    - Proper data isolation between users
*/

-- Create unique index on chatbot_id if it doesn't exist
CREATE UNIQUE INDEX IF NOT EXISTS widget_configs_chatbot_id_key 
ON widget_configs(chatbot_id);

-- Create regular index for performance
CREATE INDEX IF NOT EXISTS widget_configs_chatbot_id_idx 
ON widget_configs(chatbot_id);

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can read specific widget configs" ON widget_configs;
DROP POLICY IF EXISTS "Users can manage their own widget configs" ON widget_configs;

-- Create new policies
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

-- Ensure RLS is enabled
ALTER TABLE widget_configs ENABLE ROW LEVEL SECURITY;