export interface ParsedDates {
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
}

export function parseDatesFromRaw(raw: string, fallbackCreation?: string): ParsedDates {
  let creationDate = fallbackCreation || new Date().toISOString().split('T')[0];
  let completionDate: string | undefined = undefined;
  let dueDate: string | undefined = undefined;

  // Due date: due:YYYY-MM-DD
  const dueMatch = raw.match(/\bdue:(\d{4}-\d{2}-\d{2})\b/);
  if (dueMatch) {
    dueDate = dueMatch[1];
  }

  // Check if completed: x YYYY-MM-DD YYYY-MM-DD ...
  const completedWithTwoDatesMatch = raw.match(/^x\s+(\d{4}-\d{2}-\d{2})\s+(\d{4}-\d{2}-\d{2})\s/);
  if (completedWithTwoDatesMatch) {
    completionDate = completedWithTwoDatesMatch[1];
    creationDate = completedWithTwoDatesMatch[2];
    return { creationDate, completionDate, dueDate };
  }

  // Priority date: (A) YYYY-MM-DD ...
  const priorityDateMatch = raw.match(/^\([A-Z]\)\s+(\d{4}-\d{2}-\d{2})\s/);
  if (priorityDateMatch) {
    creationDate = priorityDateMatch[1];
    return { creationDate, completionDate, dueDate };
  }

  // Plain creation date at start: YYYY-MM-DD ...
  const plainDateMatch = raw.match(/^(\d{4}-\d{2}-\d{2})\s/);
  if (plainDateMatch) {
    creationDate = plainDateMatch[1];
    return { creationDate, completionDate, dueDate };
  }

  return { creationDate, completionDate, dueDate };
}

export function updateRawDates(
  raw: string,
  newCreationDate?: string,
  newDueDate?: string | null
): string {
  let updatedRaw = raw;

  // 1. Update or clear due date (due:YYYY-MM-DD)
  if (newDueDate !== undefined) {
    if (newDueDate && newDueDate.trim() !== '') {
      if (/\bdue:\d{4}-\d{2}-\d{2}\b/.test(updatedRaw)) {
        updatedRaw = updatedRaw.replace(/\bdue:\d{4}-\d{2}-\d{2}\b/, `due:${newDueDate}`);
      } else {
        updatedRaw = `${updatedRaw.trim()} due:${newDueDate}`;
      }
    } else {
      // Clear due date
      updatedRaw = updatedRaw.replace(/\s*\bdue:\d{4}-\d{2}-\d{2}\b/, '').trim();
    }
  }

  // 2. Update creation date if provided
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
