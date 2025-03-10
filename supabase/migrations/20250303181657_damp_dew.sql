/*
  # Fix RLS policies for flows table

  1. Changes
    - Drop and recreate flows RLS policies
    - Allow authenticated users to manage their flows
    - Ensure proper user_id scoping

  2. Security
    - Restrict access to authenticated users only
    - Scope flows to user's chatbots
*/

-- Drop existing policies
DROP POLICY IF EXISTS "admin_can_manage_flows" ON flows;
DROP POLICY IF EXISTS "users_can_read_own_flows" ON flows;
DROP POLICY IF EXISTS "users_can_insert_own_flows" ON flows;
DROP POLICY IF EXISTS "users_can_update_own_flows" ON flows;

-- Create new policies for flows
CREATE POLICY "users_can_read_flows" ON flows
  FOR SELECT TO authenticated
  USING (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "users_can_insert_flows" ON flows
  FOR INSERT TO authenticated
  WITH CHECK (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "users_can_update_flows" ON flows
  FOR UPDATE TO authenticated
  USING (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "users_can_delete_flows" ON flows
  FOR DELETE TO authenticated
  USING (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );