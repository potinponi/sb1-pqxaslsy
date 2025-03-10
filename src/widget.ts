import React, { useEffect } from 'react';
import { ChatWidget } from './components/ChatWidget/ChatWidget';
import { createRoot } from 'react-dom/client';
import { supabase } from './lib/supabase';
import type { Theme, Flow } from './types';
import './widget.css';

interface WidgetConfig {
  id: string;
  supabaseUrl: string;
  supabaseKey: string;
}

const init = async ({ id, supabaseUrl, supabaseKey }: WidgetConfig) => {
  // Initialize Supabase client
  const client = supabase.createClient(supabaseUrl, supabaseKey);

  // Fetch widget configuration
  const { data: config, error } = await client
    .from('widget_configs')
    .select('theme, flow')
    .eq('chatbot_id', id)
    .single();

  if (error) {
    console.error('Error fetching widget config:', error);
    return;
  }

  // Add required styles
  const style = document.createElement('style');
  style.textContent = `
    #chatbot-widget-root {
      position: fixed;
      z-index: 9999;
      bottom: 20px;
      right: 20px;
    }
  `;
  document.head.appendChild(style);

  // Create widget container
  const container = document.createElement('div');
  container.id = 'chatbot-widget-root';
  document.body.appendChild(container);

  // Load fonts based on config theme
  const loadFonts = (fontFamily?: string) => {
    if (!fontFamily) return;

    const fonts: Record<string, string> = {
      'Anta': 'https://fonts.googleapis.com/css2?family=Anta&display=swap',
      'Inter': 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap',
      'Roboto': 'https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600&display=swap',
      'Open Sans': 'https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600&display=swap'
    };

    // Extract font name from fontFamily string
    const fontName = fontFamily.replace(/['"]/g, '').split(',')[0].trim();
    
    if (fonts[fontName]) {
      const fontLink = document.createElement('link');
      fontLink.rel = 'stylesheet';
      fontLink.href = fonts[fontName];
      document.head.appendChild(fontLink);
    }
  };

  // Create React root and render widget
  const root = createRoot(container);
  
  // Always load the font before rendering
  const fontFamily = config.theme?.fontFamily || "system-ui, -apple-system, sans-serif";
  loadFonts(fontFamily);
  
  // Apply font family to container
  container.style.fontFamily = fontFamily;

  root.render(
  );

  // Return cleanup function
  return () => {
    root.unmount();
    container.remove();
    style.remove();
  };
};

// Export for UMD build
export const ChatbotWidget = { init };

// Expose to window