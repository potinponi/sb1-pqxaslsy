/*
  # Add widget configuration table

  1. New Tables
    - `widget_configs`
      - `id` (uuid, primary key)
      - `chatbot_id` (uuid, foreign key to chatbots)
      - `theme` (jsonb)
      - `flow` (jsonb)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `widget_configs` table
    - Add policy for public read access to widget configs
    - Add policy for authenticated users to manage their own configs
*/

CREATE TABLE IF NOT EXISTS widget_configs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chatbot_id uuid REFERENCES chatbots(id) ON DELETE CASCADE,
  theme jsonb NOT NULL DEFAULT '{}'::jsonb,
  flow jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE widget_configs ENABLE ROW LEVEL SECURITY;

-- Allow public read access to widget configs
CREATE POLICY "Public can read widget configs"
  ON widget_configs
  FOR SELECT
  TO public
  USING (true);

-- Allow authenticated users to manage their own configs
CREATE POLICY "Users can manage their own widget configs"
  ON widget_configs
  FOR ALL
  TO authenticated
  USING (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ))
  WITH CHECK (chatbot_id IN (
    SELECT id FROM chatbots WHERE user_id = auth.uid()
  ));

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_widget_configs_updated_at
  BEFORE UPDATE ON widget_configs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();