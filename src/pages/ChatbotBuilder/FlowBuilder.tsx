import React from 'react';
import { FlowEditor } from '../../components/ChatbotBuilder/FlowEditor/FlowEditor';
import { Preview } from '../../components/ChatbotBuilder/Preview';
import type { Theme, Option, Question } from '../../types';

interface ProactiveMessages {
  enabled: boolean;
  messages: string[];
  delay: number;
  interval: number;
  maxMessages: number;
}

interface FlowBuilderProps {
  welcomeMessage: string;
  setWelcomeMessage: (message: string) => void;
  endMessage: string;
  setEndMessage: (message: string) => void;
  proactiveMessages: ProactiveMessages;
  setProactiveMessages: (messages: ProactiveMessages) => void;
  showEndScreen: boolean;
  setShowEndScreen: (show: boolean) => void;
  options: Option[];
  setOptions: (options: Option[]) => void;
  theme: Theme;
  chatbotName: string;
}

export function FlowBuilder({
  welcomeMessage,
  setWelcomeMessage,
  endMessage,
  setEndMessage,
  showEndScreen,
  setShowEndScreen,
  proactiveMessages,
  setProactiveMessages,
  options,
  setOptions,
  theme,
  chatbotName
}: FlowBuilderProps) {
  return (
    <div className="flex flex-col lg:flex-row gap-8 pt-16 pl-24">
      <div className="w-full lg:w-[600px] lg:flex-shrink-0">
        <FlowEditor
          welcomeMessage={welcomeMessage}
          setWelcomeMessage={setWelcomeMessage}
          endMessage={endMessage}
          setEndMessage={setEndMessage}
          showEndScreen={showEndScreen}
          setShowEndScreen={setShowEndScreen}
          proactiveMessages={proactiveMessages}
          setProactiveMessages={setProactiveMessages}
          options={options}
          setOptions={setOptions}
        />
      </div>
      <div className="w-full lg:flex-1 lg:flex lg:justify-center">
        <Preview
          chatbotId="00000000-0000-0000-0000-000000000000"
          chatbotName={chatbotName}
          previewFlow={{
            welcomeMessage,
            endMessage,
            showEndScreen,
            proactiveMessages,
            options
          }}
          theme={theme}
        />
      </div>
    </div>
  );
}