import { NextResponse } from 'next/server';
import { getAllTasks, updateTaskInDb } from '@/lib/db';
import { isAuthenticated } from '@/lib/auth';
import { skipRecurrenceOccurrence } from '@/utils/recurrenceEngine';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;
    const allTasks = await getAllTasks();
    const existingTask = allTasks.find(t => t.id === id);

    if (!existingTask) {
      return NextResponse.json({ error: 'Task not found' }, { status: 404 });
    }

    if (!existingTask.recurrence) {
      return NextResponse.json({ error: 'Task is not recurring' }, { status: 400 });
    }

    const skippedTask = skipRecurrenceOccurrence(existingTask);
    const updatedTask = await updateTaskInDb(id, {
      dueDate: skippedTask.dueDate,
      raw: skippedTask.raw
    });

    return NextResponse.json({ updatedTask });
  } catch (error: any) {
    console.error('[POST /api/tasks/[id]/skip Error]:', {
      message: error?.message,
      stack: error?.stack
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to skip occurrence' },
      { status: 500 }
    );
  }
}
