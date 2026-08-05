import { createClient } from '@libsql/client';
import { Task } from '@/types/todo';

const url = process.env.TURSO_DATABASE_URL || 'file:todo.db';
const authToken = process.env.TURSO_AUTH_TOKEN;

export const db = createClient({
  url,
  authToken,
});

const initialTasks: Task[] = [
  {
    id: 't1',
    raw: '(A) 2026-08-06 Implement core parsing logic for +backend @dev',
    completed: false,
    priority: 'A',
    creationDate: '2026-08-05',
    description: 'Need to write a robust regex parser that handles priorities (A-Z), dates, +projects, and @contexts natively without breaking on malformed strings. Reference the original todo.txt spec.',
    subtasks: [
      { id: 't1-1', raw: 'Write unit tests for edge cases', completed: true },
      { id: 't1-2', raw: 'Integrate with main loop', completed: false }
    ],
    comments: [
      { id: 'c1', author: 'sys', timestamp: '2026-08-05T10:00Z', text: 'Started initial scaffolding.' }
    ]
  },
  {
    id: 't2',
    raw: '(B) 2026-08-05 Provision new database cluster +infra @ops',
    completed: false,
    priority: 'B',
    creationDate: '2026-08-04',
    description: 'Scale up the PostgreSQL cluster to handle the new analytics load. Ensure pgBouncer is configured correctly.',
    subtasks: [],
    comments: []
  },
  {
    id: 't3',
    raw: 'x 2026-08-05 2026-08-01 Renew SSL certificates +infra @admin',
    completed: true,
    priority: null,
    creationDate: '2026-08-01',
    completionDate: '2026-08-05',
    description: 'Use certbot for automated renewal. Check cron jobs.',
    subtasks: [],
    comments: []
  },
  {
    id: 't4',
    raw: 'Update vimrc with new LSP configurations @personal',
    completed: false,
    priority: null,
    creationDate: '2026-08-06',
    description: 'Switching from coc.nvim to native Neovim LSP. Need to map standard keys (gd, K, etc).',
    subtasks: [],
    comments: []
  },
  {
    id: 't5',
    raw: '(C) Draft Q3 architecture review +docs @management',
    completed: false,
    priority: 'C',
    creationDate: '2026-08-02',
    description: 'Focus on the migration from legacy monolith to the new microservices architecture. Highlight cost savings.',
    subtasks: [],
    comments: [
      { id: 'c2', author: 'lead', timestamp: '2026-08-03T14:30Z', text: 'Make sure to include the AWS bill projections.' }
    ]
  },
  {
    id: 't6',
    raw: 'Buy coffee beans @errands',
    completed: false,
    priority: null,
    creationDate: '2026-08-06',
    description: 'Get the dark roast from the local roaster.',
    subtasks: [],
    comments: []
  }
];

let isInitialized = false;

export async function initDb() {
  if (isInitialized) return;
  
  await db.execute(`
    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      raw TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0,
      priority TEXT,
      creation_date TEXT,
      completion_date TEXT,
      description TEXT DEFAULT '',
      subtasks TEXT DEFAULT '[]',
      comments TEXT DEFAULT '[]'
    );
  `);

  const countRes = await db.execute('SELECT COUNT(*) as count FROM tasks');
  const count = Number(countRes.rows[0]?.count ?? 0);

  if (count === 0) {
    for (const task of initialTasks) {
      await db.execute({
        sql: `INSERT INTO tasks (id, raw, completed, priority, creation_date, completion_date, description, subtasks, comments)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        args: [
          task.id,
          task.raw,
          task.completed ? 1 : 0,
          task.priority,
          task.creationDate,
          task.completionDate || null,
          task.description || '',
          JSON.stringify(task.subtasks || []),
          JSON.stringify(task.comments || [])
        ]
      });
    }
  }

  isInitialized = true;
}

export async function getAllTasks(): Promise<Task[]> {
  await initDb();
  const res = await db.execute('SELECT * FROM tasks ORDER BY id ASC');
  return res.rows.map(row => {
    let subtasks = [];
    let comments = [];
    try {
      subtasks = JSON.parse(row.subtasks as string || '[]');
    } catch {
      subtasks = [];
    }
    try {
      comments = JSON.parse(row.comments as string || '[]');
    } catch {
      comments = [];
    }
    return {
      id: String(row.id),
      raw: String(row.raw),
      completed: Boolean(row.completed),
      priority: row.priority ? String(row.priority) : null,
      creationDate: String(row.creation_date || ''),
      completionDate: row.completion_date ? String(row.completion_date) : undefined,
      description: String(row.description || ''),
      subtasks,
      comments,
    };
  });
}

export async function insertTask(task: Task): Promise<Task> {
  await initDb();
  await db.execute({
    sql: `INSERT INTO tasks (id, raw, completed, priority, creation_date, completion_date, description, subtasks, comments)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      task.id,
      task.raw,
      task.completed ? 1 : 0,
      task.priority,
      task.creationDate,
      task.completionDate || null,
      task.description || '',
      JSON.stringify(task.subtasks || []),
      JSON.stringify(task.comments || [])
    ]
  });
  return task;
}

export async function updateTaskInDb(id: string, updates: Partial<Task>): Promise<Task | null> {
  await initDb();

  const existingRes = await db.execute({
    sql: 'SELECT * FROM tasks WHERE id = ?',
    args: [id]
  });

  if (existingRes.rows.length === 0) return null;

  const existing = existingRes.rows[0];
  
  let subtasks = existing.subtasks as string;
  let comments = existing.comments as string;

  if (updates.subtasks !== undefined) {
    subtasks = JSON.stringify(updates.subtasks);
  }
  if (updates.comments !== undefined) {
    comments = JSON.stringify(updates.comments);
  }

  const newRaw = updates.raw !== undefined ? updates.raw : String(existing.raw);
  const newCompleted = updates.completed !== undefined ? (updates.completed ? 1 : 0) : Number(existing.completed);
  const newPriority = updates.priority !== undefined ? updates.priority : (existing.priority ? String(existing.priority) : null);
  const newCreationDate = updates.creationDate !== undefined ? updates.creationDate : String(existing.creation_date || '');
  const newCompletionDate = updates.completionDate !== undefined ? updates.completionDate : (existing.completion_date ? String(existing.completion_date) : null);
  const newDescription = updates.description !== undefined ? updates.description : String(existing.description || '');

  await db.execute({
    sql: `UPDATE tasks SET raw = ?, completed = ?, priority = ?, creation_date = ?, completion_date = ?, description = ?, subtasks = ?, comments = ?
          WHERE id = ?`,
    args: [
      newRaw,
      newCompleted,
      newPriority,
      newCreationDate,
      newCompletionDate,
      newDescription,
      subtasks,
      comments,
      id
    ]
  });

  return {
    id,
    raw: newRaw,
    completed: Boolean(newCompleted),
    priority: newPriority,
    creationDate: newCreationDate,
    completionDate: newCompletionDate || undefined,
    description: newDescription,
    subtasks: JSON.parse(subtasks),
    comments: JSON.parse(comments)
  };
}

export async function deleteTaskFromDb(id: string): Promise<boolean> {
  await initDb();
  await db.execute({
    sql: 'DELETE FROM tasks WHERE id = ?',
    args: [id]
  });
  return true;
}
