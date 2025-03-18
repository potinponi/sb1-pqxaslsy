import React, { useEffect } from 'react';
import { ChatWidget } from './components/ChatWidget/ChatWidget';
import { createRoot } from 'react-dom/client';
import { supabase } from './lib/supabase';
import type { Theme, Flow } from './types';
import './widget.css';

// Check if dependencies are loaded
const checkDependencies = () => {
  const missing = [];
  if (typeof React === 'undefined') missing.push('React');
  if (typeof ReactDOM === 'undefined') missing.push('ReactDOM');
  if (typeof supabase === 'undefined') missing.push('@supabase/supabase-js');
  return missing;
};

interface WidgetConfig {
  id: string;
}

const init = async ({ id }: WidgetConfig) => {
  // Check dependencies first
  const missingDeps = checkDependencies();
  if (missingDeps.length > 0) {
    throw new Error(
      `Required dependencies not loaded: ${missingDeps.join(', ')}. ` +
      'Make sure to include these scripts before the widget.'
    );
  }

  // Initialize Supabase client
  try {
    // First fetch Supabase credentials securely
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
    // Rethrow with more helpful message
    throw new Error(
      `Failed to initialize widget: ${error.message}. ` +
      'Check your chatbot ID and make sure the configuration endpoint is accessible.'
    );
  }
};

// Export for UMD build
const ChatbotWidget = { init };
export { ChatbotWidget };

// Explicitly expose to window
if (typeof window !== 'undefined') {
  (window as any).ChatbotWidget = ChatbotWidget;
}