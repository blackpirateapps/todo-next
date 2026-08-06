import { NextResponse } from 'next/server';
import { registerUserInDb } from '@/lib/db';

export async function POST(request: Request) {
  try {
    const { email: rawEmail, password } = await request.json();

    if (!rawEmail || !password) {
      return NextResponse.json({ error: 'Email and password are required' }, { status: 400 });
    }

    let email = rawEmail.trim();
    if (email.toLowerCase() === 'bpx') {
      email = 'hi@sudipx.in';
    } else if (!email.includes('@')) {
      email = `${email}@todo-next.app`;
    }

    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
    if (!apiKey) {
      return NextResponse.json({ error: 'Firebase API key is not configured' }, { status: 500 });
    }

    const fbRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          password,
          returnSecureToken: true,
        }),
      }
    );

    const data = await fbRes.json();

    if (!fbRes.ok) {
      const errorMsg = data?.error?.message || 'Authentication failed';
      return NextResponse.json({ error: errorMsg }, { status: fbRes.status });
    }

    const token = data.idToken;
    const uid = data.localId;

    await registerUserInDb(uid, email);

    return NextResponse.json({
      success: true,
      token,
      uid,
      email,
    });
  } catch (error: any) {
    console.error('[API Auth Login Error]:', error);
    return NextResponse.json({ error: error?.message || 'Login failed' }, { status: 500 });
  }
}
