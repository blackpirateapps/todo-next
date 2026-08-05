import { NextResponse } from 'next/server';
import { updateTaskInDb, deleteTaskFromDb } from '@/lib/db';
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
    const updates = await request.json();
    const updatedTask = await updateTaskInDb(id, updates);
    if (!updatedTask) {
      return NextResponse.json({ error: 'Task not found' }, { status: 404 });
    }
    return NextResponse.json(updatedTask);
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to update task' }, { status: 500 });
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
    await deleteTaskFromDb(id);
    return NextResponse.json({ success: true });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to delete task' }, { status: 500 });
  }
}
