import { NextResponse } from 'next/server';
import { getReferenceById, updateReferenceInDb, deleteReferenceFromDb } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const reference = await getReferenceById(id, user.uid);
    if (!reference) {
      return NextResponse.json({ error: 'Reference not found' }, { status: 404 });
    }
    return NextResponse.json(reference);
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[GET /api/references/[id] Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to fetch reference', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const updates = await request.json().catch(() => null);
    if (!updates || typeof updates !== 'object') {
      return NextResponse.json({ error: 'Invalid updates payload' }, { status: 400 });
    }

    const updated = await updateReferenceInDb(id, updates, user.uid);
    if (!updated) {
      return NextResponse.json({ error: 'Reference not found' }, { status: 404 });
    }
    return NextResponse.json(updated);
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[PATCH /api/references/[id] Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to update reference', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    await deleteReferenceFromDb(id, user.uid);
    return NextResponse.json({ success: true });
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[DELETE /api/references/[id] Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to delete reference', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}
