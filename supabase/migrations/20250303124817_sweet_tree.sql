/*
  # Fix Data Isolation Between Users

  1. Changes
    - Add user_id column to chatbots table
    - Update RLS policies to properly scope data by user_id
    - Add indexes for performance

  2. Security
    - Users can only access their own chatbots and related data
    - Proper data isolation between users
*/

-- Add user_id to chatbots if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chatbots' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE chatbots ADD COLUMN user_id uuid REFERENCES auth.users(id);
    CREATE INDEX chatbots_user_id_idx ON chatbots(user_id);
  END IF;
END $$;

-- Drop existing policies
DROP POLICY IF EXISTS "authenticated_users_full_access_chatbots" ON chatbots;
DROP POLICY IF EXISTS "authenticated_users_full_access_leads" ON leads;
DROP POLICY IF EXISTS "authenticated_users_full_access_flows" ON flows;

-- Create new RLS policies
CREATE POLICY "users_can_read_own_chatbots" ON chatbots
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "users_can_insert_own_chatbots" ON chatbots
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_can_update_own_chatbots" ON chatbots
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Leads policies scoped through chatbot ownership
CREATE POLICY "users_can_read_own_leads" ON leads
  FOR SELECT TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_insert_own_leads" ON leads
  FOR INSERT TO authenticated
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_delete_own_leads" ON leads
  FOR DELETE TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

-- Flow policies scoped through chatbot ownership
CREATE POLICY "users_can_read_own_flows" ON flows
  FOR SELECT TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_insert_own_flows" ON flows
  FOR INSERT TO authenticated
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_update_own_flows" ON flows
  FOR UPDATE TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ))
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));