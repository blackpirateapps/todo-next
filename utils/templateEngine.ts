import { Template, Task, Subtask } from '@/types/todo';
import { parseRawToStructured, buildRawFromStructured } from './todoParser';
import { formatDateISO } from './dateUtils';

export function resolveTemplateTokens(
  rawTemplate: string,
  varOverrides: Record<string, string> = {}
): string {
  let resolved = rawTemplate;
  const now = new Date();

  // 1. Resolve {today}
  const todayISO = formatDateISO(now);
  resolved = resolved.replace(/\{today\}/g, todayISO);

  // 2. Resolve relative due dates: {due:\+(\d+)([dwm])}
  resolved = resolved.replace(/\{due:\+(\d+)([dwm])\}/g, (_, numStr, unit) => {
    const num = parseInt(numStr, 10);
    const targetDate = new Date(now);

    if (unit === 'd') {
      targetDate.setDate(targetDate.getDate() + num);
    } else if (unit === 'w') {
      targetDate.setDate(targetDate.getDate() + (num * 7));
    } else if (unit === 'm') {
      targetDate.setMonth(targetDate.getMonth() + num);
    }

    return `due:${formatDateISO(targetDate)}`;
  });

  // 3. Resolve time tokens: {time:HH:MM}
  resolved = resolved.replace(/\{time:(\d{1,2}:\d{2})\}/g, 'time:$1');

  // 4. Resolve custom variables: {var:VariableName}
  resolved = resolved.replace(/\{var:([a-zA-Z0-9_-]+)\}/g, (_, varName) => {
    return varOverrides[varName] || varName;
  });

  return resolved;
}

export function instantiateTaskFromTemplate(
  template: Template,
  varOverrides: Record<string, string> = {}
): { newTask: Task; newSubtasks: Subtask[] } {
  const resolvedRaw = resolveTemplateTokens(template.rawTemplate, varOverrides);
  const parsed = parseRawToStructured(resolvedRaw);
  const taskId = `t${Date.now()}`;

  const projects = Array.from(new Set([...template.projects, ...parsed.projects]));
  const contexts = Array.from(new Set([...template.contexts, ...parsed.contexts]));

  const reconstructedRaw = buildRawFromStructured({
    title: parsed.title,
    priority: parsed.priority,
    creationDate: parsed.creationDate,
    completionDate: parsed.completionDate,
    dueDate: parsed.dueDate,
    dueTime: parsed.dueTime,
    completed: parsed.completed,
    projects,
    contexts
  });

  const newSubtasks: Subtask[] = template.subtasks.map((st, idx) => ({
    id: `${taskId}-st${idx + 1}`,
    taskId,
    title: resolveTemplateTokens(st.title, varOverrides),
    raw: resolveTemplateTokens(st.title, varOverrides),
    completed: false
  }));

  const newTask: Task = {
    id: taskId,
    title: parsed.title,
    raw: reconstructedRaw,
    status: parsed.completed ? 'completed' : 'open',
    completed: parsed.completed,
    priority: parsed.priority,
    creationDate: parsed.creationDate,
    completionDate: parsed.completionDate,
    dueDate: parsed.dueDate,
    dueTime: parsed.dueTime,
    description: template.description || '',
    projects,
    contexts,
    subtasks: newSubtasks,
    comments: []
  };

  return { newTask, newSubtasks };
}
