// ChatbotWidget UMD bundle
(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('react'), require('react-dom'), require('@supabase/supabase-js')) :
  typeof define === 'function' && define.amd ? define(['exports', 'react', 'react-dom', '@supabase/supabase-js'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.ChatbotWidget = {}, global.React, global.ReactDOM, global.supabase));
})(this, (function (exports, React, ReactDOM, supabase) {
  'use strict';

  // Initialize widget with configuration
  const init = async ({ id }) => {
    try {
      // Create widget container
      const container = document.createElement('div');
      container.id = 'chatbot-widget-root';
      document.body.appendChild(container);

      // Load widget styles
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = '/widget/widget.css';
      document.head.appendChild(link);

      // Initialize widget
      const root = ReactDOM.createRoot(container);
      root.render(React.createElement(ChatWidgetComponent, { chatbotId: id }));

      // Return cleanup function
      return () => {
        root.unmount();
        container.remove();
        link.remove();
      };
    } catch (error) {
      console.error('Failed to initialize widget:', error);
      throw error;
    }
  };

  // Export for UMD build
  exports.init = init;

  // Explicitly expose to window
  if (typeof window !== 'undefined') {
    window.ChatbotWidget = { init };
  }

  Object.defineProperty(exports, '__esModule', { value: true });
}));