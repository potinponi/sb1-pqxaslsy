import React from 'react';
import { MessageCircle } from 'lucide-react';

interface WelcomeSectionProps {
  welcomeMessage: string;
  setWelcomeMessage: (message: string) => void;
}

export function WelcomeSection({ welcomeMessage, setWelcomeMessage }: WelcomeSectionProps) {
  return (
    <div className="p-6 bg-dark-700/30 hover:bg-dark-700/60 transition-colors rounded-lg border border-gray-400/10">
      <div className="flex items-center space-x-2 mb-4">
        <MessageCircle className="w-5 h-5 text-brand" />
        <h2 className="text-base font-medium text-gray-100">Welcome Message</h2>
      </div>
      <textarea
        value={welcomeMessage}
        onChange={(e) => setWelcomeMessage(e.target.value)}
        className="w-full px-3 py-2 bg-dark-900 border border-gray-700 rounded-md text-gray-100"
        rows={2}
        placeholder="Enter welcome message"
      />
    </div>
  );
}