/*
  # Initial Schema Setup for Lead Generation Chatbot

  1. New Tables
    - chatbots: Stores chatbot configurations
    - leads: Stores captured leads
    - flows: Stores form flow configurations

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated access
*/

-- Create tables
CREATE TABLE chatbots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  settings jsonb NOT NULL DEFAULT '{
    "theme": {
      "primaryColor": "#4F46E5",
      "backgroundColor": "#FFFFFF"
    },
    "welcomeMessage": "Hello! 👋 How can I help you today?"
  }'::jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  name text NOT NULL,
  email text NOT NULL,
  answers jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE flows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  data jsonb NOT NULL DEFAULT '{
    "questions": []
  }'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE chatbots ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE flows ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow full access to authenticated users" ON chatbots
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow full access to authenticated users" ON leads
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow full access to authenticated users" ON flows
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX leads_chatbot_id_idx ON leads(chatbot_id);
CREATE INDEX flows_chatbot_id_idx ON flows(chatbot_id);
CREATE INDEX leads_created_at_idx ON leads(created_at);