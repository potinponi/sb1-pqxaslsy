import React, { useState, useEffect } from 'react';
import { Copy, Check } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../lib/auth';

export function CodeSnippet() {
  const [copied, setCopied] = useState<'main' | 'smart' | 'theme' | null>(null);
  const location = useLocation();
  const navigate = useNavigate();
  const { user } = useAuth();
  const chatbotId = user?.id;
  const { flow, theme, chatbotName } = location.state || {};
  const widgetUrl = 'https://chatdash.netlify.app/widget/chatbot.umd.js';
  const widgetCssUrl = 'https://chatdash.netlify.app/widget/styles.css';
  const supabaseUrl = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/dist/umd/supabase.min.js';

  const smartProactiveScript = `<!-- Add this script after the widget initialization -->
<script>
  window.addEventListener('load', function() {
    // Extract product information
    const productName = document.querySelector('h1')?.textContent
      || document.querySelector('meta[property="og:title"]')?.getAttribute('content')
      || document.querySelector('meta[name="title"]')?.getAttribute('content');
    
    const categoryName = document.querySelector('meta[property="og:type"]')?.getAttribute('content')
      || document.querySelector('.category-name')?.textContent;

    // Send to chat widget
    window.ChatbotWidget?.setPageContext({
      url: window.location.pathname,
      productName,
      categoryName
    });
  });
</script>`;

  const themeExample = `{
  primaryColor: "#a7e154",
  backgroundColor: "#1a1a1a",
  headerColor: "#232323",
  messageColor: "#232323",
  inputColor: "#1a1a1a",
  fontFamily: "Inter, system-ui",
  borderRadius: "0.5rem",
  gradient: {
    from: "#a7e154",
    to: "#4F46E5"
  }
}`;

  useEffect(() => {
    if (!flow || !chatbotId) {
      navigate('/builder');
    }
  }, [flow, chatbotId, navigate]);

  const snippet = `<!-- Add the chatbot widget to your website -->
<link rel="stylesheet" href="${widgetCssUrl}" />

<!-- Required dependencies (load these before the widget) -->
<script src="https://unpkg.com/react@18.3.1/umd/react.production.min.js"></script>
<script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js"></script>
<script src="${supabaseUrl}"></script>

<!-- Chatbot widget script -->
<script src="${widgetUrl}"></script>

<!-- Initialize the widget -->
<script>
  window.addEventListener('load', function() {
    // Initialize the widget with your configuration
    window.ChatbotWidget.init({
      id: '${chatbotId}'
    });

    // Optional: Set page context for smart proactive messages
    window.ChatbotWidget.setPageContext({
      url: window.location.pathname,
      productName: document.querySelector('h1')?.textContent,
      categoryName: document.querySelector('meta[property="og:type"]')?.getAttribute('content')
    });
  });
</script>`;

  const handleCopy = () => {
    navigator.clipboard.writeText(snippet);
    setCopied('main');
    setTimeout(() => setCopied(null), 2000);
  };

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold text-gray-100 mb-6">Installation</h1>
      
      <div className="bg-dark-800 rounded-lg shadow-lg border border-gray-800 overflow-hidden">
        <div className="p-4 border-b border-gray-800 flex justify-between items-center">
          <h2 className="text-lg font-medium text-gray-100">Add to your website</h2>
          <button 
            onClick={handleCopy}
            className="flex items-center space-x-2 px-3 py-1.5 bg-brand text-black rounded-md 
              hover:bg-brand/90 transition-colors"
          >
            {copied === 'main' ? (
              <>
                <Check className="w-4 h-4" />
                <span>Copied!</span>
              </>
            ) : (
              <>
                <Copy className="w-4 h-4" />
                <span>Copy code</span>
              </>
            )}
          </button>
        </div>
        
        <div className="p-4 bg-dark-900">
          <pre className="text-gray-300 font-mono text-sm whitespace-pre-wrap overflow-x-auto">
            {snippet}
          </pre>
        </div>
      </div>

      <div className="mt-8 space-y-4">
        <h2 className="text-xl font-medium text-gray-100">Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-300">
          <li>Copy the entire widget code snippet</li>
          <li>Add the stylesheet link to your HTML <code>&lt;head&gt;</code> section</li>
          <li>Add the required dependencies and widget script just before the closing <code>&lt;/body&gt;</code> tag</li>
          <li>The chat widget will automatically appear in the bottom right corner</li>
          <li>Customize the theme settings to match your website's design</li>
        </ol>
        
        {/* Smart Proactive Messages Setup */}
        <div className="p-4 bg-dark-700 rounded-lg border border-gray-800 mt-8">
          <h3 className="text-lg font-medium text-gray-100 mb-4">Smart Proactive Messages Setup</h3>
          <div className="bg-dark-900 rounded-lg overflow-hidden mb-4">
            <div className="px-4 py-3 border-b border-gray-800 flex justify-between items-center">
              <p className="text-sm text-gray-400">Add this script after the widget initialization</p>
              <button 
                onClick={() => {
                  navigator.clipboard.writeText(smartProactiveScript);
                  setCopied('smart');
                  setTimeout(() => setCopied(null), 2000);
                }}
                className="flex items-center space-x-2 px-3 py-1.5 bg-brand text-black rounded-md 
                  hover:bg-brand/90 transition-colors"
              >
                {copied === 'smart' ? (
                  <>
                    <Check className="w-4 h-4" />
                    <span>Copied!</span>
                  </>
                ) : (
                  <>
                    <Copy className="w-4 h-4" />
                    <span>Copy code</span>
                  </>
                )}
              </button>
            </div>
            <div className="p-4">
            <pre className="text-sm text-gray-300 whitespace-pre-wrap overflow-x-auto">
{`<!-- Add this script after the widget initialization -->
<script>
  window.addEventListener('load', function() {
    // Extract product information
    const productName = document.querySelector('h1')?.textContent
      || document.querySelector('meta[property="og:title"]')?.getAttribute('content')
      || document.querySelector('meta[name="title"]')?.getAttribute('content');
    
    const categoryName = document.querySelector('meta[property="og:type"]')?.getAttribute('content')
      || document.querySelector('.category-name')?.textContent;

    // Send to chat widget
    window.ChatbotWidget?.setPageContext({
      url: window.location.pathname,
      productName,
      categoryName
    });
  });
</script>`}
            </pre>
          </div>
          </div>
          <div className="space-y-2 text-gray-300">
            <p className="text-sm font-medium">This script will:</p>
            <ul className="list-disc list-inside space-y-1 text-sm">
              <li>Detect product names from page headings or meta tags</li>
              <li>Identify category information from meta tags or page elements</li>
              <li>Automatically trigger relevant proactive messages based on the context</li>
            </ul>
          </div>
        </div>
        
        <div className="p-4 bg-dark-700 rounded-lg border border-gray-800 mt-4">
          <h3 className="text-lg font-medium text-gray-100 mb-2">Important Notes</h3>
          <ul className="space-y-2 text-gray-300">
            <li>• Lightweight and optimized</li>
            <li>• Requires React, ReactDOM, and Supabase</li>
            <li>• Automatically syncs with your chatbot configuration</li>
            <li>• Smart proactive messages support</li>
            <li>• Real-time lead capture</li>
            <li>• Feedback collection</li>
            <li>• Loads asynchronously</li>
            <li>• Works offline-first with data sync</li>
            <li>• Compatible with all modern browsers</li>
            <li>• No jQuery required</li>
            <li>• Served from Netlify's global CDN</li>
            <li>• Automatic error handling and retries</li>
            <li>• Customizable appearance and behavior</li>
            <li>• Mobile-responsive design</li>
          </ul>
        </div>
        
        <div className="p-4 bg-dark-800 rounded-lg border border-gray-800 mt-4">
          <h3 className="text-lg font-medium text-gray-100 mb-2">Theme Options</h3>
          <p className="text-sm text-gray-400 mb-4">
            Customize these options in the widget initialization script to match your website's design.
          </p>
          <ul className="space-y-2 text-gray-300">
            <li><code>primaryColor</code>: Main color for buttons and accents (e.g., "#a7e154")</li>
            <li><code>backgroundColor</code>: Chat window background color (e.g., "#1a1a1a")</li>
            <li><code>gradient</code>: Optional gradient for buttons (e.g., "from: #a7e154, to: #4F46E5")</li>
            <li><code>fontFamily</code>: Custom font family (e.g., "Inter, system-ui")</li>
            <li><code>borderRadius</code>: Corner roundness (e.g., "0.5rem" or "9999px")</li>
            <li><code>headerColor</code>: Header background color (e.g., "#232323")</li>
            <li><code>messageColor</code>: Message bubble color (e.g., "#232323")</li>
            <li><code>inputColor</code>: Input field background color (e.g., "#1a1a1a")</li>
            <li><code>botMessageColor</code>: Bot message bubble color</li>
            <li><code>userMessageColor</code>: User message bubble color</li>
            <li><code>botTextColor</code>: Bot message text color</li>
            <li><code>userTextColor</code>: User message text color</li>
            <li><code>headerTextColor</code>: Header text color</li>
            <li><code>showMessageIcons</code>: Show/hide message icons</li>
            <li><code>botIcon</code>: Custom bot icon URL</li>
            <li><code>userIcon</code>: Custom user icon URL</li>
          </ul>
          
          <div className="mt-4 p-4 bg-dark-900 rounded border border-gray-700">
            <div className="flex justify-between items-center mb-4">
              <h4 className="text-sm font-medium text-gray-400">Example Theme Configuration</h4>
              <button 
                onClick={() => {
                  navigator.clipboard.writeText(themeExample);
                  setCopied('theme');
                  setTimeout(() => setCopied(null), 2000);
                }}
                className="flex items-center space-x-2 px-3 py-1.5 bg-brand text-black rounded-md 
                  hover:bg-brand/90 transition-colors text-sm"
              >
                {copied === 'theme' ? (
                  <>
                    <Check className="w-4 h-4" />
                    <span>Copied!</span>
                  </>
                ) : (
                  <>
                    <Copy className="w-4 h-4" />
                    <span>Copy example</span>
                  </>
                )}
              </button>
            </div>
            <pre className="text-sm text-gray-300 whitespace-pre-wrap">
{`{
  primaryColor: "#a7e154",
  backgroundColor: "#1a1a1a",
  headerColor: "#232323",
  messageColor: "#232323",
  inputColor: "#1a1a1a",
  fontFamily: "Inter, system-ui",
  borderRadius: "0.5rem",
  gradient: {
    from: "#a7e154",
    to: "#4F46E5"
  }
}`}
            </pre>
          </div>
        </div>
        
        <div className="p-4 bg-dark-700 rounded-lg border border-gray-800 mt-4">
          <h3 className="text-lg font-medium text-gray-100 mb-2">Troubleshooting</h3>
          <ul className="space-y-2 text-gray-300">
            <li>• Make sure both the CSS and JS files are loading correctly (check browser console)</li>
            <li>• Verify the script is placed before the closing body tag</li>
            <li>• Ensure your theme configuration uses valid color values</li>
            <li>• Check that the chatbot ID matches your configuration</li>
            <li>• For CORS issues, ensure your domain is allowed to access the widget</li>
          </ul>
        </div>
      </div>
    </div>
  );
}