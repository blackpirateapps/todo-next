import { NextResponse } from 'next/server';
import { getAllTasks, updateTaskInDb, insertTask } from '@/lib/db';
import { getAuthenticatedUser } from '@/lib/auth';
import { spawnNextRecurrenceInstance } from '@/utils/recurrenceEngine';

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
    const allTasks = await getAllTasks(user.uid);
    const existingTask = allTasks.find(t => t.id === id);

    if (!existingTask) {
      return NextResponse.json({ error: 'Task not found' }, { status: 404 });
    }

    const body = await request.json().catch(() => ({}));
    const completionDate = body.completionDate || new Date().toISOString().split('T')[0];

    const today = completionDate;
    let newRaw = existingTask.raw;
    if (!existingTask.completed) {
      newRaw = `x ${today} ${existingTask.raw.replace(/^\([A-Z]\)\s/, '')}`;
    }

    const completedTask = await updateTaskInDb(id, {
      completed: true,
      status: 'completed',
      completionDate,
      raw: newRaw
    }, user.uid);

    let nextTask = null;
    if (existingTask.recurrence) {
      const spawned = spawnNextRecurrenceInstance(existingTask, completionDate);
      if (spawned) {
        nextTask = await insertTask(spawned, user.uid);
      }
    }

    return NextResponse.json({ completedTask, nextTask });
  } catch (error: any) {
    console.error('[POST /api/tasks/[id]/complete Error]:', {
      message: error?.message,
      stack: error?.stack
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to complete task' },
      { status: 500 }
    );
  }
}
