/*
  # Add feedback collection

  1. New Tables
    - `feedback`
      - `id` (uuid, primary key)
      - `chatbot_id` (uuid, foreign key to chatbots)
      - `satisfied` (boolean)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `feedback` table
    - Add policies for authenticated users to read their own data
    - Allow public to insert feedback
*/

CREATE TABLE IF NOT EXISTS feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  satisfied boolean NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read their own chatbot's feedback
CREATE POLICY "Users can read own feedback"
  ON feedback
  FOR SELECT
  TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

-- Allow anyone to submit feedback
CREATE POLICY "Anyone can submit feedback"
  ON feedback
  FOR INSERT
  TO public
  WITH CHECK (true);