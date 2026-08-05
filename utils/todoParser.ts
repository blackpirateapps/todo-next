export interface ParsedTaskMeta {
  title: string;
  priority: string | null;
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
  dueTime?: string;
  completed: boolean;
  projects: string[];
  contexts: string[];
}

export function parseRawToStructured(raw: string, fallbackCreation?: string): ParsedTaskMeta {
  const words = raw.trim().split(/\s+/);

  let completed = false;
  let priority: string | null = null;
  let creationDate = fallbackCreation || new Date().toISOString().split('T')[0];
  let completionDate: string | undefined = undefined;
  let dueDate: string | undefined = undefined;
  let dueTime: string | undefined = undefined;
  const projects: string[] = [];
  const contexts: string[] = [];
  const titleWords: string[] = [];

  let idx = 0;

  // Check completed prefix: x YYYY-MM-DD YYYY-MM-DD ... or x ...
  if (words[0] === 'x') {
    completed = true;
    idx++;
    if (words[idx] && /^\d{4}-\d{2}-\d{2}$/.test(words[idx])) {
      completionDate = words[idx];
      idx++;
      if (words[idx] && /^\d{4}-\d{2}-\d{2}$/.test(words[idx])) {
        creationDate = words[idx];
        idx++;
      }
    }
  }

  // Check priority: (A)
  if (words[idx] && /^\([A-Z]\)$/.test(words[idx])) {
    priority = words[idx][1];
    idx++;
  }

  // Check creation date if not completed: YYYY-MM-DD
  if (!completed && words[idx] && /^\d{4}-\d{2}-\d{2}$/.test(words[idx])) {
    creationDate = words[idx];
    idx++;
  }

  // Process remaining tokens
  for (; idx < words.length; idx++) {
    const word = words[idx];

    if (word.startsWith('+') && word.length > 1) {
      if (!projects.includes(word)) projects.push(word);
    } else if (word.startsWith('@') && word.length > 1) {
      if (!contexts.includes(word)) contexts.push(word);
    } else if (/\bdue:(\d{4}-\d{2}-\d{2})(?:T(\d{1,2}:\d{2}))?\b/i.test(word)) {
      const match = word.match(/\bdue:(\d{4}-\d{2}-\d{2})(?:T(\d{1,2}:\d{2}))?\b/i);
      if (match) {
        dueDate = match[1];
        if (match[2]) dueTime = match[2].padStart(5, '0');
      }
    } else if (/\btime:(\d{1,2}:\d{2})\b/i.test(word)) {
      const match = word.match(/\btime:(\d{1,2}:\d{2})\b/i);
      if (match) dueTime = match[1].padStart(5, '0');
    } else {
      titleWords.push(word);
    }
  }

  const title = titleWords.join(' ') || raw;

  return {
    title,
    priority,
    creationDate,
    completionDate,
    dueDate,
    dueTime,
    completed,
    projects,
    contexts,
  };
}

export function buildRawFromStructured(meta: {
  title: string;
  priority?: string | null;
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
  dueTime?: string;
  completed: boolean;
  projects?: string[];
  contexts?: string[];
}): string {
  const parts: string[] = [];

  if (meta.completed) {
    parts.push('x');
    if (meta.completionDate) parts.push(meta.completionDate);
    parts.push(meta.creationDate);
  }

  if (meta.priority) {
    parts.push(`(${meta.priority})`);
  }

  if (!meta.completed && meta.creationDate) {
    parts.push(meta.creationDate);
  }

  if (meta.title) {
    parts.push(meta.title);
  }

  if (meta.projects && meta.projects.length > 0) {
    meta.projects.forEach(p => {
      if (!parts.includes(p)) parts.push(p);
    });
  }

  if (meta.contexts && meta.contexts.length > 0) {
    meta.contexts.forEach(c => {
      if (!parts.includes(c)) parts.push(c);
    });
  }

  if (meta.dueDate) {
    parts.push(`due:${meta.dueDate}`);
  }

  if (meta.dueTime) {
    parts.push(`time:${meta.dueTime}`);
  }

  return parts.join(' ');
}

export function parseDatesFromRaw(raw: string, fallbackCreation?: string) {
  const parsed = parseRawToStructured(raw, fallbackCreation);
  return {
    creationDate: parsed.creationDate,
    completionDate: parsed.completionDate,
    dueDate: parsed.dueDate,
    time: parsed.dueTime,
  };
}

export function updateRawDates(
  raw: string,
  newCreationDate?: string,
  newDueDate?: string | null,
  newTime?: string | null
): string {
  const parsed = parseRawToStructured(raw, newCreationDate);
  return buildRawFromStructured({
    title: parsed.title,
    priority: parsed.priority,
    completed: parsed.completed,
    completionDate: parsed.completionDate,
    creationDate: newCreationDate || parsed.creationDate,
    dueDate: newDueDate !== undefined ? (newDueDate || undefined) : parsed.dueDate,
    dueTime: newTime !== undefined ? (newTime || undefined) : parsed.dueTime,
    projects: parsed.projects,
    contexts: parsed.contexts,
  });
}
