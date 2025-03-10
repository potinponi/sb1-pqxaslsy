/*
  # Fix leads table RLS policies and add user_id column

  1. Changes
    - Add user_id column to leads table
    - Update RLS policies to handle both authenticated and anonymous users
    - Add indexes for performance

  2. Security
    - Anonymous users can insert leads
    - Authenticated users can manage their own leads
    - Proper scoping through user_id and chatbot ownership
*/

-- Add user_id column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE leads ADD COLUMN user_id uuid REFERENCES auth.users(id);
    CREATE INDEX leads_user_id_idx ON leads(user_id);
  END IF;
END $$;

-- Drop existing policies
DROP POLICY IF EXISTS "anon_can_insert_leads" ON leads;
DROP POLICY IF EXISTS "users_can_read_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_update_own_leads" ON leads;
DROP POLICY IF EXISTS "users_can_delete_own_leads" ON leads;

-- Create new RLS policies
CREATE POLICY "anyone_can_insert_leads" ON leads
  FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY "users_can_read_own_leads" ON leads
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid() OR
    chatbot_id IN (SELECT id FROM chatbots WHERE user_id = auth.uid())
  );

CREATE POLICY "users_can_update_own_leads" ON leads
  FOR UPDATE TO authenticated
  USING (
    user_id = auth.uid() OR
    chatbot_id IN (SELECT id FROM chatbots WHERE user_id = auth.uid())
  )
  WITH CHECK (
    user_id = auth.uid() OR
    chatbot_id IN (SELECT id FROM chatbots WHERE user_id = auth.uid())
  );

CREATE POLICY "users_can_delete_own_leads" ON leads
  FOR DELETE TO authenticated
  USING (
    user_id = auth.uid() OR
    chatbot_id IN (SELECT id FROM chatbots WHERE user_id = auth.uid())
  );