import { createClient, InValue } from '@libsql/client';
import { Task, Subtask, Comment, Template, TemplateSubtask } from '@/types/todo';
import { parseRawToStructured, buildRawFromStructured } from '@/utils/todoParser';
import { instantiateTaskFromTemplate } from '@/utils/templateEngine';

const isVercel = Boolean(process.env.VERCEL || process.env.AWS_LAMBDA_FUNCTION_NAME);
let url = process.env.TURSO_DATABASE_URL;

if (!url) {
  if (isVercel) {
    url = 'file:/tmp/todo.db';
  } else {
    url = 'file:todo.db';
  }
}

const authToken = process.env.TURSO_AUTH_TOKEN;

console.log('[DB Init] Configured database client:', {
  url,
  hasAuthToken: Boolean(authToken),
  isVercel
});

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

const starterTemplatesData = [
  {
    id: 'tmpl-1',
    name: 'Sprint Release Checklist',
    rawTemplate: '(A) Deploy release v1.0 +infra @ops due:{due:+2d} {time:10:00}',
    description: 'Checklist for deploying a production release candidate.',
    subtasks: ['Run unit tests & E2E suite', 'Tag git release candidate', 'Apply database migrations', 'Monitor metrics on dashboard']
  },
  {
    id: 'tmpl-2',
    name: 'Weekly Code Review',
    rawTemplate: '(B) Conduct weekly team code review +dev @review due:{due:+5d}',
    description: 'Weekly team peer review workflow.',
    subtasks: ['Check open pull requests', 'Audit dependencies for security updates', 'Post feedback comments']
  },
  {
    id: 'tmpl-3',
    name: 'Inbox Zero & Daily Prep',
    rawTemplate: '(C) Morning prep and inbox zero @personal',
    description: 'Daily morning organization routine.',
    subtasks: ['Review priority A tasks', 'Clear unread emails & messages', 'Set daily goal focus']
  }
];

let isInitialized = false;

export async function initDb() {
  if (isInitialized) return;

  try {
    await db.execute('PRAGMA foreign_keys = ON;');

    // Create Users Table for SaaS
    await db.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE,
        is_migrated INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      );
    `);

    // Create Relational Tasks Tables
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
        description TEXT DEFAULT '',
        recurrence TEXT DEFAULT NULL,
        parent_recurring_id TEXT DEFAULT NULL,
        user_id TEXT DEFAULT NULL
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

    // Create Relational Templates Tables
    await db.execute(`
      CREATE TABLE IF NOT EXISTS templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        raw_template TEXT NOT NULL,
        description TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        user_id TEXT DEFAULT NULL
      );
    `);

    await db.execute(`
      CREATE TABLE IF NOT EXISTS template_projects (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        project TEXT NOT NULL,
        FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
      );
    `);

    await db.execute(`
      CREATE TABLE IF NOT EXISTS template_contexts (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        context TEXT NOT NULL,
        FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
      );
    `);

    await db.execute(`
      CREATE TABLE IF NOT EXISTS template_subtasks (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        title TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
      );
    `);

    // --- AUTOMATIC TASKS SCHEMA MIGRATION ---
    const tableInfo = await db.execute("PRAGMA table_info(tasks)");
    const hasRawColumn = tableInfo.rows.some(row => row.name === 'raw');

    if (hasRawColumn) {
      const legacyTasksRes = await db.execute('SELECT * FROM tasks');
      
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
          description TEXT DEFAULT '',
          recurrence TEXT DEFAULT NULL,
          parent_recurring_id TEXT DEFAULT NULL,
          user_id TEXT DEFAULT NULL
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
          String(legacy.description || ''),
          parsed.recurrence ? String(parsed.recurrence) : null,
          null,
          legacy.user_id ? String(legacy.user_id) : null
        ];

        await db.execute({
          sql: `INSERT INTO tasks_normalized (id, title, status, priority, creation_date, completion_date, due_date, due_time, description, recurrence, parent_recurring_id, user_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          args: normArgs
        });

        for (const p of parsed.projects) {
          await db.execute({
            sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
            args: [`tp-${legacy.id}-${p}`, String(legacy.id), p]
          });
        }

        for (const c of parsed.contexts) {
          await db.execute({
            sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
            args: [`tc-${legacy.id}-${c}`, String(legacy.id), c]
          });
        }

        try {
          const subtasksJson = JSON.parse(legacy.subtasks as string || '[]');
          for (const st of subtasksJson) {
            await db.execute({
              sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
              args: [st.id || `st-${Date.now()}`, String(legacy.id), st.raw || st.title || '', st.completed ? 1 : 0]
            });
          }
        } catch {}

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

      await db.execute('DROP TABLE tasks;');
      await db.execute('ALTER TABLE tasks_normalized RENAME TO tasks;');
    }

    const currentCols = await db.execute("PRAGMA table_info(tasks)");
    if (!currentCols.rows.some(row => row.name === 'recurrence')) {
      await db.execute("ALTER TABLE tasks ADD COLUMN recurrence TEXT DEFAULT NULL;");
    }
    if (!currentCols.rows.some(row => row.name === 'parent_recurring_id')) {
      await db.execute("ALTER TABLE tasks ADD COLUMN parent_recurring_id TEXT DEFAULT NULL;");
    }
    if (!currentCols.rows.some(row => row.name === 'user_id')) {
      await db.execute("ALTER TABLE tasks ADD COLUMN user_id TEXT DEFAULT NULL;");
    }

    const currentTmplCols = await db.execute("PRAGMA table_info(templates)");
    if (!currentTmplCols.rows.some(row => row.name === 'user_id')) {
      await db.execute("ALTER TABLE templates ADD COLUMN user_id TEXT DEFAULT NULL;");
    }

    // Initial Seed for Tasks if empty
    const countRes = await db.execute('SELECT COUNT(*) as count FROM tasks');
    const count = Number(countRes.rows[0]?.count ?? 0);

    if (count === 0) {
      for (const initTask of initialTasksData) {
        const parsed = parseRawToStructured(initTask.raw);

        await db.execute({
          sql: `INSERT INTO tasks (id, title, status, priority, creation_date, completion_date, due_date, due_time, description, user_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)`,
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

    // Initial Seed for Templates if empty
    const tmplCountRes = await db.execute('SELECT COUNT(*) as count FROM templates');
    const tmplCount = Number(tmplCountRes.rows[0]?.count ?? 0);

    if (tmplCount === 0) {
      const nowStr = new Date().toISOString();
      for (const t of starterTemplatesData) {
        const parsed = parseRawToStructured(t.rawTemplate);

        await db.execute({
          sql: `INSERT INTO templates (id, name, raw_template, description, created_at, updated_at, user_id)
                VALUES (?, ?, ?, ?, ?, ?, NULL)`,
          args: [t.id, t.name, t.rawTemplate, t.description, nowStr, nowStr]
        });

        for (const p of parsed.projects) {
          await db.execute({
            sql: 'INSERT INTO template_projects (id, template_id, project) VALUES (?, ?, ?)',
            args: [`tmplp-${t.id}-${p}`, t.id, p]
          });
        }

        for (const c of parsed.contexts) {
          await db.execute({
            sql: 'INSERT INTO template_contexts (id, template_id, context) VALUES (?, ?, ?)',
            args: [`tmplc-${t.id}-${c}`, t.id, c]
          });
        }

        for (let i = 0; i < t.subtasks.length; i++) {
          await db.execute({
            sql: 'INSERT INTO template_subtasks (id, template_id, title, position) VALUES (?, ?, ?, ?)',
            args: [`tmpls-${t.id}-${i}`, t.id, t.subtasks[i], i]
          });
        }
      }
    }

    isInitialized = true;
  } catch (err: any) {
    console.error('[DB Init Failed]:', {
      message: err?.message,
      stack: err?.stack,
      cause: err?.cause,
      url
    });
    throw err;
  }
}

// --- USER MANAGEMENT ---

export async function registerUserInDb(userId: string, email: string, username?: string) {
  await initDb();
  const now = new Date().toISOString();
  await db.execute({
    sql: `INSERT OR IGNORE INTO users (id, email, username, is_migrated, created_at)
          VALUES (?, ?, ?, 1, ?)`,
    args: [userId, email, username || email.split('@')[0], now]
  });
}

// --- TASK CRUD OPERATIONS ---

export async function getAllTasks(userId?: string): Promise<Task[]> {
  await initDb();
  let sql = 'SELECT * FROM tasks ORDER BY id ASC';
  const args: InValue[] = [];

  if (userId) {
    sql = 'SELECT * FROM tasks WHERE user_id = ? OR user_id IS NULL ORDER BY id ASC';
    args.push(userId);
  }

  const tasksRes = await db.execute({ sql, args });
  const projectsRes = await db.execute('SELECT * FROM task_projects');
  const contextsRes = await db.execute('SELECT * FROM task_contexts');
  const subtasksRes = await db.execute('SELECT * FROM subtasks');
  const commentsRes = await db.execute('SELECT * FROM comments');

  const projectsMap = new Map<string, string[]>();
  projectsRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = projectsMap.get(tid) || [];
    projectsMap.set(tid, [...list, String(row.project)]);
  });

  const contextsMap = new Map<string, string[]>();
  contextsRes.rows.forEach(row => {
    const tid = String(row.task_id);
    const list = contextsMap.get(tid) || [];
    contextsMap.set(tid, [...list, String(row.context)]);
  });

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

    const recurrence = row.recurrence ? String(row.recurrence) : undefined;
    const parentRecurringId = row.parent_recurring_id ? String(row.parent_recurring_id) : undefined;

    const raw = buildRawFromStructured({
      title,
      priority,
      creationDate,
      completionDate,
      dueDate,
      dueTime,
      recurrence,
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
      recurrence,
      parentRecurringId,
      projects,
      contexts,
      subtasks,
      comments
    };
  });
}

export async function insertTask(task: Task, userId?: string): Promise<Task> {
  await initDb();
  const parsed = parseRawToStructured(task.raw, task.creationDate);

  const title = task.title || parsed.title;
  const status = (task.completed || parsed.completed) ? 'completed' : 'open';
  const priority = task.priority !== undefined ? task.priority : parsed.priority;
  const creationDate = parsed.creationDate;
  const completionDate = parsed.completionDate || task.completionDate || null;
  const dueDate = parsed.dueDate || task.dueDate || null;
  const dueTime = parsed.dueTime || task.dueTime || null;
  const recurrence = task.recurrence || parsed.recurrence || null;
  const parentRecurringId = task.parentRecurringId || null;
  const description = task.description || '';

  await db.execute({
    sql: `INSERT INTO tasks (id, title, status, priority, creation_date, completion_date, due_date, due_time, description, recurrence, parent_recurring_id, user_id)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      task.id,
      title,
      status,
      priority ? String(priority) : null,
      creationDate,
      completionDate,
      dueDate,
      dueTime,
      description,
      recurrence,
      parentRecurringId,
      userId || null
    ]
  });

  const projects = Array.from(new Set([...(task.projects || []), ...parsed.projects]));
  for (const p of projects) {
    await db.execute({
      sql: 'INSERT INTO task_projects (id, task_id, project) VALUES (?, ?, ?)',
      args: [`tp-${task.id}-${p}`, task.id, p]
    });
  }

  const contexts = Array.from(new Set([...(task.contexts || []), ...parsed.contexts]));
  for (const c of contexts) {
    await db.execute({
      sql: 'INSERT INTO task_contexts (id, task_id, context) VALUES (?, ?, ?)',
      args: [`tc-${task.id}-${c}`, task.id, c]
    });
  }

  for (const st of (task.subtasks || [])) {
    await db.execute({
      sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
      args: [st.id, task.id, st.title || st.raw, st.completed ? 1 : 0]
    });
  }

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
    recurrence: recurrence || undefined,
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
    recurrence: recurrence || undefined,
    parentRecurringId: parentRecurringId || undefined,
    projects,
    contexts
  };
}

export async function updateTaskInDb(id: string, updates: Partial<Task>, userId?: string): Promise<Task | null> {
  await initDb();

  let sql = 'SELECT * FROM tasks WHERE id = ?';
  const args: InValue[] = [id];

  if (userId) {
    sql = 'SELECT * FROM tasks WHERE id = ? AND (user_id = ? OR user_id IS NULL)';
    args.push(userId);
  }

  const existingRes = await db.execute({ sql, args });

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

  const newRecurrence = updates.recurrence !== undefined
    ? updates.recurrence
    : (parsed?.recurrence !== undefined ? parsed.recurrence : (existingRow.recurrence ? String(existingRow.recurrence) : null));

  const newParentRecurringId = updates.parentRecurringId !== undefined
    ? updates.parentRecurringId
    : (existingRow.parent_recurring_id ? String(existingRow.parent_recurring_id) : null);

  const updateArgs: InValue[] = [
    newTitle,
    newStatus,
    newPriority ? String(newPriority) : null,
    newCreationDate,
    newCompletionDate || null,
    newDueDate || null,
    newDueTime || null,
    newDescription,
    newRecurrence || null,
    newParentRecurringId || null,
    id
  ];

  await db.execute({
    sql: `UPDATE tasks SET title = ?, status = ?, priority = ?, creation_date = ?, completion_date = ?, due_date = ?, due_time = ?, description = ?, recurrence = ?, parent_recurring_id = ?
          WHERE id = ?`,
    args: updateArgs
  });

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

  if (updates.subtasks !== undefined) {
    await db.execute({ sql: 'DELETE FROM subtasks WHERE task_id = ?', args: [id] });
    for (const st of updates.subtasks) {
      await db.execute({
        sql: 'INSERT INTO subtasks (id, task_id, title, completed) VALUES (?, ?, ?, ?)',
        args: [st.id, id, st.title || st.raw, st.completed ? 1 : 0]
      });
    }
  }

  if (updates.comments !== undefined) {
    await db.execute({ sql: 'DELETE FROM comments WHERE task_id = ?', args: [id] });
    for (const cm of updates.comments) {
      await db.execute({
        sql: 'INSERT INTO comments (id, task_id, author, timestamp, text) VALUES (?, ?, ?, ?, ?)',
        args: [cm.id || `cm-${Date.now()}`, id, cm.author, cm.timestamp, cm.text]
      });
    }
  }

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
    recurrence: newRecurrence || undefined,
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
    recurrence: newRecurrence || undefined,
    parentRecurringId: newParentRecurringId || undefined,
    projects: newProjects,
    contexts: newContexts,
    subtasks: finalSubtasks,
    comments: finalComments
  };
}

export async function deleteTaskFromDb(id: string, userId?: string): Promise<boolean> {
  await initDb();
  let sql = 'DELETE FROM tasks WHERE id = ?';
  const args: InValue[] = [id];

  if (userId) {
    sql = 'DELETE FROM tasks WHERE id = ? AND (user_id = ? OR user_id IS NULL)';
    args.push(userId);
  }

  await db.execute({ sql, args });
  return true;
}

// --- TEMPLATE CRUD OPERATIONS ---

export async function getAllTemplates(userId?: string): Promise<Template[]> {
  await initDb();
  let sql = 'SELECT * FROM templates ORDER BY created_at DESC';
  const args: InValue[] = [];

  if (userId) {
    sql = 'SELECT * FROM templates WHERE user_id = ? OR user_id IS NULL ORDER BY created_at DESC';
    args.push(userId);
  }

  const tmplRes = await db.execute({ sql, args });
  const projRes = await db.execute('SELECT * FROM template_projects');
  const ctxRes = await db.execute('SELECT * FROM template_contexts');
  const subRes = await db.execute('SELECT * FROM template_subtasks ORDER BY position ASC');

  const projMap = new Map<string, string[]>();
  projRes.rows.forEach(r => {
    const tid = String(r.template_id);
    const list = projMap.get(tid) || [];
    projMap.set(tid, [...list, String(r.project)]);
  });

  const ctxMap = new Map<string, string[]>();
  ctxRes.rows.forEach(r => {
    const tid = String(r.template_id);
    const list = ctxMap.get(tid) || [];
    ctxMap.set(tid, [...list, String(r.context)]);
  });

  const subMap = new Map<string, TemplateSubtask[]>();
  subRes.rows.forEach(r => {
    const tid = String(r.template_id);
    const list = subMap.get(tid) || [];
    const st: TemplateSubtask = {
      id: String(r.id),
      templateId: tid,
      title: String(r.title),
      position: Number(r.position)
    };
    subMap.set(tid, [...list, st]);
  });

  return tmplRes.rows.map(r => {
    const id = String(r.id);
    const rawTemplate = String(r.raw_template);
    const parsed = parseRawToStructured(rawTemplate);

    const projects = Array.from(new Set([...(projMap.get(id) || []), ...parsed.projects]));
    const contexts = Array.from(new Set([...(ctxMap.get(id) || []), ...parsed.contexts]));

    return {
      id,
      name: String(r.name),
      rawTemplate,
      description: String(r.description || ''),
      createdAt: String(r.created_at),
      updatedAt: String(r.updated_at),
      projects,
      contexts,
      subtasks: subMap.get(id) || []
    };
  });
}

export async function insertTemplate(template: Template, userId?: string): Promise<Template> {
  await initDb();
  const now = new Date().toISOString();
  const parsed = parseRawToStructured(template.rawTemplate);

  await db.execute({
    sql: `INSERT INTO templates (id, name, raw_template, description, created_at, updated_at, user_id)
          VALUES (?, ?, ?, ?, ?, ?, ?)`,
    args: [
      template.id,
      template.name,
      template.rawTemplate,
      template.description || '',
      template.createdAt || now,
      template.updatedAt || now,
      userId || null
    ]
  });

  const projects = Array.from(new Set([...(template.projects || []), ...parsed.projects]));
  for (const p of projects) {
    await db.execute({
      sql: 'INSERT INTO template_projects (id, template_id, project) VALUES (?, ?, ?)',
      args: [`tmplp-${template.id}-${p}`, template.id, p]
    });
  }

  const contexts = Array.from(new Set([...(template.contexts || []), ...parsed.contexts]));
  for (const c of contexts) {
    await db.execute({
      sql: 'INSERT INTO template_contexts (id, template_id, context) VALUES (?, ?, ?)',
      args: [`tmplc-${template.id}-${c}`, template.id, c]
    });
  }

  for (let i = 0; i < (template.subtasks || []).length; i++) {
    const st = template.subtasks[i];
    await db.execute({
      sql: 'INSERT INTO template_subtasks (id, template_id, title, position) VALUES (?, ?, ?, ?)',
      args: [st.id || `tmpls-${template.id}-${i}`, template.id, st.title, i]
    });
  }

  return {
    ...template,
    projects,
    contexts,
    createdAt: template.createdAt || now,
    updatedAt: template.updatedAt || now
  };
}

export async function updateTemplateInDb(id: string, updates: Partial<Template>, userId?: string): Promise<Template | null> {
  await initDb();
  const now = new Date().toISOString();

  let sql = 'SELECT * FROM templates WHERE id = ?';
  const args: InValue[] = [id];

  if (userId) {
    sql = 'SELECT * FROM templates WHERE id = ? AND (user_id = ? OR user_id IS NULL)';
    args.push(userId);
  }

  const existingRes = await db.execute({ sql, args });
  if (existingRes.rows.length === 0) return null;
  const existing = existingRes.rows[0];

  const name = updates.name !== undefined ? updates.name : String(existing.name);
  const rawTemplate = updates.rawTemplate !== undefined ? updates.rawTemplate : String(existing.raw_template);
  const description = updates.description !== undefined ? updates.description : String(existing.description || '');

  await db.execute({
    sql: `UPDATE templates SET name = ?, raw_template = ?, description = ?, updated_at = ? WHERE id = ?`,
    args: [name, rawTemplate, description, now, id]
  });

  const parsed = parseRawToStructured(rawTemplate);

  let projects = updates.projects;
  if (!projects) projects = parsed.projects;
  if (projects !== undefined) {
    await db.execute({ sql: 'DELETE FROM template_projects WHERE template_id = ?', args: [id] });
    for (const p of projects) {
      await db.execute({
        sql: 'INSERT INTO template_projects (id, template_id, project) VALUES (?, ?, ?)',
        args: [`tmplp-${id}-${p}`, id, p]
      });
    }
  }

  let contexts = updates.contexts;
  if (!contexts) contexts = parsed.contexts;
  if (contexts !== undefined) {
    await db.execute({ sql: 'DELETE FROM template_contexts WHERE template_id = ?', args: [id] });
    for (const c of contexts) {
      await db.execute({
        sql: 'INSERT INTO template_contexts (id, template_id, context) VALUES (?, ?, ?)',
        args: [`tmplc-${id}-${c}`, id, c]
      });
    }
  }

  if (updates.subtasks !== undefined) {
    await db.execute({ sql: 'DELETE FROM template_subtasks WHERE template_id = ?', args: [id] });
    for (let i = 0; i < updates.subtasks.length; i++) {
      const st = updates.subtasks[i];
      await db.execute({
        sql: 'INSERT INTO template_subtasks (id, template_id, title, position) VALUES (?, ?, ?, ?)',
        args: [st.id || `tmpls-${id}-${i}`, id, st.title, i]
      });
    }
  }

  const subRes = await db.execute({ sql: 'SELECT * FROM template_subtasks WHERE template_id = ? ORDER BY position ASC', args: [id] });
  const finalSubtasks: TemplateSubtask[] = subRes.rows.map(r => ({
    id: String(r.id),
    templateId: id,
    title: String(r.title),
    position: Number(r.position)
  }));

  return {
    id,
    name,
    rawTemplate,
    description,
    createdAt: String(existing.created_at),
    updatedAt: now,
    projects: projects || [],
    contexts: contexts || [],
    subtasks: finalSubtasks
  };
}

export async function deleteTemplateFromDb(id: string, userId?: string): Promise<boolean> {
  await initDb();
  let sql = 'DELETE FROM templates WHERE id = ?';
  const args: InValue[] = [id];

  if (userId) {
    sql = 'DELETE FROM templates WHERE id = ? AND (user_id = ? OR user_id IS NULL)';
    args.push(userId);
  }

  await db.execute({ sql, args });
  return true;
}

export async function instantiateTaskFromTemplateId(
  templateId: string,
  varOverrides: Record<string, string> = {},
  userId?: string
): Promise<Task | null> {
  const templates = await getAllTemplates(userId);
  const tmpl = templates.find(t => t.id === templateId || t.name.toLowerCase() === templateId.toLowerCase());
  if (!tmpl) return null;

  const { newTask } = instantiateTaskFromTemplate(tmpl, varOverrides);
  return await insertTask(newTask, userId);
}
