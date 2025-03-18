/*
  # Add Widget Frames Table
  
  1. New Tables
    - `widget_frames`
      - `id` (uuid, primary key)
      - `name` (text) - Name of the frame template
      - `structure` (jsonb) - Core widget structure (sizes, positions, etc)
      - `base_styles` (jsonb) - Base CSS styles and animations
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policy for public read access
    - Add policy for admin management
*/

-- Create widget_frames table
CREATE TABLE widget_frames (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  structure jsonb NOT NULL DEFAULT '{
    "dimensions": {
      "width": "360px",
      "height": "500px",
      "maxWidth": "90vw",
      "maxHeight": "80vh",
      "buttonSize": "48px",
      "headerHeight": "56px",
      "inputHeight": "48px",
      "messageSpacing": "8px",
      "messagePadding": "12px",
      "containerSpacing": "16px"
    },
    "positions": {
      "button": {
        "bottom": "20px",
        "right": "20px"
      },
      "widget": {
        "bottom": "84px",
        "right": "20px"
      }
    },
    "layout": {
      "header": {
        "height": "56px",
        "padding": "16px",
        "titleSize": "16px",
        "closeButtonSize": "20px"
      },
      "messages": {
        "maxWidth": "80%",
        "avatarSize": "32px",
        "spacing": "8px"
      },
      "input": {
        "height": "48px",
        "padding": "8px 16px",
        "buttonSize": "32px"
      }
    },
    "zIndexes": {
      "widget": "9999",
      "overlay": "9998"
    }
  }'::jsonb,
  base_styles jsonb NOT NULL DEFAULT '{
    "animations": {
      "slideInUp": {
        "name": "slideInUp",
        "duration": "0.8s",
        "timing": "cubic-bezier(0.22, 1, 0.36, 1)",
        "keyframes": [
          { "0%": { "opacity": "0", "transform": "scale(0.3) translateY(20px)" } },
          { "40%": { "opacity": "0.8", "transform": "scale(1.02) translateY(-8px)" } },
          { "70%": { "transform": "scale(0.99) translateY(4px)" } },
          { "100%": { "opacity": "1", "transform": "scale(1) translateY(0)" } }
        ]
      },
      "slideOutDown": {
        "name": "slideOutDown",
        "duration": "0.8s",
        "timing": "cubic-bezier(0.4, 0, 0.2, 1)",
        "keyframes": [
          { "0%": { "opacity": "1", "transform": "scale(1) translateY(0)" } },
          { "100%": { "opacity": "0", "transform": "scale(0.3) translateY(16px)" } }
        ]
      },
      "slideInFromLeft": {
        "name": "slideInFromLeft",
        "duration": "0.3s",
        "timing": "ease-out",
        "keyframes": [
          { "0%": { "opacity": "0", "transform": "translateX(-20px)" } },
          { "100%": { "opacity": "1", "transform": "translateX(0)" } }
        ]
      },
      "slideInFromRight": {
        "name": "slideInFromRight",
        "duration": "0.3s",
        "timing": "ease-out",
        "keyframes": [
          { "0%": { "opacity": "0", "transform": "translateX(20px)" } },
          { "100%": { "opacity": "1", "transform": "translateX(0)" } }
        ]
      }
    },
    "baseStyles": {
      "widget": {
        "position": "fixed",
        "display": "flex",
        "flexDirection": "column",
        "borderRadius": "16px",
        "boxShadow": "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)",
        "transition": "transform 0.3s ease-in-out",
        "overflow": "hidden"
      },
      "header": {
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "space-between",
        "borderTopLeftRadius": "16px",
        "borderTopRightRadius": "16px"
      },
      "messagesContainer": {
        "flex": "1",
        "overflowY": "auto",
        "padding": "16px",
        "scrollBehavior": "smooth"
      },
      "message": {
        "display": "flex",
        "alignItems": "flex-start",
        "marginBottom": "8px",
        "maxWidth": "80%"
      },
      "messageContent": {
        "padding": "12px 16px",
        "borderRadius": "12px",
        "fontSize": "14px",
        "lineHeight": "1.5"
      },
      "input": {
        "display": "flex",
        "alignItems": "center",
        "gap": "8px",
        "padding": "16px",
        "borderTop": "1px solid rgba(0, 0, 0, 0.1)"
      },
      "button": {
        "position": "fixed",
        "borderRadius": "50%",
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "center",
        "cursor": "pointer",
        "transition": "transform 0.2s ease-in-out, background-color 0.2s ease-in-out",
        "boxShadow": "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)"
      }
    }
  }'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE widget_frames ENABLE ROW LEVEL SECURITY;

-- Create index
CREATE INDEX widget_frames_name_idx ON widget_frames(name);

-- Create updated_at trigger
CREATE TRIGGER update_widget_frames_updated_at
  BEFORE UPDATE ON widget_frames
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add RLS policies
CREATE POLICY "Allow public to read widget frames"
  ON widget_frames
  FOR SELECT
  TO public
  USING (true);

-- Insert default frame
INSERT INTO widget_frames (name)
VALUES ('default')
ON CONFLICT (id) DO NOTHING;