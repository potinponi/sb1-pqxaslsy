/*
  # Fix RLS policies for leads table

  1. Changes
    - Add RLS policy for anonymous users to insert leads
    - Add RLS policy for authenticated users to read their own leads
    - Add RLS policy for authenticated users to delete their own leads

  2. Security
    - Anonymous users can only insert leads
    - Authenticated users can only read/delete leads for their chatbots
    - No update policy needed for leads as they should be immutable
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "users_can_read_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_insert_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_delete_own_leads" ON leads;

-- Create new RLS policies
CREATE POLICY "anon_can_insert_leads" ON leads
  FOR INSERT TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "users_can_read_own_leads" ON leads
  FOR SELECT TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

CREATE POLICY "users_can_delete_own_leads" ON leads
  FOR DELETE TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));