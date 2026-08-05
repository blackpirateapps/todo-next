import { cookies } from 'next/headers';
import crypto from 'crypto';

export function getExpectedSessionToken(): string | null {
  const password = process.env.APP_PASSWORD;
  if (!password) return null;
  return crypto.createHash('sha256').update(password).digest('hex');
}

export function isAuthRequired(): boolean {
  return Boolean(process.env.APP_PASSWORD);
}

export async function isAuthenticated(): Promise<boolean> {
  const expectedToken = getExpectedSessionToken();
  if (!expectedToken) return true; // Password not set, open access

  const cookieStore = await cookies();
  const sessionToken = cookieStore.get('app_session')?.value;
  return sessionToken === expectedToken;
}

export function verifyPassword(password: string): boolean {
  const expectedPassword = process.env.APP_PASSWORD;
  if (!expectedPassword) return true;
  return password === expectedPassword;
}
