import { NextResponse } from 'next/server';
import { instantiateTaskFromTemplateId } from '@/lib/db';
import { isAuthenticated } from '@/lib/auth';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const body = await request.json().catch(() => ({}));
    const varOverrides = body.varOverrides || {};

    const newTask = await instantiateTaskFromTemplateId(id, varOverrides);
    if (!newTask) {
      return NextResponse.json({ error: 'Template not found' }, { status: 404 });
    }

    return NextResponse.json(newTask, { status: 201 });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to instantiate task from template' }, { status: 500 });
  }
}
