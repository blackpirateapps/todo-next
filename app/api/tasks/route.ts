import { NextResponse } from 'next/server';
import { getAllTasks, insertTask } from '@/lib/db';
import { isAuthenticated } from '@/lib/auth';
import { Task } from '@/types/todo';

export async function GET() {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const tasks = await getAllTasks();
    return NextResponse.json(tasks);
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to fetch tasks' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body: Task = await request.json();
    const newTask = await insertTask(body);
    return NextResponse.json(newTask, { status: 201 });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to create task' }, { status: 500 });
  }
}
