import { createContext, useContext, useEffect, useState } from 'react';
import { supabase } from './supabase';
import type { User, AuthError } from '@supabase/supabase-js';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  error: AuthError | null;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<AuthError | null>(null);

  useEffect(() => {
    let mounted = true;

    if (!supabase) {
      console.warn('Supabase client not initialized');
      setError(new Error('Supabase client not initialized'));
      setLoading(false);
      return;
    }

    async function getInitialSession() {
      try {
        setLoading(true);
        const { data: { session }, error: sessionError } = await supabase.auth.getSession();
        
        if (mounted) {
          if (sessionError) {
            console.error('Session error:', sessionError);
            console.error('Session error:', sessionError);
            throw sessionError;
          }
          console.info('Auth state:', session ? 'Authenticated' : 'Not authenticated');
          setUser(session?.user ?? null);
          setError(null);
        }
      } catch (err) {
        if (mounted) {
          console.error('Auth error:', err);
          setError(err instanceof Error ? err : new Error('Authentication failed'));
          setUser(null);
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    }

    getInitialSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.info('Auth state change:', event, session ? 'Authenticated' : 'Not authenticated');
      if (mounted) {
        setUser(session?.user ?? null);
        setError(null);
      }
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const signIn = async (email: string, password: string) => {
    setError(null);
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      setError(error);
      throw error;
    }
  };

  const signOut = async () => {
    setError(null);
    const { error } = await supabase.auth.signOut();
    if (error) {
      setError(error);
      throw error;
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, error, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}