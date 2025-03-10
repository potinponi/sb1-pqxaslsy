/*
  # Add phone field to leads table

  1. Changes
    - Add phone column to leads table
    - Make it optional since not all flows collect phone numbers
    - Add index for phone number searches
*/

-- Add phone column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'phone'
  ) THEN
    ALTER TABLE leads ADD COLUMN phone text;
  END IF;
END $$;

-- Create index for phone number searches
CREATE INDEX IF NOT EXISTS leads_phone_idx ON leads(phone);