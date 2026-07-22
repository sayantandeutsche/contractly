import React, { createContext, useCallback, useContext, useEffect, useState } from 'react';
import { authApi } from '../api/client';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [status, setStatus] = useState('loading'); // loading | authenticated | unauthenticated

  useEffect(() => {
    authApi.me()
      .then(u => { setUser(u); setStatus('authenticated'); })
      .catch(() => { setUser(null); setStatus('unauthenticated'); });
  }, []);

  const signup = useCallback(async (data) => {
    const u = await authApi.signup(data);
    setUser(u); setStatus('authenticated');
    return u;
  }, []);

  const login = useCallback(async (data) => {
    const u = await authApi.login(data);
    setUser(u); setStatus('authenticated');
    return u;
  }, []);

  const loginWithGoogle = useCallback(async (idToken) => {
    const u = await authApi.loginWithGoogle(idToken);
    setUser(u); setStatus('authenticated');
    return u;
  }, []);

  const logout = useCallback(async () => {
    try { await authApi.logout(); } finally {
      setUser(null); setStatus('unauthenticated');
    }
  }, []);

  return (
    <AuthContext.Provider value={{ user, status, signup, login, loginWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider');
  return ctx;
}
