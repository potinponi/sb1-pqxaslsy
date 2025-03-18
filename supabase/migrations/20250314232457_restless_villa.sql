/*
  # Add proactive messages and animations to widget_configs

  1. Changes
    - Add proactive messages configuration to flow
    - Add animation settings to theme
    - Update default values with animation classes
  
  2. Data Structure
    - flow: {
        proactiveMessages: {
          enabled: boolean
          messages: string[]
          delay: number
          interval: number
          maxMessages: number
        }
      }
    - theme: {
        animations: {
          open: string
          close: string
          messages: {
            bot: string
            user: string
          }
        }
      }
*/

-- Update widget_configs default values with animations and proactive messages
ALTER TABLE widget_configs 
ALTER COLUMN theme SET DEFAULT '{
  "primaryColor": "#a7e154",
  "backgroundColor": "#1a1a1a",
  "headerColor": "#232323",
  "messageColor": "#232323",
  "botMessageColor": "#232323",
  "userMessageColor": "#a7e154",
  "inputColor": "#1a1a1a",
  "botTextColor": "#ffffff",
  "userTextColor": "#000000",
  "headerTextColor": "#ffffff",
  "fontFamily": "system-ui",
  "borderRadius": "0.5rem",
  "showMessageIcons": true,
  "animations": {
    "open": "animate-slide-in-up",
    "close": "animate-slide-out-down",
    "messages": {
      "bot": "animate-slide-in",
      "user": "animate-slide-in-right"
    }
  }
}'::jsonb,
ALTER COLUMN flow SET DEFAULT '{
  "welcomeMessage": "Hello! 👋 How can I help you today?",
  "endMessage": "Thank you for your responses! We''ll be in touch soon.",
  "showEndScreen": true,
  "options": [],
  "proactiveMessages": {
    "enabled": false,
    "messages": ["👋 Need help? I''m here to assist!", "Have any questions? Feel free to ask!"],
    "delay": 30,
    "interval": 60,
    "maxMessages": 3
  }
}'::jsonb;

-- Update existing records to include new fields
UPDATE widget_configs
SET theme = theme || '{
  "animations": {
    "open": "animate-slide-in-up",
    "close": "animate-slide-out-down",
    "messages": {
      "bot": "animate-slide-in",
      "user": "animate-slide-in-right"
    }
  }
}'::jsonb
WHERE theme->>'animations' IS NULL;

UPDATE widget_configs
SET flow = flow || '{
  "proactiveMessages": {
    "enabled": false,
    "messages": ["👋 Need help? I''m here to assist!", "Have any questions? Feel free to ask!"],
    "delay": 30,
    "interval": 60,
    "maxMessages": 3
  }
}'::jsonb
WHERE flow->>'proactiveMessages' IS NULL;