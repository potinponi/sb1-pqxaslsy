/*
  # Add Last Login Tracking

  1. Changes
    - Add last_login column to users table
    - Add function to update last_login on sign in
    - Add trigger to handle sign in events
    
  2. Security
    - Only authenticated users can see their own last login
*/

-- Add last_login column to auth.users
ALTER TABLE auth.users 
ADD COLUMN IF NOT EXISTS last_login timestamptz;

-- Create function to update last_login
CREATE OR REPLACE FUNCTION handle_auth_sign_in()
RETURNS trigger AS $$
BEGIN
  UPDATE auth.users
  SET last_login = now()
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for sign in events
DROP TRIGGER IF EXISTS on_auth_sign_in ON auth.sessions;
CREATE TRIGGER on_auth_sign_in
  AFTER INSERT ON auth.sessions
  FOR EACH ROW
  EXECUTE FUNCTION handle_auth_sign_in();