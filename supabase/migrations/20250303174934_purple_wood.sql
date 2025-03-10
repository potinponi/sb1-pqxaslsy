/*
  # Fix chatbot and leads policies

  1. Changes
    - Add policies for chatbots table
    - Update leads policies to handle both widget and admin cases
    - Fix policy naming for clarity

  2. Security
    - Allow public access for widget interactions
    - Restrict admin access to authenticated users
*/

-- Drop existing policies
DROP POLICY IF EXISTS "anyone_can_insert_leads" ON leads;
DROP POLICY IF EXISTS "users_can_read_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_update_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_delete_own_leads" ON leads;

-- Create new leads policies
CREATE POLICY "widget_can_insert_leads" ON leads
  FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY "admin_can_read_leads" ON leads
  FOR SELECT TO authenticated
  USING (chatbot_id = auth.uid());

CREATE POLICY "admin_can_update_leads" ON leads
  FOR UPDATE TO authenticated
  USING (chatbot_id = auth.uid())
  WITH CHECK (chatbot_id = auth.uid());

CREATE POLICY "admin_can_delete_leads" ON leads
  FOR DELETE TO authenticated
  USING (chatbot_id = auth.uid());

-- Drop existing chatbot policies
DROP POLICY IF EXISTS "users_can_read_own_chatbots" ON chatbots;
DROP POLICY IF EXISTS "users_can_insert_own_chatbots" ON chatbots;
DROP POLICY IF EXISTS "users_can_update_own_chatbots" ON chatbots;

-- Create new chatbot policies
CREATE POLICY "public_can_read_chatbots" ON chatbots
  FOR SELECT TO public
  USING (true);

CREATE POLICY "admin_can_manage_chatbots" ON chatbots
  FOR ALL TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());