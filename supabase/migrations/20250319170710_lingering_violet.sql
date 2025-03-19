/*
  # Add Chat Interactions Tracking

  1. New Tables
    - `chat_interactions`
      - `id` (uuid, primary key)
      - `chatbot_id` (uuid, foreign key to chatbots)
      - `type` (text) - Type of interaction (open, close, start_flow)
      - `created_at` (timestamp)
      - `session_id` (text) - To group interactions from same session
      - `converted` (boolean) - Whether this interaction led to a lead

  2. Security
    - Enable RLS
    - Allow public to insert interactions
    - Allow users to read their own chatbot's interactions
*/

-- Create chat_interactions table
CREATE TABLE chat_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  type text NOT NULL,
  session_id text NOT NULL,
  converted boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE chat_interactions ENABLE ROW LEVEL SECURITY;

-- Create indexes
CREATE INDEX chat_interactions_chatbot_id_idx ON chat_interactions(chatbot_id);
CREATE INDEX chat_interactions_created_at_idx ON chat_interactions(created_at);
CREATE INDEX chat_interactions_type_idx ON chat_interactions(type);
CREATE INDEX chat_interactions_session_id_idx ON chat_interactions(session_id);

-- Create policies
CREATE POLICY "Anyone can insert chat interactions"
  ON chat_interactions
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Users can read own chatbot interactions"
  ON chat_interactions
  FOR SELECT
  TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));