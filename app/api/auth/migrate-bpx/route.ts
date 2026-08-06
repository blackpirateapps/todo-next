import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { verifyLegacyPassword } from '@/lib/auth';
import { migrateLegacyDataToUser } from '@/lib/db';

export async function POST(request: Request) {
  try {
    const { legacyPassword, userId, email, token } = await request.json();

    if (!legacyPassword || !userId || !email) {
      return NextResponse.json({ error: 'Missing required migration fields' }, { status: 400 });
    }

    if (!verifyLegacyPassword(legacyPassword)) {
      return NextResponse.json({ error: 'Invalid legacy environment password' }, { status: 401 });
    }

    // Run DB migration assigning all legacy data to this user's UID
    await migrateLegacyDataToUser(userId, email, 'bpx');

    if (token) {
      const cookieStore = await cookies();
      cookieStore.set('app_session', token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
        maxAge: 60 * 60 * 24 * 30, // 30 days
      });
    }

    return NextResponse.json({ success: true, migrated: true });
  } catch (error: any) {
    console.error('[Migration Error]:', error);
    return NextResponse.json({ error: error?.message || 'Migration failed' }, { status: 500 });
  }
}
