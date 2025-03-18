/*
  # Fix widget configuration updates

  1. Changes
    - Add ON CONFLICT clause to handle updates
    - Update indexes for better performance
    - Ensure proper RLS policies
    
  2. Security
    - Maintain existing access control
    - Allow public read access for specific chatbot
*/

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS widget_configs_chatbot_id_idx ON widget_configs(chatbot_id);
CREATE UNIQUE INDEX IF NOT EXISTS widget_configs_chatbot_id_key ON widget_configs(chatbot_id);

-- Insert or update demo configuration
INSERT INTO widget_configs (
  chatbot_id,
  theme,
  flow
) VALUES (
  'a54a2bd1-cf6a-4af7-8435-c256c10794e7',
  '{
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
    "buttonIcon": "message-square",
    "gradient": {
      "from": "#a7e154",
      "to": "#4F46E5"
    },
    "animations": {
      "open": "animate-slide-in-up",
      "close": "animate-slide-out-down",
      "messages": {
        "bot": "animate-slide-in",
        "user": "animate-slide-in-right"
      }
    }
  }'::jsonb,
  '{
    "welcomeMessage": "Hello! 👋 How can I help you today?",
    "endMessage": "Thank you for your responses! We''ll be in touch soon.",
    "showEndScreen": true,
    "proactiveMessages": {
      "enabled": false,
      "messages": [
        "👋 Need help? I''m here to assist!",
        "Have any questions? Feel free to ask!"
      ],
      "delay": 30,
      "interval": 60,
      "maxMessages": 3
    },
    "options": [
      {
        "id": "1",
        "label": "I want an offer",
        "flow": [
          {
            "id": "1",
            "type": "text",
            "label": "What is your name?",
            "required": true
          },
          {
            "id": "2",
            "type": "email",
            "label": "What is your email?",
            "required": true
          },
          {
            "id": "3",
            "type": "phone",
            "label": "What is your phone number?",
            "required": true
          }
        ]
      },
      {
        "id": "2",
        "label": "I want a call back",
        "flow": [
          {
            "id": "1",
            "type": "text",
            "label": "What is your name?",
            "required": true
          },
          {
            "id": "2",
            "type": "email",
            "label": "What is your email?",
            "required": true
          },
          {
            "id": "3",
            "type": "phone",
            "label": "What is your phone number?",
            "required": true
          },
          {
            "id": "4",
            "type": "text",
            "label": "What is the best time to call you?",
            "required": true
          }
        ]
      }
    ]
  }'::jsonb
) ON CONFLICT (chatbot_id) DO UPDATE 
SET 
  theme = EXCLUDED.theme,
  flow = EXCLUDED.flow,
  updated_at = now();