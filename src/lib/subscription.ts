import { useAuth } from './auth';

export type SubscriptionStatus = 'trial' | 'expired' | 'pro';

interface UseSubscriptionReturn {
  daysRemaining: number;
  status: SubscriptionStatus;
  canAccessFeature: (feature: 'builder' | 'leads' | 'analytics' | 'code') => boolean;
}

export function useSubscription(): UseSubscriptionReturn {
  const { user } = useAuth();

  const getDaysRemaining = (): number => {
    if (!user) return 0;
    
    // Convert UTC timestamp to local date for accurate day calculation
    const trialStart = new Date(user.created_at || Date.now());
    const trialEnd = new Date(trialStart.getTime() + 14 * 24 * 60 * 60 * 1000);
    const now = new Date();
    
    // Calculate days remaining, accounting for partial days
    const millisecondsPerDay = 1000 * 60 * 60 * 24;
    const daysRemaining = (trialEnd.getTime() - now.getTime()) / millisecondsPerDay;
    
    return Math.max(0, Math.floor(daysRemaining));
  };

  const daysRemaining = getDaysRemaining();
  const status: SubscriptionStatus = daysRemaining > 0 ? 'trial' : 'expired';

  const canAccessFeature = (feature: 'builder' | 'leads' | 'analytics' | 'code'): boolean => {
    // During trial period, all features are accessible
    if (status === 'trial') return true;

    // After trial, only basic features are accessible
    if (status === 'expired') {
      return false;
    }

    // Pro users have access to all features
    return true;
  };

  return {
    daysRemaining,
    status,
    canAccessFeature
  };
}