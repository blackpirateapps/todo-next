import React, { useState } from 'react';

interface LoginScreenProps {
  onLoginSuccess: () => void;
  isLight: boolean;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({ onLoginSuccess, isLight }) => {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      const res = await fetch('/api/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password }),
      });

      if (res.ok) {
        onLoginSuccess();
      } else {
        const data = await res.json();
        setError(data.error || 'Invalid password');
      }
    } catch {
      setError('Connection error');
    } finally {
      setSubmitting(false);
    }
  };

  const bgClass = isLight ? 'bg-white text-gray-900' : 'bg-black text-gray-200';
  const boxClass = isLight ? 'border-gray-400 bg-gray-50' : 'border-gray-800 bg-gray-950';

  return (
    <div className={`flex flex-col items-center justify-center min-h-screen font-mono p-4 ${bgClass}`}>
      <div className={`w-full max-w-sm border p-6 shadow-lg ${boxClass}`}>
        <div className="text-center mb-6">
          <div className="text-lg font-bold tracking-widest uppercase mb-1">
            [ SYSTEM AUTHENTICATION ]
          </div>
          <p className="text-xs opacity-75">
            Enter password to access todo.txt system
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs uppercase tracking-wider mb-1 font-bold">
              Password:
            </label>
            <div className="flex items-center gap-2 border p-2 bg-transparent">
              <span className={isLight ? 'text-green-600 font-bold' : 'text-green-500 font-bold'}>&gt;</span>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full bg-transparent outline-none font-mono text-sm"
                autoFocus
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
            className={`w-full py-2 text-xs font-bold uppercase border transition-colors ${
              isLight
                ? 'border-gray-400 bg-gray-200 hover:bg-gray-300 text-gray-900'
                : 'border-gray-700 bg-gray-900 hover:bg-gray-800 text-white'
            }`}
          >
            {submitting ? 'Authenticating...' : '[ Authenticate ]'}
          </button>
        </form>
      </div>
    </div>
  );
};
