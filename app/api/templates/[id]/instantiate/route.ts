import { NextResponse } from 'next/server';
import { instantiateTaskFromTemplateId } from '@/lib/db';
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
    const body = await request.json().catch(() => ({}));
    const varOverrides = body.varOverrides || {};

    const newTask = await instantiateTaskFromTemplateId(id, varOverrides, user.uid);
    if (!newTask) {
      return NextResponse.json({ error: 'Template not found' }, { status: 404 });
    }

    return NextResponse.json(newTask, { status: 201 });
  } catch (error: any) {
    console.error('[POST /api/templates/[id]/instantiate Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to instantiate task from template', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
      { status: 500 }
    );
  }
}
