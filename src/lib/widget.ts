import type { Theme, Flow } from '../types';

export function generateWidgetBundle(chatbotId: string, theme: Theme, flow: Flow): string {
  // Generate CSS as a string that will be injected
  const css = `
    #chatbot-widget-root {
      --primary-color: ${theme.primaryColor};
      --bg-color: ${theme.backgroundColor};
      --header-color: ${theme.headerColor};
      --message-color: ${theme.messageColor};
      --input-color: ${theme.inputColor};
      --bot-message-color: ${theme.botMessageColor};
      --user-message-color: ${theme.userMessageColor};
      --bot-text-color: ${theme.botTextColor};
      --user-text-color: ${theme.userTextColor};
      --header-text-color: ${theme.headerTextColor};
      --border-radius: ${theme.borderRadius};
      font-family: ${theme.fontFamily};
      line-height: 1.5;
      -webkit-text-size-adjust: 100%;
      position: fixed;
      z-index: 9999;
      bottom: 20px;
      right: 20px;
    }
    .animate-slide-in-up {
      animation: slideInUp 0.8s cubic-bezier(0.22, 1, 0.36, 1) forwards;
    }

    .animate-slide-out-down {
      animation: slideOutDown 0.8s cubic-bezier(0.4, 0, 0.2, 1) forwards;
    }

    .animate-slide-in {
      animation: slideInFromLeft 0.3s ease-out forwards;
    }

    .animate-slide-in-right {
      animation: slideInFromRight 0.3s ease-out forwards;
    }

    @keyframes slideInUp {
      0% { opacity: 0; transform: scale(0.3) translateY(20px); }
      40% { opacity: 0.8; transform: scale(1.02) translateY(-8px); }
      70% { transform: scale(0.99) translateY(4px); }
      100% { opacity: 1; transform: scale(1) translateY(0); }
    }

    @keyframes slideOutDown {
      0% { opacity: 1; transform: scale(1) translateY(0); }
      100% { opacity: 0; transform: scale(0.3) translateY(16px); }
    }

    @keyframes slideInFromLeft {
      0% { opacity: 0; transform: translateX(-20px); }
      100% { opacity: 1; transform: translateX(0); }
    }

    @keyframes slideInFromRight {
      0% { opacity: 0; transform: translateX(20px); }
      100% { opacity: 1; transform: translateX(0); }
    }
  `;

  return `
(function() {
  // Configuration
  const CHATBOT_ID = '${chatbotId}';
  let config = null;

  // Load required dependencies
  async function loadDependencies() {
    const deps = [
      { name: 'React', url: 'https://unpkg.com/react@18.2.0/umd/react.production.min.js' },
      { name: 'ReactDOM', url: 'https://unpkg.com/react-dom@18.2.0/umd/react-dom.production.min.js' },
      { name: 'Supabase', url: 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.39.7/dist/umd/supabase.min.js' }
    ];

    for (const dep of deps) {
      if (!window[dep.name]) {
        await new Promise((resolve, reject) => {
          const script = document.createElement('script');
          script.src = dep.url;
          script.crossOrigin = 'anonymous';
          script.onload = resolve;
          script.onerror = reject;
          document.head.appendChild(script);
        });
      }
    }
  }

  // Fetch configuration from secure endpoint
  async function fetchConfig() {
    try {
      const supabaseUrl = 'https://ziuyjhndicmqxhetyxux.supabase.co';
      const supabaseKey = config?.supabaseKey;
      
      if (!supabaseKey) {
        throw new Error('Supabase configuration is required');
      }
      
      return { supabaseUrl, supabaseKey };
    } catch (error) {
      console.error('Failed to fetch widget configuration:', error);
      throw error;
    }
  }

  // Initialize widget
  async function initWidget() {
    try {
      await loadDependencies();
      // Get Supabase configuration
      const { supabaseUrl, supabaseKey } = await fetchConfig();
      const supabase = createClient(supabaseUrl, supabaseKey);

      // Fetch widget configuration
      const { data: widgetConfig, error } = await supabase
        .from('widget_configs')
        .select('theme, flow')
        .eq('chatbot_id', CHATBOT_ID)
        .single();

      if (error) throw error;
      if (!widgetConfig) throw new Error('Widget configuration not found');
      
      // Add styles
      const style = document.createElement('style');
      style.textContent = ${JSON.stringify(css)};
      document.head.appendChild(style);

      // Create widget container
      const container = document.createElement('div');
      container.id = 'chatbot-widget-root';
      document.body.appendChild(container);

      // Initialize React component
      const root = window.ReactDOM.createRoot(container);
      root.render(
        React.createElement(ChatWidget, {
          chatbotId: CHATBOT_ID,
          theme: widgetConfig.theme,
          flow: widgetConfig.flow
        })
      );

      return () => {
        root.unmount();
        container.remove();
        style.remove();
      };
    } catch (error) {
      console.error('Failed to initialize widget:', error);
    }
  }

  // Initialize on page load
  const init = async ({ id, supabaseUrl, supabaseKey }) => {
    if (!id) throw new Error('Chatbot ID is required');

    // If Supabase credentials not provided, fetch from API
    if (!supabaseUrl || !supabaseKey) {
      try {
        let cleanup = null;
        const initialize = async () => {
          cleanup = await initWidget();

          // Initialize page context if proactive messages are enabled
          if (widgetConfig?.flow?.proactiveMessages?.enabled) {
            window.addEventListener('load', function() {
              const productName = document.querySelector('h1')?.textContent
                || document.querySelector('meta[property="og:title"]')?.getAttribute('content')
                || document.querySelector('meta[name="title"]')?.getAttribute('content');
              
              const categoryName = document.querySelector('meta[property="og:type"]')?.getAttribute('content')
                || document.querySelector('.category-name')?.textContent;

              window.ChatbotWidget?.setPageContext({
                url: window.location.pathname,
                productName,
                categoryName
              });
            });
          }
        };
        initialize();
        return () => cleanup?.();
      }
    }
  };
  
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();`
}