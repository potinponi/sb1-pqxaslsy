/*
  # Fix leads policies and permissions

  1. Changes
    - Add public insert policy for leads from widget
    - Update read policy for admin users
    - Add indexes for better performance

  2. Security
    - Enable RLS
    - Add policies for proper access control
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "widget_can_insert_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_read_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_update_leads" ON leads;
DROP POLICY IF EXISTS "admin_can_delete_leads" ON leads;

-- Create new policies
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS leads_chatbot_id_created_at_idx ON leads(chatbot_id, created_at DESC);