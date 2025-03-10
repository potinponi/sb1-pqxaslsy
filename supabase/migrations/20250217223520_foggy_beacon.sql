/*
  # RLS Policies Setup

  1. Security
    - Add RLS policies for authenticated users
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow full access to authenticated users" ON chatbots;
DROP POLICY IF EXISTS "Allow full access to authenticated users" ON leads;
DROP POLICY IF EXISTS "Allow full access to authenticated users" ON flows;

-- Create new policies
CREATE POLICY "authenticated_users_full_access_chatbots" ON chatbots
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "authenticated_users_full_access_leads" ON leads
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "authenticated_users_full_access_flows" ON flows
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);