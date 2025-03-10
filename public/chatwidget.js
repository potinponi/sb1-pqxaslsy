// Chatbot Widget Loader
(function() {
  // Initialize empty config object
  const config = {};

  // Load required dependencies
  function loadScript(src, callback) {
    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = callback;
    document.body.appendChild(script);
  }

  function loadStylesheet(href) {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
  }

  // Initialize widget after all dependencies are loaded
  function initWidget() {
    if (window.ChatbotWidget) {
      window.ChatbotWidget.init(config);
    }
  }

  // Load dependencies in the correct order
  function loadDependencies() {
    // Load React first
    loadScript('https://unpkg.com/react@18/umd/react.production.min.js', () => {
      // Then load ReactDOM
      loadScript('https://unpkg.com/react-dom@18/umd/react-dom.production.min.js', () => {
        // Then load Supabase
        loadScript('https://unpkg.com/@supabase/supabase-js@2/dist/umd/supabase.min.js', () => {
          // Finally load the widget
          loadScript('/widget/chatbot.umd.js', initWidget);
        });
      });
    });

    // Load widget styles
    loadStylesheet('/widget/styles.css');
  }

  // Start loading when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadDependencies);
  } else {
    loadDependencies();
  }

  // Expose configuration function
  window.ChatbotWidgetConfig = function(customConfig) {
    Object.assign(config, customConfig);
    
    // If widget is already initialized, update its configuration
    if (window.ChatbotWidget?.instance) {
      window.ChatbotWidget.instance.updateConfig(config);
    }
  };

  // Expose page context function for smart proactive messages
  window.ChatbotWidget = window.ChatbotWidget || {};
  window.ChatbotWidget.setPageContext = function(context) {
    if (window.ChatbotWidget.instance) {
      window.ChatbotWidget.instance.setPageContext(context);
    }
  };

  // Expose theme update function
  window.ChatbotWidget.updateTheme = function(theme) {
    if (window.ChatbotWidget.instance) {
      window.ChatbotWidget.instance.updateTheme(theme);
    }
  };
})();