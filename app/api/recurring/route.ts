import { NextResponse } from 'next/server';
import { getAllTasks } from '@/lib/db';
import { isAuthenticated } from '@/lib/auth';
import { getUpcomingRecurrenceDates, parseRecurrenceRule } from '@/utils/recurrenceEngine';

export async function GET() {
  if (!(await isAuthenticated())) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const tasks = await getAllTasks();
    const recurringTasks = tasks.filter(t => Boolean(t.recurrence) && !t.completed);

    const result = recurringTasks.map(t => {
      const rule = parseRecurrenceRule(t.recurrence || '');
      const upcomingDates = getUpcomingRecurrenceDates(t, 5);
      return {
        task: t,
        rule,
        upcomingDates
      };
    });

    return NextResponse.json(result);
  } catch (error: any) {
    console.error('[GET /api/recurring Error]:', {
      message: error?.message,
      stack: error?.stack
    });
    return NextResponse.json(
      { error: error?.message || 'Failed to fetch recurring tasks' },
      { status: 500 }
    );
  }
}
