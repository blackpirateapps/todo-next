import { Task, Subtask, RecurrenceRule, RecurrenceUnit, RecurrenceMode } from '@/types/todo';
import { formatDateISO } from '@/utils/dateUtils';
import { parseRawToStructured, buildRawFromStructured } from '@/utils/todoParser';

/**
 * Parses a raw recurrence tag like "1d", "rec:1w", "strict:3d", "+2w", "weekday", "mwf"
 * into a structured RecurrenceRule object.
 */
export function parseRecurrenceRule(rawTag: string): RecurrenceRule | null {
  if (!rawTag) return null;

  let clean = rawTag.trim();
  if (clean.toLowerCase().startsWith('rec:')) {
    clean = clean.substring(4);
  }

  let mode: RecurrenceMode = 'completion';
  if (clean.toLowerCase().startsWith('strict:')) {
    mode = 'strict';
    clean = clean.substring(7);
  } else if (clean.startsWith('+')) {
    mode = 'strict';
    clean = clean.substring(1);
  }

  const lower = clean.toLowerCase();

  if (lower === 'weekday') {
    return { raw: rawTag, interval: 1, unit: 'weekday', mode };
  }

  if (lower === 'mwf') {
    return { raw: rawTag, interval: 1, unit: 'mwf', mode };
  }

  const match = lower.match(/^(\d+)([dwmy])$/);
  if (!match) return null;

  const interval = parseInt(match[1], 10);
  const unit = match[2] as RecurrenceUnit;

  if (interval <= 0) return null;

  return { raw: rawTag, interval, unit, mode };
}

/**
 * Calculates the next due date string (YYYY-MM-DD) based on reference date and recurrence rule.
 */
export function calculateNextDueDate(
  currentDueDate: string | undefined,
  completionDate: string,
  rule: RecurrenceRule
): { nextDueDate: string } {
  // Determine reference date string YYYY-MM-DD
  const refDateStr = (rule.mode === 'strict' && currentDueDate) ? currentDueDate : completionDate;
  
  const parts = refDateStr.split('-').map(Number);
  const baseDate = new Date(parts[0], parts[1] - 1, parts[2] || 1);

  let nextDate = new Date(baseDate);

  switch (rule.unit) {
    case 'd':
      nextDate.setDate(nextDate.getDate() + rule.interval);
      break;

    case 'w':
      nextDate.setDate(nextDate.getDate() + rule.interval * 7);
      break;

    case 'm': {
      const origDay = nextDate.getDate();
      nextDate.setMonth(nextDate.getMonth() + rule.interval);
      // Handle month overflow (e.g. Jan 31 -> Feb 28)
      if (nextDate.getDate() !== origDay) {
        nextDate.setDate(0);
      }
      break;
    }

    case 'y':
      nextDate.setFullYear(nextDate.getFullYear() + rule.interval);
      break;

    case 'weekday': {
      // Advance to next Monday - Friday
      do {
        nextDate.setDate(nextDate.getDate() + 1);
      } while (nextDate.getDay() === 0 || nextDate.getDay() === 6);
      break;
    }

    case 'mwf': {
      // Advance to next Mon (1), Wed (3), or Fri (5)
      do {
        nextDate.setDate(nextDate.getDate() + 1);
      } while (![1, 3, 5].includes(nextDate.getDay()));
      break;
    }
  }

  // Ensure strict mode doesn't produce a date in the past relative to completionDate
  if (rule.mode === 'strict' && completionDate) {
    const compParts = completionDate.split('-').map(Number);
    const compDateObj = new Date(compParts[0], compParts[1] - 1, compParts[2] || 1);
    while (nextDate <= compDateObj) {
      switch (rule.unit) {
        case 'd': nextDate.setDate(nextDate.getDate() + rule.interval); break;
        case 'w': nextDate.setDate(nextDate.getDate() + rule.interval * 7); break;
        case 'm': nextDate.setMonth(nextDate.getMonth() + rule.interval); break;
        case 'y': nextDate.setFullYear(nextDate.getFullYear() + rule.interval); break;
        default: nextDate.setDate(nextDate.getDate() + 1); break;
      }
    }
  }

  return { nextDueDate: formatDateISO(nextDate) };
}

/**
 * Creates the next Task instance when completing a recurring task.
 */
export function spawnNextRecurrenceInstance(
  completedTask: Task,
  completionDate: string
): Task | null {
  const recStr = completedTask.recurrence || parseRawToStructured(completedTask.raw).recurrence;
  if (!recStr) return null;

  const rule = parseRecurrenceRule(recStr);
  if (!rule) return null;

  const { nextDueDate } = calculateNextDueDate(completedTask.dueDate, completionDate, rule);

  // Re-set subtasks to uncompleted
  const resetSubtasks: Subtask[] = completedTask.subtasks.map((st, idx) => ({
    id: `st-${Date.now()}-${idx}`,
    taskId: undefined,
    title: st.title,
    raw: st.raw || st.title,
    completed: false
  }));

  // Re-build raw string with open status and new due date
  const newRaw = buildRawFromStructured({
    title: completedTask.title,
    priority: completedTask.priority,
    creationDate: completionDate,
    dueDate: nextDueDate,
    dueTime: completedTask.dueTime,
    recurrence: recStr,
    completed: false,
    projects: completedTask.projects,
    contexts: completedTask.contexts
  });

  const nextTask: Task = {
    id: `t${Date.now()}`,
    title: completedTask.title,
    raw: newRaw,
    status: 'open',
    completed: false,
    priority: completedTask.priority,
    creationDate: completionDate,
    dueDate: nextDueDate,
    dueTime: completedTask.dueTime,
    description: completedTask.description || '',
    recurrence: recStr,
    parentRecurringId: completedTask.id,
    projects: [...completedTask.projects],
    contexts: [...completedTask.contexts],
    subtasks: resetSubtasks,
    comments: []
  };

  return nextTask;
}

/**
 * Advances a recurring task's due date to the next occurrence without marking it completed.
 */
export function skipRecurrenceOccurrence(task: Task): Task {
  const recStr = task.recurrence || parseRawToStructured(task.raw).recurrence;
  if (!recStr) return task;

  const rule = parseRecurrenceRule(recStr);
  if (!rule) return task;

  const today = formatDateISO(new Date());
  const { nextDueDate } = calculateNextDueDate(task.dueDate || today, today, rule);

  const newRaw = buildRawFromStructured({
    title: task.title,
    priority: task.priority,
    creationDate: task.creationDate,
    dueDate: nextDueDate,
    dueTime: task.dueTime,
    recurrence: recStr,
    completed: false,
    projects: task.projects,
    contexts: task.contexts
  });

  return {
    ...task,
    raw: newRaw,
    dueDate: nextDueDate,
  };
}

/**
 * Generates future projected due dates for calendar visualization.
 */
export function getUpcomingRecurrenceDates(task: Task, maxCount: number = 5): string[] {
  if (!task.recurrence || task.completed) return [];
  const rule = parseRecurrenceRule(task.recurrence);
  if (!rule) return [];

  const results: string[] = [];
  let currentDue = task.dueDate || formatDateISO(new Date());

  for (let i = 0; i < maxCount; i++) {
    const { nextDueDate } = calculateNextDueDate(currentDue, currentDue, rule);
    results.push(nextDueDate);
    currentDue = nextDueDate;
  }

  return results;
}
