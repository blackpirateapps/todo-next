import { NextResponse } from 'next/server';
import { getAllTemplates, insertTemplate } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';
import { Template } from '@/types/todo';

export async function GET() {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const templates = await getAllTemplates(user.uid);
    return NextResponse.json(templates);
  } catch (error: any) {
    console.error('[GET /api/templates Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to fetch templates', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
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
    const body: Template = await request.json().catch(() => null);
    if (!body || !body.name || !body.rawTemplate) {
      return NextResponse.json({ error: 'Invalid template payload' }, { status: 400 });
    }

    const newTemplate = await insertTemplate(body, user.uid);
    return NextResponse.json(newTemplate, { status: 201 });
  } catch (error: any) {
    console.error('[POST /api/templates Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to create template', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
      { status: 500 }
    );
  }
}
