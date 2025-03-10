/*
  # Add location data to leads table

  1. Changes
    - Add location JSONB column to leads table for storing IP-based location data
    - Add btree indexes on location data for efficient text searches
    
  2. Data Structure
    - location: {
        city: string,
        country: string,
        region: string,
        ip: string
      }
*/

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