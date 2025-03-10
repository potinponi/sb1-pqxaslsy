/*
  # Add feedback table and policies

  1. New Tables
    - `feedback`
      - `id` (uuid, primary key)
      - `chatbot_id` (uuid, foreign key to chatbots)
      - `satisfied` (boolean)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `feedback` table
    - Add policy for public to submit feedback
    - Add policy for authenticated users to read their own feedback
*/

-- Check if feedback table exists and create if not
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedback') THEN
    CREATE TABLE feedback (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
      satisfied boolean NOT NULL,
      created_at timestamptz DEFAULT now()
    );

    ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Check and create policies if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'feedback' 
    AND policyname = 'Anyone can submit feedback'
  ) THEN
    CREATE POLICY "Anyone can submit feedback"
      ON feedback
      FOR INSERT
      TO public
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'feedback' 
    AND policyname = 'Users can read own feedback'
  ) THEN
    CREATE POLICY "Users can read own feedback"
      ON feedback
      FOR SELECT
      TO authenticated
      USING (chatbot_id IN (
        SELECT id FROM chatbots WHERE user_id = auth.uid()
      ));
  END IF;
END $$;