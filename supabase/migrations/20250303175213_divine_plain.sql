/*
  # Fix RLS policies for leads and chatbots

  1. Changes
    - Update leads policies to handle both widget and admin access
    - Fix chatbot policies for proper ID handling
    - Add policies for flows table

  2. Security
    - Allow public access for widget lead submissions
    - Restrict admin access to authenticated users
    - Ensure proper ID scoping
*/

-- Drop existing policies
DROP POLICY IF EXISTS "widget_can_insert_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_read_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_update_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_delete_leads" ON leads;

-- Create new leads policies
CREATE POLICY "widget_can_insert_leads" ON leads
  FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY "admin_can_read_leads" ON leads
  FOR SELECT TO authenticated
  USING (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "admin_can_update_leads" ON leads
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

CREATE POLICY "admin_can_delete_leads" ON leads
  FOR DELETE TO authenticated
  USING (
    chatbot_id IN (
      SELECT id FROM chatbots WHERE user_id = auth.uid()
    )
  );

-- Drop existing chatbot policies
DROP POLICY IF EXISTS "public_can_read_chatbots" ON chatbots;
DROP POLICY IF EXISTS "admin_can_manage_chatbots" ON chatbots;

-- Create new chatbot policies
CREATE POLICY "public_can_read_chatbots" ON chatbots
  FOR SELECT TO public
  USING (true);

CREATE POLICY "admin_can_manage_chatbots" ON chatbots
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Drop existing flow policies if they exist
DROP POLICY IF EXISTS "admin_can_manage_flows" ON flows;

-- Create new flow policies
CREATE POLICY "admin_can_manage_flows" ON flows
  FOR ALL TO authenticated
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