import React from 'react';
import { MessageCircle } from 'lucide-react';

interface EndMessageSectionProps {
  endMessage: string;
  setEndMessage: (message: string) => void;
  showEndScreen: boolean;
  setShowEndScreen: (show: boolean) => void;
}

export function EndMessageSection({ 
  endMessage, 
  setEndMessage,
  showEndScreen,
  setShowEndScreen
}: EndMessageSectionProps) {
  return (
    <div className="p-6 bg-dark-700/30 hover:bg-dark-700/60 transition-colors rounded-lg border border-gray-800">
      <div className="flex items-center space-x-2 mb-4">
        <MessageCircle className="w-5 h-5 text-brand" />
        <h2 className="text-base font-medium text-gray-100">End Message</h2>
      </div>
      <div className="mb-4">
        <label className="flex items-center space-x-2">
          <input
            type="checkbox"
            checked={showEndScreen}
            onChange={(e) => setShowEndScreen(e.target.checked)}
            className="rounded border-gray-700 bg-dark-900 text-brand"
          />
          <span className="text-sm text-gray-400">Show end screen with feedback</span>
        </label>
      </div>
      <textarea
        value={endMessage}
        onChange={(e) => setEndMessage(e.target.value)}
        className="w-full px-3 py-2 bg-dark-900 border border-gray-700 rounded-md text-gray-100"
        rows={2}
        placeholder="Enter end message"
      />
    </div>
  );
}