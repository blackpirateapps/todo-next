export interface ParsedDates {
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
  time?: string;
}

export function parseDatesFromRaw(raw: string, fallbackCreation?: string): ParsedDates {
  let creationDate = fallbackCreation || new Date().toISOString().split('T')[0];
  let completionDate: string | undefined = undefined;
  let dueDate: string | undefined = undefined;
  let time: string | undefined = undefined;

  // Time tag: time:HH:MM or @HH:MM (e.g. time:14:30)
  const timeMatch = raw.match(/\btime:(\d{1,2}:\d{2})\b/i);
  if (timeMatch) {
    time = timeMatch[1].padStart(5, '0');
  }

  // Due date: due:YYYY-MM-DD or due:YYYY-MM-DDTHH:MM
  const dueMatch = raw.match(/\bdue:(\d{4}-\d{2}-\d{2})(?:T(\d{1,2}:\d{2}))?\b/i);
  if (dueMatch) {
    dueDate = dueMatch[1];
    if (dueMatch[2]) {
      time = dueMatch[2].padStart(5, '0');
    }
  }

  // Check if completed: x YYYY-MM-DD YYYY-MM-DD ...
  const completedWithTwoDatesMatch = raw.match(/^x\s+(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s/);
  if (completedWithTwoDatesMatch) {
    completionDate = completedWithTwoDatesMatch[1];
    creationDate = completedWithTwoDatesMatch[2];
    return { creationDate, completionDate, dueDate, time };
  }

  // Priority date: (A) YYYY-MM-DD ...
  const priorityDateMatch = raw.match(/^\([A-Z]\)\s+(\d{4}-\d{2}-\d{2})\s/);
  if (priorityDateMatch) {
    creationDate = priorityDateMatch[1];
    return { creationDate, completionDate, dueDate, time };
  }

  // Plain creation date at start: YYYY-MM-DD ...
  const plainDateMatch = raw.match(/^(\d{4}-\d{2}-\d{2})\s/);
  if (plainDateMatch) {
    creationDate = plainDateMatch[1];
    return { creationDate, completionDate, dueDate, time };
  }

  return { creationDate, completionDate, dueDate, time };
}

export function updateRawDates(
  raw: string,
  newCreationDate?: string,
  newDueDate?: string | null,
  newTime?: string | null
): string {
  let updatedRaw = raw;

  // 1. Update or clear time (time:HH:MM)
  if (newTime !== undefined) {
    if (newTime && newTime.trim() !== '') {
      if (/\btime:\d{1,2}:\d{2}\b/i.test(updatedRaw)) {
        updatedRaw = updatedRaw.replace(/\btime:\d{1,2}:\d{2}\b/i, `time:${newTime}`);
      } else {
        updatedRaw = `${updatedRaw.trim()} time:${newTime}`;
      }
    } else {
      updatedRaw = updatedRaw.replace(/\s*\btime:\d{1,2}:\d{2}\b/i, '').trim();
    }
  }

  // 2. Update or clear due date (due:YYYY-MM-DD)
  if (newDueDate !== undefined) {
    if (newDueDate && newDueDate.trim() !== '') {
      if (/\bdue:\d{4}-\d{2}-\d{2}(?:T\d{1,2}:\d{2})?\b/i.test(updatedRaw)) {
        updatedRaw = updatedRaw.replace(/\bdue:\d{4}-\d{2}-\d{2}(?:T\d{1,2}:\d{2})?\b/i, `due:${newDueDate}`);
      } else {
        updatedRaw = `${updatedRaw.trim()} due:${newDueDate}`;
      }
    } else {
      // Clear due date
      updatedRaw = updatedRaw.replace(/\s*\bdue:\d{4}-\d{2}-\d{2}(?:T\d{1,2}:\d{2})?\b/i, '').trim();
    }
  }

  // 3. Update creation date if provided
  if (newCreationDate && /^\d{4}-\d{2}-\d{2}$/.test(newCreationDate)) {
    if (/^x\s+(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s/.test(updatedRaw)) {
      updatedRaw = updatedRaw.replace(/^x\s+(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s/, `x $1 ${newCreationDate} `);
    } else if (/^\([A-Z]\)\s+(\d{4}-\d{2}-\d{2})\s/.test(updatedRaw)) {
      updatedRaw = updatedRaw.replace(/^(\([A-Z]\))\s+(\d{4}-\d{2}-\d{2})\s/, `$1 ${newCreationDate} `);
    } else if (/^(\d{4}-\d{2}-\d{2})\s/.test(updatedRaw)) {
      updatedRaw = updatedRaw.replace(/^(\d{4}-\d{2}-\d{2})\s/, `${newCreationDate} `);
    } else if (/^\([A-Z]\)\s/.test(updatedRaw)) {
      updatedRaw = updatedRaw.replace(/^(\([A-Z]\))\s/, `$1 ${newCreationDate} `);
    } else if (!updatedRaw.startsWith('x ')) {
      updatedRaw = `${newCreationDate} ${updatedRaw}`;
    }
  }

  return updatedRaw;
}
