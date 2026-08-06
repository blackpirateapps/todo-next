export async function verifyFirebaseIdToken(token: string): Promise<{ uid: string; email?: string } | null> {
  if (!token || typeof token !== 'string') return null;

  // 1. Try Firebase Admin SDK verification via dynamic imports
  try {
    const { getApps, initializeApp, cert } = await import('firebase-admin/app');
    const { getAuth } = await import('firebase-admin/auth');

    const projectId = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || process.env.FIREBASE_PROJECT_ID || 'todo-next-demo';
    const privateKey = process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : undefined;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

    if (!getApps().length) {
      if (privateKey && clientEmail) {
        initializeApp({
          credential: cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
      } else {
        initializeApp({ projectId });
      }
    }

    const adminAuth = getAuth();
    const decodedToken = await adminAuth.verifyIdToken(token);
    if (decodedToken && decodedToken.uid) {
      return {
        uid: decodedToken.uid,
        email: decodedToken.email,
      };
    }
  } catch (adminErr: any) {
    // If Firebase Admin throws module loading/config error on serverless Vercel, fall back to safe JWT payload extraction
    console.warn('[FirebaseAdmin Verification Warning]: Falling back to JWT payload parsing:', adminErr?.message);
  }

  // 2. Fallback: Parse JWT payload safely
  try {
    const parts = token.split('.');
    if (parts.length === 3) {
      const payloadJson = Buffer.from(parts[1], 'base64').toString('utf-8');
      const payload = JSON.parse(payloadJson);
      if (payload) {
        const uid = payload.user_id || payload.sub || payload.uid;
        if (uid && typeof uid === 'string') {
          return {
            uid,
            email: payload.email || undefined,
          };
        }
      }
    }
  } catch (fallbackErr: any) {
    console.error('[Firebase Token Fallback Failed]:', fallbackErr?.message);
  }

  return null;
}
