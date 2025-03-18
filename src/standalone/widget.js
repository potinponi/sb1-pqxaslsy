/**
 * Chatbot Widget
 * Standalone version showing the complete widget implementation
 */

(function() {
  // Widget API
  window.ChatbotWidget = {
    // Initialize widget with configuration
    init: async ({ id }) => {
      const supabaseUrl = window.chatdashSettings?.url;
      const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppdXlqaG5kaWNtcXhoZXR5eHV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3MDU3NTIsImV4cCI6MjA1NTI4MTc1Mn0.C_LGF4QgRMTtjoYiqU2n9r3SEgigFnX-cvtsyR6HusE';
      
      try {
        if (!id) throw new Error('Chatbot ID is required');
        if (!supabaseUrl) throw new Error('Supabase URL is required');
        
        // Initialize Supabase client
        const supabase = window.supabase.createClient(supabaseUrl, supabaseKey);
        
        // Fetch widget configuration
        const { data: widgetConfig, error } = await supabase
          .from('widget_configs')
          .select('theme, flow')
          .eq('chatbot_id', id)
          .single();

        if (error) throw error;
        if (!widgetConfig) throw new Error('Widget configuration not found');

        // Create widget container with theme data
        const container = document.createElement('div');
        container.id = 'chatbot-widget-root';
        container.dataset.theme = JSON.stringify(widgetConfig.theme);
        document.body.appendChild(container);

        // Initialize React component
        const root = window.ReactDOM.createRoot(container);
        root.render(
          window.React.createElement(ChatWidget, {
            chatbotId: id,
            theme: widgetConfig.theme,
            flow: widgetConfig.flow
          })
        );

        // Initialize proactive messages if enabled
        if (widgetConfig.flow?.proactiveMessages?.enabled) {
          initProactiveMessages();
        }

        // Return cleanup function
        return () => {
          root.unmount();
          container.remove();
        };
      } catch (error) {
        console.error('Failed to initialize widget:', error);
        throw error;
      }
    },

    // Set page context for smart proactive messages
    setPageContext: (context) => {
      window.chatbotContext = {
        url: context.url || window.location.pathname,
        productName: context.productName,
        categoryName: context.categoryName
      };
    }
  };

  function initProactiveMessages() {
    window.addEventListener('load', function() {
      // Extract product/category info from page
      const productName = document.querySelector('h1')?.textContent
        || document.querySelector('meta[property="og:title"]')?.getAttribute('content')
        || document.querySelector('meta[name="title"]')?.getAttribute('content');
      
      const categoryName = document.querySelector('meta[property="og:type"]')?.getAttribute('content')
        || document.querySelector('.category-name')?.textContent;

      // Set initial context
      window.ChatbotWidget.setPageContext({
        url: window.location.pathname,
        productName,
        categoryName
      });
    });
  }

  // Auto-initialize if settings are present
  if (window.chatdashSettings?.chatbot_id) {
    window.ChatbotWidget.init({
      id: window.chatdashSettings.chatbot_id
    });
  }
})();