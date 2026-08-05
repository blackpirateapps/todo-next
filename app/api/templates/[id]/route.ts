import { NextResponse } from 'next/server';
import { updateTemplateInDb, deleteTemplateFromDb } from '@/lib/db';
import { isAuthenticated } from '@/lib/auth';

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const updates = await request.json().catch(() => null);
    if (!updates) {
      return NextResponse.json({ error: 'Invalid updates payload' }, { status: 400 });
    }

    const updatedTemplate = await updateTemplateInDb(id, updates);
    if (!updatedTemplate) {
      return NextResponse.json({ error: 'Template not found' }, { status: 404 });
    }
    return NextResponse.json(updatedTemplate);
  } catch (error: any) {
    console.error('[PATCH /api/templates/[id] Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to update template', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    await deleteTemplateFromDb(id);
    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('[DELETE /api/templates/[id] Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to delete template', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
      { status: 500 }
    );
  }
}
