import { NextResponse } from 'next/server';
import { getAllReferences, insertReference, GetReferencesOptions } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';
import { Reference } from '@/types/todo';

export async function GET(request: Request) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { searchParams } = new URL(request.url);
    const archivedParam = searchParams.get('archived');
    const search = searchParams.get('search') || undefined;
    const tag = searchParams.get('tag') || undefined;
    const sort = searchParams.get('sort') || undefined;
    const order = (searchParams.get('order') as 'asc' | 'desc') || undefined;

    const options: GetReferencesOptions = {
      search,
      tag,
      sort,
      order
    };

    if (archivedParam === 'all') {
      options.archived = 'all';
    } else if (archivedParam === 'true' || archivedParam === '1') {
      options.archived = true;
    } else if (archivedParam === 'false' || archivedParam === '0') {
      options.archived = false;
    }

    const references = await getAllReferences(user.uid, options);
    return NextResponse.json(references);
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[GET /api/references Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to fetch references', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json().catch(() => null);
    if (!body || typeof body.title !== 'string' || !body.title.trim()) {
      return NextResponse.json({ error: 'Title is required for a Reference' }, { status: 400 });
    }

    const newReference: Reference = {
      id: body.id || `ref-${Date.now()}`,
      userId: user.uid,
      title: body.title.trim(),
      content: typeof body.content === 'string' ? body.content : '',
      tags: Array.isArray(body.tags) ? body.tags.filter((t: unknown) => typeof t === 'string') : [],
      createdAt: body.createdAt || new Date().toISOString(),
      updatedAt: body.updatedAt || new Date().toISOString(),
      archived: Boolean(body.archived)
    };

    const inserted = await insertReference(newReference, user.uid);
    return NextResponse.json(inserted, { status: 201 });
  } catch (error: unknown) {
    const e = error as Error;
    console.error('[POST /api/references Error]:', {
      message: e?.message,
      stack: e?.stack,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: e?.message || 'Failed to create reference', debug: process.env.NODE_ENV !== 'production' ? e?.stack : undefined },
      { status: 500 }
    );
  }
}
