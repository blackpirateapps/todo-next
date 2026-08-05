import { createClient, InValue } from '@libsql/client';
import { Task, Subtask, Comment } from '@/types/todo';
import { parseRawToStructured, buildRawFromStructured } from '@/utils/todoParser';

const url = process.env.TURSO_DATABASE_URL || 'file:todo.db';
const authToken = process.env.TURSO_AUTH_TOKEN;

export const db = createClient({
  url,
  authToken,
});

const initialTasksData = [
  {
    id: 't1',
    raw: '(A) 2026-08-06 Implement core parsing logic for +backend @dev due:2026-08-12',
    description: 'Need to write a robust regex parser that handles priorities (A-Z), dates, +projects, and @contexts natively without breaking on malformed strings. Reference the original todo.txt spec.',
    subtasks: [
      { id: 't1-1', title: 'Write unit tests for edge cases', raw: 'Write unit tests for edge cases', completed: true },
      { id: 't1-2', title: 'Integrate with main loop', raw: 'Integrate with main loop', completed: false }
    ],
    comments: [
      { id: 'c1', author: 'sys', timestamp: '2026-08-05T10:00Z', text: 'Started initial scaffolding.' }
    ]
  },
  {
    id: 't2',
    raw: '(B) 2026-08-05 Provision new database cluster +infra @ops due:2026-08-15',
    description: 'Scale up the PostgreSQL cluster to handle the new analytics load. Ensure pgBouncer is configured correctly.',
    subtasks: [],
    comments: []
  },
  {
    id: 't3',
    raw: 'x 2026-08-05 2026-08-01 Renew SSL certificates +infra @admin',
    description: 'Use certbot for automated renewal. Check cron jobs.',
    subtasks: [],
    comments: []
  },
  {
    id: 't4',
    raw: 'Update vimrc with new LSP configurations @personal',
    description: 'Switching from coc.nvim to native Neovim LSP. Need to map standard keys (gd, K, etc).',
    subtasks: [],
    comments: []
  },
  {
    id: 't5',
    raw: '(C) Draft Q3 architecture review +docs @management due:2026-08-20',
    description: 'Focus on the migration from legacy monolith to the new microservices architecture. Highlight cost savings.',
    subtasks: [],
    comments: [
      { id: 'c2', author: 'lead', timestamp: '2026-08-03T14:30Z', text: 'Make sure to include the AWS bill projections.' }
    ]
  },
  {
    id: 't6',
    raw: 'Buy coffee beans @errands',
    description: 'Get the dark roast from the local roaster.',
    subtasks: [],
    comments: []
  }
];

let isInitialized = false;

export async function initDb() {
  if (isInitialized) return;

  await db.execute('PRAGMA foreign_keys = ON;');

  // Create Relational Normalized Tables
  await db.execute(`
    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'open',
      priority TEXT,
      creation_date TEXT NOT NULL,
      completion_date TEXT,
      due_date TEXT,
      due_time TEXT,
      description TEXT DEFAULT ''
    );
  `);

  await db.execute(`
    CREATE TABLE IF NOT EXISTS task_projects (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      project TEXT NOT NULL,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
  `);

  await db.execute(`
    CREATE TABLE IF NOT EXISTS task_contexts (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      context TEXT NOT NULL,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
  `);

  await db.execute(`
    CREATE TABLE IF NOT EXISTS subtasks (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      title TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
  `);

  await db.execute(`
    CREATE TABLE IF NOT EXISTS comments (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      author TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      text TEXT NOT NULL,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
  `);

  // --- AUTOMATIC SCHEMA MIGRATION ---
  // Check if legacy 'tasks' table columns (e.g. 'raw') exist in database schema
  const tableInfo = await db.execute("PRAGMA table_info(tasks)");
  const hasRawColumn = tableInfo.rows.some(row => row.name === 'raw');

  if (hasRawColumn) {
    console.log('[DB Migration] Migrating legacy raw tasks schema to normalized relational tables...');
    const legacyTasksRes = await db.execute('SELECT * FROM tasks');
    
    // Create temp table for migration
    await db.execute(`
      CREATE TABLE tasks_normalized (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'open',
        priority TEXT,
        creation_date TEXT NOT NULL,
        completion_date TEXT,
        due_date TEXT,
        due_time TEXT,
        description TEXT DEFAULT ''
      );
    `);

    for (const legacy of legacyTasksRes.rows) {
      const rawStr = String(legacy.raw || '');
      const parsed = parseRawToStructured(rawStr, String(legacy.creation_date || ''));

      const normArgs: InValue[] = [
        String(legacy.id),
        parsed.title,
        legacy.completed ? 'completed' : 'open',
        parsed.priority ? String(parsed.priority) : null,
        parsed.creationDate,
        parsed.completionDate || (legacy.completion_date ? String(legacy.completion_date) : null),
        parsed.dueDate ? String(parsed.dueDate) : null,
        parsed.dueTime ? String(parsed.dueTime) : null,
        String(legacy.description || '')
      ];

      await db.execute({
        sql: `INSERT INTO tasks_normalized (id, title, status, priority, creation_date, completion_date, due_date, due_time, description)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        args: normArgs
      });

      // Migrate projects
      for (const p of parsed.projects) {
        await db.execute({
          sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
          args: [`tp-${legacy.id}-${p}`, String(legacy.id), p]
        });
      }

      // Migrate contexts
      for (const c of parsed.contexts) {
        await db.execute({
          sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
          args: [`tc-${legacy.id}-${c}`, String(legacy.id), c]
        });
      }

      // Migrate JSON subtasks if present
      try {
        const subtasksJson = JSON.parse(legacy.subtasks as string || '[]');
        for (const st of subtasksJson) {
          await db.execute({
            sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
            args: [st.id || `st-${Date.now()}`, String(legacy.id), st.raw || st.title || '', st.completed ? 1 : 0]
          });
        }
      } catch {}

      // Migrate JSON comments if present
      try {
        const commentsJson = JSON.parse(legacy.comments as string || '[]');
        for (const cm of commentsJson) {
          await db.execute({
            sql: 'INSERT INTO comments (id, task_id, author, timestamp, text) VALUES (?, ?, ?, ?, ?)',
            args: [cm.id || `cm-${Date.now()}`, String(legacy.id), cm.author || 'user', cm.timestamp || new Date().toISOString(), cm.text || '']
          });
        }
      } catch {}
    }

    // Drop legacy table and rename tasks_normalized -> tasks
    await db.execute('DROP TABLE tasks;');
    await db.execute('ALTER TABLE tasks_normalized RENAME TO tasks;');
    console.log('[DB Migration] Schema migration completed successfully.');
  }

  // Initial Seed if tasks table is empty
  const countRes = await db.execute('SELECT COUNT(*) as count FROM tasks');
  const count = Number(countRes.rows[0]?.count ?? 0);

  if (count === 0) {
    for (const initTask of initialTasksData) {
      const parsed = parseRawToStructured(initTask.raw);

      await db.execute({
        sql: `INSERT INTO tasks (id, title, status, priority, creation_date, completion_date, due_date, due_time, description)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        args: [
          initTask.id,
          parsed.title,
          parsed.completed ? 'completed' : 'open',
          parsed.priority ? String(parsed.priority) : null,
          parsed.creationDate,
          parsed.completionDate || null,
          parsed.dueDate || null,
          parsed.dueTime || null,
          initTask.description || ''
        ]
      });

      for (const p of parsed.projects) {
        await db.execute({
          sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
          args: [`tp-${initTask.id}-${p}`, initTask.id, p]
        });
      }

      for (const c of parsed.contexts) {
        await db.execute({
          sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
          args: [`tc-${initTask.id}-${c}`, initTask.id, c]
        });
      }

      for (const st of initTask.subtasks) {
        await db.execute({
          sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
          args: [st.id, initTask.id, st.raw, st.completed ? 1 : 0]
        });
      }

      for (const cm of initTask.comments) {
        await db.execute({
          sql: 'INSERT INTO comments (id, task_id, author, timestamp, text) VALUES (?, ?, ?, ?, ?)',
          args: [cm.id, initTask.id, cm.author, cm.timestamp, cm.text]
        });
      }
    }
  }

  isInitialized = true;
}

export async function getAllTasks(): Promise<Task[]> {
  await initDb();
  const tasksRes = await db.execute('SELECT * FROM tasks ORDER BY id ASC');
  const projectsRes = await db.execute('SELECT * FROM task_projects');
  const contextsRes = await db.execute('SELECT * FROM task_contexts');
  const subtasksRes = await db.execute('SELECT * FROM subtasks');
  const commentsRes = await db.execute('SELECT * FROM comments');

  // Map projects by task_id
  const projectsMap = new Map<string, string[]>();
  projectsRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = projectsMap.get(tid) || [];
    projectsMap.set(tid, [...list, String(row.project)]);
  });

  // Map contexts by task_id
  const contextsMap = new Map<string, string[]>();
  contextsRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = contextsMap.get(tid) || [];
    contextsMap.set(tid, [...list, String(row.context)]);
  });

  // Map subtasks by task_id
  const subtasksMap = new Map<string, Subtask[]>();
  subtasksRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = subtasksMap.get(tid) || [];
    const st: Subtask = {
      id: String(row.id),
      taskId: tid,
      title: String(row.title),
      raw: String(row.title),
      completed: Boolean(row.completed)
    };
    subtasksMap.set(tid, [...list, st]);
  });

  // Map comments by task_id
  const commentsMap = new Map<string, Comment[]>();
  commentsRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = commentsMap.get(tid) || [];
    const cm: Comment = {
      id: String(row.id),
      taskId: tid,
      author: String(row.author),
      timestamp: String(row.timestamp),
      text: String(row.text)
    };
    commentsMap.set(tid, [...list, cm]);
  });

  return tasksRes.rows.map(row => {
    const id = String(row.id);
    const title = String(row.title);
    const status = String(row.status) as 'open' | 'completed';
    const completed = status === 'completed';
    const priority = row.priority ? String(row.priority) : null;
    const creationDate = String(row.creation_date || '');
    const completionDate = row.completion_date ? String(row.completion_date) : undefined;
    const dueDate = row.due_date ? String(row.due_date) : undefined;
    const dueTime = row.due_time ? String(row.due_time) : undefined;
    const description = String(row.description || '');

    const projects = projectsMap.get(id) || [];
    const contexts = contextsMap.get(id) || [];
    const subtasks = subtasksMap.get(id) || [];
    const comments = commentsMap.get(id) || [];

    const raw = buildRawFromStructured({
      title,
      priority,
      creationDate,
      completionDate,
      dueDate,
      dueTime,
      completed,
      projects,
      contexts
    });

    return {
      id,
      title,
      raw,
      status,
      completed,
      priority,
      creationDate,
      completionDate,
      dueDate,
      dueTime,
      description,
      projects,
      contexts,
      subtasks,
      comments
    };
  });
}

export async function insertTask(task: Task): Promise<Task> {
  await initDb();
  const parsed = parseRawToStructured(task.raw, task.creationDate);

  const title = task.title || parsed.title;
  const status = (task.completed || parsed.completed) ? 'completed' : 'open';
  const priority = task.priority !== undefined ? task.priority : parsed.priority;
  const creationDate = parsed.creationDate;
  const completionDate = parsed.completionDate || task.completionDate || null;
  const dueDate = parsed.dueDate || task.dueDate || null;
  const dueTime = parsed.dueTime || task.dueTime || null;
  const description = task.description || '';

  await db.execute({
    sql: `INSERT INTO tasks (id, title, status, priority, creation_date, completion_date, due_date, due_time, description)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      task.id,
      title,
      status,
      priority ? String(priority) : null,
      creationDate,
      completionDate,
      dueDate,
      dueTime,
      description
    ]
  });

  // Save projects
  const projects = Array.from(new Set([...(task.projects || []), ...parsed.projects]));
  for (const p of projects) {
    await db.execute({
      sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
      args: [`tp-${task.id}-${p}`, task.id, p]
    });
  }

  // Save contexts
  const contexts = Array.from(new Set([...(task.contexts || []), ...parsed.contexts]));
  for (const c of contexts) {
    await db.execute({
      sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
      args: [`tc-${task.id}-${c}`, task.id, c]
    });
  }

  // Save subtasks
  for (const st of (task.subtasks || [])) {
    await db.execute({
      sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
      args: [st.id, task.id, st.title || st.raw, st.completed ? 1 : 0]
    });
  }

  // Save comments
  for (const cm of (task.comments || [])) {
    await db.execute({
      sql: 'INSERT INTO comments (id, task_id, author, timestamp, text) VALUES (?, ?, ?, ?, ?)',
      args: [cm.id || `cm-${Date.now()}`, task.id, cm.author, cm.timestamp, cm.text]
    });
  }

  const reconstructedRaw = buildRawFromStructured({
    title,
    priority,
    creationDate,
    completionDate: completionDate || undefined,
    dueDate: dueDate || undefined,
    dueTime: dueTime || undefined,
    completed: status === 'completed',
    projects,
    contexts
  });

  return {
    ...task,
    title,
    raw: reconstructedRaw,
    status,
    completed: status === 'completed',
    priority,
    creationDate,
    completionDate: completionDate || undefined,
    dueDate: dueDate || undefined,
    dueTime: dueTime || undefined,
    projects,
    contexts
  };
}

export async function updateTaskInDb(id: string, updates: Partial<Task>): Promise<Task | null> {
  await initDb();

  const existingRes = await db.execute({
    sql: 'SELECT * FROM tasks WHERE id = ?',
    args: [id]
  });

  if (existingRes.rows.length === 0) return null;

  const existingRow = existingRes.rows[0];

  let raw = updates.raw !== undefined ? updates.raw : undefined;
  let parsed = raw ? parseRawToStructured(raw, updates.creationDate || String(existingRow.creation_date)) : null;

  const newStatus = updates.completed !== undefined
    ? (updates.completed ? 'completed' : 'open')
    : (updates.status !== undefined ? updates.status : String(existingRow.status));

  const newTitle = updates.title !== undefined
    ? updates.title
    : (parsed ? parsed.title : String(existingRow.title));

  const newPriority = updates.priority !== undefined
    ? updates.priority
    : (parsed ? parsed.priority : (existingRow.priority ? String(existingRow.priority) : null));

  const newCreationDate = updates.creationDate !== undefined
    ? updates.creationDate
    : (parsed ? parsed.creationDate : String(existingRow.creation_date));

  const newCompletionDate = updates.completionDate !== undefined
    ? updates.completionDate
    : (parsed?.completionDate || (existingRow.completion_date ? String(existingRow.completion_date) : null));

  const newDueDate = updates.dueDate !== undefined
    ? updates.dueDate
    : (parsed ? parsed.dueDate : (existingRow.due_date ? String(existingRow.due_date) : null));

  const newDueTime = updates.dueTime !== undefined
    ? updates.dueTime
    : (parsed ? parsed.dueTime : (existingRow.due_time ? String(existingRow.due_time) : null));

  const newDescription = updates.description !== undefined
    ? updates.description
    : String(existingRow.description || '');

  const updateArgs: InValue[] = [
    newTitle,
    newStatus,
    newPriority ? String(newPriority) : null,
    newCreationDate,
    newCompletionDate || null,
    newDueDate || null,
    newDueTime || null,
    newDescription,
    id
  ];

  // Update tasks table
  await db.execute({
    sql: `UPDATE tasks SET title = ?, status = ?, priority = ?, creation_date = ?, completion_date = ?, due_date = ?, due_time = ?, description = ?
          WHERE id = ?`,
    args: updateArgs
  });

  // Update projects if provided or if raw changed
  let newProjects = updates.projects;
  if (parsed && !newProjects) newProjects = parsed.projects;
  if (newProjects !== undefined) {
    await db.execute({ sql: 'DELETE FROM task_projects WHERE task_id = ?', args: [id] });
    for (const p of newProjects) {
      await db.execute({
        sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
        args: [`tp-${id}-${p}`, id, p]
      });
    }
  } else {
    const prRes = await db.execute({ sql: 'SELECT project FROM task_projects WHERE task_id = ?', args: [id] });
    newProjects = prRes.rows.map(r => String(r.project));
  }

  // Update contexts if provided or if raw changed
  let newContexts = updates.contexts;
  if (parsed && !newContexts) newContexts = parsed.contexts;
  if (newContexts !== undefined) {
    await db.execute({ sql: 'DELETE FROM task_contexts WHERE task_id = ?', args: [id] });
    for (const c of newContexts) {
      await db.execute({
        sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
        args: [`tc-${id}-${c}`, id, c]
      });
    }
  } else {
    const cxRes = await db.execute({ sql: 'SELECT context FROM task_contexts WHERE task_id = ?', args: [id] });
    newContexts = cxRes.rows.map(r => String(r.context));
  }

  // Update subtasks if provided
  if (updates.subtasks !== undefined) {
    await db.execute({ sql: 'DELETE FROM subtasks WHERE task_id = ?', args: [id] });
    for (const st of updates.subtasks) {
      await db.execute({
        sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
        args: [st.id, id, st.title || st.raw, st.completed ? 1 : 0]
      });
    }
  }

  // Update comments if provided
  if (updates.comments !== undefined) {
    await db.execute({ sql: 'DELETE FROM comments WHERE task_id = ?', args: [id] });
    for (const cm of updates.comments) {
      await db.execute({
        sql: 'INSERT INTO comments (id, task_id, author, timestamp, text) VALUES (?, ?, ?, ?, ?)',
        args: [cm.id || `cm-${Date.now()}`, id, cm.author, cm.timestamp, cm.text]
      });
    }
  }

  // Fetch updated subtasks & comments
  const subRes = await db.execute({ sql: 'SELECT * FROM subtasks WHERE task_id = ?', args: [id] });
  const comRes = await db.execute({ sql: 'SELECT * FROM comments WHERE task_id = ?', args: [id] });

  const finalSubtasks: Subtask[] = subRes.rows.map(r => ({
    id: String(r.id),
    taskId: id,
    title: String(r.title),
    raw: String(r.title),
    completed: Boolean(r.completed)
  }));

  const finalComments: Comment[] = comRes.rows.map(r => ({
    id: String(r.id),
    taskId: id,
    author: String(r.author),
    timestamp: String(r.timestamp),
    text: String(r.text)
  }));

  const reconstructedRaw = buildRawFromStructured({
    title: newTitle,
    priority: newPriority,
    creationDate: newCreationDate,
    completionDate: newCompletionDate || undefined,
    dueDate: newDueDate || undefined,
    dueTime: newDueTime || undefined,
    completed: newStatus === 'completed',
    projects: newProjects,
    contexts: newContexts
  });

  return {
    id,
    title: newTitle,
    raw: reconstructedRaw,
    status: newStatus as 'open' | 'completed',
    completed: newStatus === 'completed',
    priority: newPriority,
    creationDate: newCreationDate,
    completionDate: newCompletionDate || undefined,
    dueDate: newDueDate || undefined,
    dueTime: newDueTime || undefined,
    description: newDescription,
    projects: newProjects,
    contexts: newContexts,
    subtasks: finalSubtasks,
    comments: finalComments
  };
}

export async function deleteTaskFromDb(id: string): Promise<boolean> {
  await initDb();
  await db.execute({ sql: 'DELETE FROM tasks WHERE id = ?', args: [id] });
  return true;
}
