import { cookies, headers } from 'next/headers';
import { verifyFirebaseIdToken } from './firebaseAdmin';

export function getExpectedLegacyPassword(): string | null {
  return process.env.APP_PASSWORD || null;
}

export function verifyLegacyPassword(password: string): boolean {
  const expectedPassword = process.env.APP_PASSWORD;
  if (!expectedPassword) return true;
  return password === expectedPassword;
}

export async function getAuthenticatedUser(): Promise<{ uid: string; email?: string } | null> {
  const headerStore = await headers();
  const authHeader = headerStore.get('authorization');
  const customHeaderToken = headerStore.get('x-app-session')?.trim();

  let token = customHeaderToken;
  if (!token && authHeader) {
    token = authHeader.replace(/^Bearer\s+/i, '').trim();
  }

  if (!token) {
    const cookieStore = await cookies();
    token = cookieStore.get('app_session')?.value;
  }

  if (!token) return null;

  const verified = await verifyFirebaseIdToken(token);
  return verified;
}

export async function isAuthenticated(): Promise<boolean> {
  const user = await getAuthenticatedUser();
  return Boolean(user);
}
