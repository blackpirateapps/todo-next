import { NextResponse } from 'next/server';
import { verifyLegacyPassword } from '@/lib/auth';

export async function POST(request: Request) {
  try {
    const { password } = await request.json();
    if (!password) {
      return NextResponse.json({ error: 'Password is required' }, { status: 400 });
    }

    const isValid = verifyLegacyPassword(password);
    if (!isValid) {
      return NextResponse.json({ error: 'Incorrect legacy system password' }, { status: 401 });
    }

    return NextResponse.json({ success: true, verified: true });
  } catch (error: any) {
    return NextResponse.json({ error: error?.message || 'Verification failed' }, { status: 500 });
  }
}
