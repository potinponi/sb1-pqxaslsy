import React, { useEffect } from 'react';
import { ChatWidget } from './components/ChatWidget/ChatWidget';
import { createRoot } from 'react-dom/client';
import { supabase } from './lib/supabase';
import type { Theme, Flow } from './types';
import './widget.css';

export interface WidgetConfig {
  id: string;
}

const init = async ({ id }: WidgetConfig) => {
  // Initialize Supabase client
  try {
    // Fetch configuration from secure endpoint
    const response = await fetch(`https://chatdash.netlify.app/api/config/${id}`);
    if (!response.ok) {
      throw new Error('Failed to fetch configuration');
    }
    
    const config = await response.json();
    if (!config.supabaseUrl) {
      throw new Error('Invalid configuration');
    }
    
    const client = supabase.createClient(config.supabaseUrl, config.supabaseKey);
    
    // Fetch widget configuration
    const { data: widgetConfig, error } = await client
      .from('widget_configs')
      .select('theme, flow')
      .eq('chatbot_id', id)
      .single();

    if (error) {
      throw error;
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
    const fontFamily = widgetConfig?.theme?.fontFamily || "system-ui, -apple-system, sans-serif";
    loadFonts(fontFamily);
    
    // Apply font family to container
    container.style.fontFamily = fontFamily;

    root.render(
      <ChatWidget
        chatbotId={id}
        theme={widgetConfig?.theme}
        previewFlow={widgetConfig?.flow}
      />
    );

    // Return cleanup function
    return () => {
      root.unmount();
      container.remove();
      style.remove();
    };
  } catch (error) {
    console.error('Failed to initialize widget:', error);
    throw error;
  }
};

// Export for UMD build
export const ChatbotWidget = { init };

// Expose to window