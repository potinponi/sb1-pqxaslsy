/*
  # Add location indexes for leads

  1. Changes
    - Add btree indexes for location city and country fields
    - Use proper index type for text search
  
  2. Notes
    - Using btree indexes instead of GIN for text fields
    - Indexes are created only if they don't exist
*/

-- Drop existing indexes if they exist
DROP INDEX IF EXISTS leads_location_city_idx;
DROP INDEX IF EXISTS leads_location_country_idx;

-- Add location column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'location'
  ) THEN
    ALTER TABLE leads ADD COLUMN location JSONB DEFAULT '{}'::jsonb;
  END IF;
END $$;

-- Create btree indexes for text search on location fields
CREATE INDEX IF NOT EXISTS leads_location_city_idx ON leads ((location->>'city'));
CREATE INDEX IF NOT EXISTS leads_location_country_idx ON leads ((location->>'country'));