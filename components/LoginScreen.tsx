import React, { useState } from 'react';
import { auth } from '@/lib/firebase';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  getIdToken
} from 'firebase/auth';

interface LoginScreenProps {
  onLoginSuccess: () => void;
  isLight: boolean;
  isBpxMigrated?: boolean;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({ onLoginSuccess, isLight, isBpxMigrated = false }) => {
  const [mode, setMode] = useState<'LOGIN' | 'SIGNUP'>('LOGIN');
  const [emailOrUser, setEmailOrUser] = useState('');
  const [password, setPassword] = useState('');
  
  // Legacy bpx Migration States
  const [isBpxFlow, setIsBpxFlow] = useState(false);
  const [bpxStep, setBpxStep] = useState<1 | 2>(1); // 1: Legacy APP_PASSWORD, 2: Set New Password
  const [legacyPassword, setLegacyPassword] = useState('');
  const [newBpxPassword, setNewBpxPassword] = useState('');

  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

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

    const targetEmail = resolveEmail(emailOrUser);
    const isBpxAccount = targetEmail.toLowerCase() === 'hi@sudipx.in' || emailOrUser.trim().toLowerCase() === 'bpx';

    // If attempting bpx login/signup for the first time and bpx is not yet migrated
    if (isBpxAccount && !isBpxMigrated && !isBpxFlow) {
      setIsBpxFlow(true);
      setBpxStep(1);
      return;
    }

    setSubmitting(true);

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
        setError('Invalid credentials. If this is your first time as bpx, click below to migrate.');
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

  const handleVerifyLegacyPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      const res = await fetch('/api/auth/legacy-verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: legacyPassword }),
      });

      if (res.ok) {
        setBpxStep(2);
      } else {
        const data = await res.json();
        setError(data.error || 'Incorrect legacy system environment password');
      }
    } catch {
      setError('Connection error verifying legacy password');
    } finally {
      setSubmitting(false);
    }
  };

  const handleCompleteBpxMigration = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);

    const bpxEmail = 'hi@sudipx.in';

    try {
      let userCredential;
      try {
        // Try creating new Firebase account for bpx
        userCredential = await createUserWithEmailAndPassword(auth, bpxEmail, newBpxPassword);
      } catch (fbErr: any) {
        if (fbErr?.code === 'auth/email-already-in-use') {
          // Fallback sign-in if Firebase user already created
          userCredential = await signInWithEmailAndPassword(auth, bpxEmail, newBpxPassword);
        } else {
          throw fbErr;
        }
      }

      const token = await getIdToken(userCredential.user);

      // Call migration endpoint to link existing tasks & templates to bpx Firebase UID
      const migRes = await fetch('/api/auth/migrate-bpx', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          legacyPassword,
          userId: userCredential.user.uid,
          email: bpxEmail,
          token
        }),
      });

      if (migRes.ok) {
        onLoginSuccess();
      } else {
        const data = await migRes.json();
        setError(data.error || 'Migration failed');
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to complete account migration');
    } finally {
      setSubmitting(false);
    }
  };

  const bgClass = isLight ? 'bg-white text-gray-900' : 'bg-black text-gray-200';
  const boxClass = isLight ? 'border-gray-400 bg-gray-50' : 'border-gray-800 bg-gray-950 shadow-2xl';

  return (
    <div className={`flex flex-col items-center justify-center min-h-screen font-mono p-4 ${bgClass}`}>
      <div className={`w-full max-w-md border p-6 shadow-xl relative ${boxClass}`}>
        {/* Terminal Header */}
        <div className="text-center mb-6">
          <div className="text-xs uppercase tracking-widest text-emerald-500 font-bold mb-1">
            {isBpxFlow ? '[ LEGACY BPX ACCOUNT MIGRATION ]' : '[ TODO-NEXT SAAS SYSTEM ]'}
          </div>
          <p className="text-xs opacity-75">
            {isBpxFlow
              ? 'Migrate single-user database & set account password'
              : 'Sign in or create account to access your todo.txt workspace'}
          </p>
        </div>

        {/* Tab Selector (Standard Mode) */}
        {!isBpxFlow && (
          <div className="flex border-b mb-6 text-xs font-bold">
            <button
              type="button"
              onClick={() => { setMode('LOGIN'); setError(''); }}
              className={`flex-1 py-2 text-center transition-colors ${
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
              className={`flex-1 py-2 text-center transition-colors ${
                mode === 'SIGNUP'
                  ? 'border-b-2 border-emerald-500 text-emerald-500 font-bold'
                  : 'opacity-50 hover:opacity-100'
              }`}
            >
              [ SIGN UP ]
            </button>
          </div>
        )}

        {/* BPX Migration Wizard */}
        {isBpxFlow ? (
          <div>
            {bpxStep === 1 ? (
              <form onSubmit={handleVerifyLegacyPassword} className="space-y-4">
                <div className="p-3 border border-amber-500/30 bg-amber-500/10 text-amber-400 text-xs rounded mb-4">
                  <strong>Initial Login for bpx / hi@sudipx.in:</strong> Please enter the legacy system password (<code className="bg-black/50 px-1 py-0.5 font-bold">APP_PASSWORD</code> env variable) to authorize data migration.
                </div>

                <div>
                  <label className="block text-xs uppercase tracking-wider mb-1 font-bold">
                    Environment Password (APP_PASSWORD):
                  </label>
                  <div className="flex items-center gap-2 border p-2 bg-transparent">
                    <span className="text-emerald-500 font-bold">&gt;</span>
                    <input
                      type="password"
                      value={legacyPassword}
                      onChange={(e) => setLegacyPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full bg-transparent outline-none font-mono text-sm"
                      autoFocus
                      required
                    />
                  </div>
                </div>

                {error && (
                  <div className="text-xs text-red-500 font-bold text-center">
                    [ERROR: {error}]
                  </div>
                )}

                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => { setIsBpxFlow(false); setError(''); }}
                    className="w-1/3 py-2 text-xs font-bold uppercase border hover:bg-gray-800"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="w-2/3 py-2 text-xs font-bold uppercase border border-emerald-500 bg-emerald-900/40 hover:bg-emerald-800/60 text-white transition-colors"
                  >
                    {submitting ? 'Verifying...' : '[ Verify Env Password ]'}
                  </button>
                </div>
              </form>
            ) : (
              <form onSubmit={handleCompleteBpxMigration} className="space-y-4">
                <div className="p-3 border border-emerald-500/30 bg-emerald-500/10 text-emerald-400 text-xs rounded mb-4">
                  <strong>Env Password Verified!</strong> Now set a new password for account <span className="underline">hi@sudipx.in</span> (bpx). All existing tasks and templates will be migrated with 0 data loss.
                </div>

                <div>
                  <label className="block text-xs uppercase tracking-wider mb-1 font-bold">
                    Set New Account Password:
                  </label>
                  <div className="flex items-center gap-2 border p-2 bg-transparent">
                    <span className="text-emerald-500 font-bold">&gt;</span>
                    <input
                      type="password"
                      value={newBpxPassword}
                      onChange={(e) => setNewBpxPassword(e.target.value)}
                      placeholder="At least 6 characters"
                      className="w-full bg-transparent outline-none font-mono text-sm"
                      autoFocus
                      required
                      minLength={6}
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
                  className="w-full py-2.5 text-xs font-bold uppercase border border-emerald-500 bg-emerald-600 hover:bg-emerald-500 text-black transition-colors"
                >
                  {submitting ? 'Migrating Database & Setting Password...' : '[ Set Password & Complete Migration ]'}
                </button>
              </form>
            )}
          </div>
        ) : (
          /* Standard Auth Form */
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
              className={`w-full py-2.5 text-xs font-bold uppercase border transition-colors ${
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

            {!isBpxMigrated && (
              <div className="pt-2 text-center">
                <button
                  type="button"
                  onClick={() => {
                    setEmailOrUser('bpx');
                    setIsBpxFlow(true);
                    setBpxStep(1);
                    setError('');
                  }}
                  className="text-xs text-emerald-500 hover:underline font-mono"
                >
                  ⚡ First login for legacy bpx account? Click here to migrate.
                </button>
              </div>
            )}
          </form>
        )}
      </div>
    </div>
  );
};
