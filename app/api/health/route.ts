import { NextResponse } from 'next/server';
import { db, initDb } from '@/lib/db';

export async function GET() {
  const isVercel = Boolean(process.env.VERCEL || process.env.AWS_LAMBDA_FUNCTION_NAME);
  const hasTursoUrl = Boolean(process.env.TURSO_DATABASE_URL);
  const hasTursoToken = Boolean(process.env.TURSO_AUTH_TOKEN);

  try {
    await initDb();
    const result = await db.execute('SELECT COUNT(*) as count FROM tasks');
    const taskCount = Number(result.rows[0]?.count ?? 0);

    return NextResponse.json({
      status: 'healthy',
      database: 'connected',
      taskCount,
      environment: {
        isVercel,
        hasTursoUrl,
        hasTursoToken,
        nodeEnv: process.env.NODE_ENV
      }
    });
  } catch (error: any) {
    console.error('[Health Diagnostic Check Failed]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      isVercel,
      hasTursoUrl,
      hasTursoToken
    });

    return NextResponse.json({
      status: 'unhealthy',
      database: 'error',
      error: error?.message,
      environment: {
        isVercel,
        hasTursoUrl,
        hasTursoToken,
        nodeEnv: process.env.NODE_ENV
      }
    }, { status: 500 });
  }
}
