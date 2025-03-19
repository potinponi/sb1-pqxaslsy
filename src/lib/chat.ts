import { useState } from 'react';
import { supabase } from './supabase';
import { useAuth } from './auth';
import type { Message, Flow, Lead } from '../types';

export function useChat(chatbotId: string) {
  const { user } = useAuth();
  const [messages, setMessages] = useState<Message[]>([]);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(-1);
  const [flow, setFlow] = useState<Flow | null>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [completed, setCompleted] = useState(false);
  const [showEndScreen, setShowEndScreen] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const [answers, setAnswers] = useState<Record<string, string>>({});

  const validateFlow = (flowData: Flow | null) => {
    if (!flowData) return false;
    if (!flowData.data) return false;
    if (!flowData.data.welcomeMessage) return false;
    if (!flowData.data.endMessage) return false;
    if (!Array.isArray(flowData.data.options)) return false;
    if (flowData.data.options.length === 0) return false;
    return true;
  };

  const simulateTyping = async () => {
    setIsTyping(true);
    await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 1000));
    setIsTyping(false);
  };

  const fetchFlow = async () => {
    try {
      const { data, error } = await supabase
        .from('flows')
        .select('*')
        .eq('chatbot_id', chatbotId)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (error) throw error;
      
      if (!validateFlow(data)) {
        throw new Error('Invalid flow configuration');
      }

      setFlow(data);
      // Show welcome message and initial options prompt
      setMessages([
        {
          id: 'welcome',
          content: data?.data.welcomeMessage || 'Hello! 👋 How can I help you today?',
          sender: 'bot'
        }
      ]);

    } catch (error) {
      console.error('Error fetching flow:', error);
    }
  };

  const submitLead = async (answers: Record<string, string>, fetchLocation: () => Promise<any>) => {
    setSubmitting(true);
    try {
      const selectedOptionData = flow?.data.options?.find(opt => opt.id === selectedOption);
      const locationData = await fetchLocation();
      
      const processAnswers = () => {
        const result = {
          name: 'Anonymous',
          email: 'no-email@example.com',
          phone: undefined as string | undefined
        };
        
        // Get all questions with their types
        const questions = selectedOptionData?.flow || [];
        
        // Process answers in order
        for (const question of questions) {
          const answer = answers[question.label]?.trim();
          if (!answer) continue;
          
          switch (question.type) {
            case 'name':
            case 'text': // For backward compatibility
              if (result.name === 'Anonymous') {
                result.name = answer;
              }
              break;
            case 'email':
              result.email = answer;
              break;
            case 'phone':
              result.phone = answer;
              break;
          }
        }
        
        return result;
      };

      const { name, email, phone } = processAnswers();

      // Ensure we have all required answers
      const requiredQuestions = selectedOptionData?.flow.filter(q => q.required) || [];
      const missingRequired = requiredQuestions.some(q => !answers[q.label]);
      
      if (missingRequired) {
        throw new Error('Please answer all required questions');
      }

      const lead: Partial<Lead> = {
        chatbot_id: chatbotId,
        name,
        email,
        phone,
        location: locationData,
        answers
      };

      const { error } = await supabase.from('leads').insert(lead);
      if (error) throw error;

      // Set completed state first
      setCompleted(true);
      setSubmitting(false);

      // Add completion message
      setMessages(prev => [
        ...prev,
        {
          id: 'completion',
          content: flow?.data.endMessage || 'Thank you for your responses! We\'ll be in touch soon.',
          sender: 'bot'
        }
      ]);
      
      // Show end screen if enabled in flow configuration
      setTimeout(() => {
        if (flow?.data?.showEndScreen) {
          setShowEndScreen(true);
        }
      }, 1000);
    } catch (error) {
      console.error('Error saving lead:', error);
      setMessages(prev => [
        ...prev,
        {
          id: 'error',
          content: 'Sorry, there was an error saving your responses. Please try again.',
          sender: 'bot'
        }
      ]);
    } finally {
      setSubmitting(false);
    }
  };

  return {
    messages,
    setMessages,
    selectedOption,
    setSelectedOption,
    currentQuestionIndex,
    setCurrentQuestionIndex,
    flow,
    setFlow,
    loading,
    setLoading,
    submitting,
    completed,
    setCompleted,
    showEndScreen,
    setShowEndScreen,
    isTyping,
    answers,
    setAnswers,
    validateFlow,
    simulateTyping,
    submitLead
  };
}