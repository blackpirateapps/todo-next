import { NextResponse } from 'next/server';
import { archiveReferenceInDb } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const updated = await archiveReferenceInDb(id, false, user.uid);
    if (!updated) {
      return NextResponse.json({ error: 'Reference not found' }, { status: 404 });
    }
    return NextResponse.json(updated);
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[POST /api/references/[id]/restore Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to restore reference', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}
