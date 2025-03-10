/*
  # Fix leads table RLS policies

  1. Changes
    - Allow anonymous users to insert leads
    - Allow authenticated users to read their own leads
    - Allow authenticated users to delete their own leads
    - Add policy for updating leads

  2. Security
    - Anonymous users can only insert
    - Authenticated users can only access leads from their chatbots
*/

-- Drop existing policies
DROP POLICY IF EXISTS "anon_can_insert_leads" ON leads;
DROP POLICY IF EXISTS "users_can_read_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_delete_own_leads" ON leads;

-- Create new RLS policies
CREATE POLICY "anon_can_insert_leads" ON leads
  FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY "users_can_read_own_leads" ON leads
  FOR SELECT TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_update_own_leads" ON leads
  FOR UPDATE TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ))
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_delete_own_leads" ON leads
  FOR DELETE TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));