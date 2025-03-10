/*
  # Add location data to leads table

  1. Changes
    - Add location JSONB column to leads table for storing IP-based location data
    - Add index on location data for better query performance
    
  2. Data Structure
    - location: {
        city: string,
        country: string,
        region: string,
        ip: string
      }
*/

ALTER TABLE leads
ADD COLUMN IF NOT EXISTS location JSONB;

CREATE INDEX IF NOT EXISTS leads_location_city_idx ON leads USING gin ((location->>'city'));
CREATE INDEX IF NOT EXISTS leads_location_country_idx ON leads USING gin ((location->>'country'));