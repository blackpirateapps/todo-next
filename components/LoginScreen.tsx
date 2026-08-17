import React, { useState, useEffect } from 'react';
import { auth } from '@/lib/firebase';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  getIdToken
} from 'firebase/auth';

interface LoginScreenProps {
  onLoginSuccess: () => void;
  isLight: boolean;
  initialMode?: 'LOGIN' | 'SIGNUP';
  onBackToOnboarding?: () => void;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({
  onLoginSuccess,
  isLight,
  initialMode = 'LOGIN',
  onBackToOnboarding,
}) => {
  const [mode, setMode] = useState<'LOGIN' | 'SIGNUP'>(initialMode);
  const [emailOrUser, setEmailOrUser] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (initialMode) setMode(initialMode);
  }, [initialMode]);

  const resolveEmail = (input: string): string => {
    const trimmed = input.trim();
    if (trimmed.toLowerCase() === 'bpx') {
      return 'hi@sudipx.in';
    }
    if (!trimmed.includes('@')) {
      return `${trimmed}@todo-next.app`;
    }
    return trimmed;
  };

  const handleStandardAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    const targetEmail = resolveEmail(emailOrUser);

    try {
      let userCredential;
      if (mode === 'LOGIN') {
        userCredential = await signInWithEmailAndPassword(auth, targetEmail, password);
      } else {
        userCredential = await createUserWithEmailAndPassword(auth, targetEmail, password);
      }

      const token = await getIdToken(userCredential.user);
      
      // Store session token in server cookie
      await fetch('/api/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token }),
      });

      onLoginSuccess();
    } catch (err: any) {
      const code = err?.code || '';
      if (code === 'auth/user-not-found' || code === 'auth/invalid-credential') {
        setError('Invalid email or password.');
      } else if (code === 'auth/email-already-in-use') {
        setError('Email already registered. Switch to LOGIN.');
      } else if (code === 'auth/weak-password') {
        setError('Password must be at least 6 characters.');
      } else {
        setError(err?.message || 'Authentication failed');
      }
    } finally {
      setSubmitting(false);
    }
  };

  const bgClass = isLight ? 'bg-white text-gray-900' : 'bg-black text-gray-200';
  const boxClass = isLight ? 'border-gray-400 bg-gray-50' : 'border-gray-800 bg-gray-950 shadow-2xl';

  return (
    <div className={`flex flex-col items-center justify-center min-h-screen font-mono p-4 ${bgClass}`}>
      <div className={`w-full max-w-md border p-6 shadow-xl relative ${boxClass}`}>
        {/* Back to Onboarding link */}
        {onBackToOnboarding && (
          <button
            type="button"
            onClick={onBackToOnboarding}
            className="mb-4 text-xs font-bold text-cyan-400 hover:underline flex items-center gap-1 cursor-pointer"
          >
            <span>←</span>
            <span>[ Back to Overview / Features ]</span>
          </button>
        )}

        {/* Terminal Header */}
        <div className="text-center mb-6">
          <div className="text-xs uppercase tracking-widest text-emerald-500 font-bold mb-1">
            [ TODO-NEXT SAAS SYSTEM ]
          </div>
          <p className="text-xs opacity-75">
            {mode === 'LOGIN'
              ? 'Sign in to access your todo.txt workspace'
              : 'Create your free account to get started'}
          </p>
        </div>

        {/* Tab Selector */}
        <div className="flex border-b mb-6 text-xs font-bold">
          <button
            type="button"
            onClick={() => { setMode('LOGIN'); setError(''); }}
            className={`flex-1 py-2 text-center transition-colors cursor-pointer ${
              mode === 'LOGIN'
                ? 'border-b-2 border-emerald-500 text-emerald-500 font-bold'
                : 'opacity-50 hover:opacity-100'
            }`}
          >
            [ LOG IN ]
          </button>
          <button
            type="button"
            onClick={() => { setMode('SIGNUP'); setError(''); }}
            className={`flex-1 py-2 text-center transition-colors cursor-pointer ${
              mode === 'SIGNUP'
                ? 'border-b-2 border-emerald-500 text-emerald-500 font-bold'
                : 'opacity-50 hover:opacity-100'
            }`}
          >
            [ SIGN UP ]
          </button>
        </div>

        {/* Standard Auth Form */}
        <form onSubmit={handleStandardAuth} className="space-y-4">
          <div>
            <label className="block text-xs uppercase tracking-wider mb-1 font-bold">
              Email / Username:
            </label>
            <div className="flex items-center gap-2 border p-2 bg-transparent">
              <span className="text-emerald-500 font-bold">&gt;</span>
              <input
                type="text"
                value={emailOrUser}
                onChange={(e) => setEmailOrUser(e.target.value)}
                placeholder="bpx OR user@example.com"
                className="w-full bg-transparent outline-none font-mono text-sm"
                autoFocus
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-xs uppercase tracking-wider mb-1 font-bold">
              Password:
            </label>
            <div className="flex items-center gap-2 border p-2 bg-transparent">
              <span className="text-emerald-500 font-bold">&gt;</span>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full bg-transparent outline-none font-mono text-sm"
                required
              />
            </div>
          </div>

          {error && (
            <div className="text-xs text-red-500 font-bold text-center">
              [ERROR: {error}]
            </div>
          )}

          <button
            type="submit"
            disabled={submitting}
            className={`w-full py-2.5 text-xs font-bold uppercase border transition-colors cursor-pointer ${
              isLight
                ? 'border-gray-400 bg-gray-200 hover:bg-gray-300 text-gray-900'
                : 'border-emerald-500 bg-emerald-950 hover:bg-emerald-900 text-emerald-400'
            }`}
          >
            {submitting
              ? 'Processing...'
              : mode === 'LOGIN'
              ? '[ Authenticate Workspace ]'
              : '[ Create SaaS Account ]'}
          </button>
        </form>
      </div>
    </div>
  );
};
