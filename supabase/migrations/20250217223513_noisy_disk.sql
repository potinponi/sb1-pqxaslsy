/*
  # Initial Schema Setup

  1. New Tables
    - `chatbots`
    - `leads`
    - `flows`
  
  2. Security
    - Enable RLS
    - Create indexes
*/

-- Create tables
CREATE TABLE IF NOT EXISTS chatbots (
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

CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  name text NOT NULL,
  email text NOT NULL,
  answers jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS flows (
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

-- Create indexes
CREATE INDEX IF NOT EXISTS leads_chatbot_id_idx ON leads(chatbot_id);
CREATE INDEX IF NOT EXISTS flows_chatbot_id_idx ON flows(chatbot_id);
CREATE INDEX IF NOT EXISTS leads_created_at_idx ON leads(created_at);

-- Insert default chatbot
INSERT INTO chatbots (id, name)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'Default Chatbot'
) ON CONFLICT (id) DO NOTHING;