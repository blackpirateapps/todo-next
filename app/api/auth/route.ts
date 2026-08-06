import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { getAuthenticatedUser } from '@/lib/auth';
import { isBpxMigrated } from '@/lib/db';

export async function GET() {
  const user = await getAuthenticatedUser();
  const bpxMigrated = await isBpxMigrated();

  return NextResponse.json({
    authRequired: true,
    authenticated: Boolean(user),
    isBpxMigrated: bpxMigrated,
    user: user ? { uid: user.uid, email: user.email } : null
  });
}

export async function POST(request: Request) {
  try {
    const { token } = await request.json();
    if (!token) {
      return NextResponse.json({ error: 'Token is required' }, { status: 400 });
    }

    const cookieStore = await cookies();
    cookieStore.set('app_session', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 30, // 30 days
    });

    return NextResponse.json({ success: true, token });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Authentication failed' }, { status: 500 });
  }
}

export async function DELETE() {
  const cookieStore = await cookies();
  cookieStore.delete('app_session');
  return NextResponse.json({ success: true });
}
