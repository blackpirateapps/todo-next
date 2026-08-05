# AI Handoff Document - Todo-Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), and dual theme support (Dark/Light mode).

Recently refactored from a monolithic `page.tsx` into clean, maintainable modular components with full backend persistence powered by **Turso DB** (`@libsql/client`).

---

## 🏗 System Architecture & Directory Structure

```
├── app/
│   ├── api/
│   │   └── tasks/
│   │       ├── route.ts              # GET (all tasks), POST (create task)
│   │       └── [id]/
│   │           └── route.ts          # PATCH (update task fields/subtasks/comments), DELETE (remove task)
│   ├── globals.css                   # Tailwind v4 directives & font configurations
│   ├── layout.tsx                    # Main HTML layout wrapper
│   └── page.tsx                      # Modular main container managing state & API sync
├── components/
│   ├── CommandInput.tsx              # Terminal prompt (> input & :add command parsing)
│   ├── FormattedText.tsx             # todo.txt syntax highlighter (priorities, projects, contexts)
│   ├── Sidebar.tsx                   # Filter sidebar listing unique +projects and @contexts
│   ├── StatusBar.tsx                 # Vim/Unix status bar displaying mode, task counters & theme toggle
│   ├── TaskDetails.tsx               # Inspector drawer with editable description, subtasks, and comments
│   └── TaskList.tsx                  # Tabular task view with status toggle and row selection
├── lib/
│   └── db.ts                         # Turso DB (@libsql/client) initialization, migration & CRUD helpers
├── types/
│   └── todo.ts                       # TypeScript interfaces for Task, Subtask, and Comment
├── .env.example                      # Example environment variables for Turso DB connection
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```

---

## 🗄 Database & Persistence Layer (Turso DB)

Persistence is handled by `@libsql/client`, which supports both local LibSQL SQLite files and cloud-hosted Turso DB clusters.

### Environment Setup (`.env.local`)
To connect to a live Turso DB cluster in production, add the following environment variables:

```env
TURSO_DATABASE_URL=libsql://your-database-name-org.turso.io
TURSO_AUTH_TOKEN=your-turso-auth-token
```

> **Fallback Mode:** If `TURSO_DATABASE_URL` is omitted, `lib/db.ts` automatically falls back to a local SQLite database file (`file:todo.db`), ensuring out-of-the-box local operation without external dependencies.

### Database Schema (`tasks` table)
```sql
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
```

---

## ⚙️ Inspector Functionality (Editable Fields)

The right-side Inspector panel (`TaskDetails.tsx`) allows interactive editing for:

1. **Description**:
   - Click `[Edit]` or click the description body to switch to a textarea.
   - Save updates directly to Turso DB via `PATCH /api/tasks/[id]`.

2. **Subtasks**:
   - **Toggle**: Click `[ ]` / `[x]` to toggle subtask completion status.
   - **Add**: Enter new subtask text in `+ add subtask...` input and press Enter.
   - **Edit**: Click subtask text to edit inline.
   - **Delete**: Click `[x]` next to any subtask to remove it.

3. **Comments**:
   - **Add**: Specify author (`@author`) and comment body, then click `Comment`.
   - **Edit**: Click comment text to edit inline.
   - **Delete**: Click `[x]` to remove a comment.

---

## 🚀 Key Commands & NPM Scripts

- `npm run dev`: Start Next.js development server
- `npm run build`: Build production application bundle (Next.js 16 App Router)
- `npm run start`: Run production server
- `npm run lint`: Run ESLint checks
- `npx tsc --noEmit`: Run TypeScript type checking

---

## 🛠 Next.js 16 & Breaking API Conventions
Per `AGENTS.md` and Next.js 16 conventions:
- Dynamic API route parameters in `app/api/tasks/[id]/route.ts` treat `params` as a Promise: `{ params }: { params: Promise<{ id: string }> }`. Always `await params` before accessing route variables.
