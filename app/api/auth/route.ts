import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { isAuthRequired, isAuthenticated, verifyPassword, getExpectedSessionToken } from '@/lib/auth';

export async function GET() {
  const authRequired = isAuthRequired();
  const authenticated = await isAuthenticated();
  return NextResponse.json({ authRequired, authenticated });
}

export async function POST(request: Request) {
  try {
    const { password } = await request.json();
    if (!verifyPassword(password)) {
      return NextResponse.json({ error: 'Incorrect password' }, { status: 401 });
    }

    const expectedToken = getExpectedSessionToken();
    const cookieStore = await cookies();

    if (expectedToken) {
      cookieStore.set('app_session', expectedToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });
    }

    return NextResponse.json({ success: true });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Authentication failed' }, { status: 500 });
  }
}

export async function DELETE() {
  const cookieStore = await cookies();
  cookieStore.delete('app_session');
  return NextResponse.json({ success: true });
}
