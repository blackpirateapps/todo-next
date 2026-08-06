import { NextResponse } from 'next/server';
import { getAllTasks, insertTask } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';
import { Task } from '@/types/todo';

export async function GET() {
  const user = await getAuthenticatedUser();
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const tasks = await getAllTasks(user.uid);
    return NextResponse.json(tasks);
  } catch (error: any) {
    console.error('[GET /api/tasks Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to fetch tasks', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
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
    const body: Task = await request.json().catch(() => null);
    if (!body || !body.raw) {
      return NextResponse.json({ error: 'Invalid task payload' }, { status: 400 });
    }

    const newTask = await insertTask(body, user.uid);
    return NextResponse.json(newTask, { status: 201 });
  } catch (error: any) {
    console.error('[POST /api/tasks Error]:', {
      message: error?.message,
      stack: error?.stack,
      cause: error?.cause,
      hasTursoUrl: Boolean(process.env.TURSO_DATABASE_URL),
      isVercel: Boolean(process.env.VERCEL)
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to create task', debug: process.env.NODE_ENV !== 'production' ? error?.stack : undefined },
      { status: 500 }
    );
  }
}
