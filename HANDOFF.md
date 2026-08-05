# AI Handoff Document - Todo-Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), and dual theme support (Dark/Light mode).

Recently updated with **Password Authentication**, **Mobile Responsiveness**, **Editable Creation & Due Dates**, modular components, and backend persistence powered by **Turso DB** (`@libsql/client`).

---

## 🏗 System Architecture & Directory Structure

```
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   └── route.ts              # GET (auth status), POST (login), DELETE (logout)
│   │   └── tasks/
│   │       ├── route.ts              # GET (all tasks), POST (create task)
│   │       └── [id]/
│   │           └── route.ts          # PATCH (update task fields/subtasks/comments), DELETE (remove task)
│   ├── globals.css                   # Tailwind v4 directives & font configurations
│   ├── layout.tsx                    # Main HTML layout wrapper
│   └── page.tsx                      # Main container managing auth state, mobile drawers & API sync
├── components/
│   ├── CommandInput.tsx              # Terminal prompt (> input, :add command & mobile filter drawer toggle)
│   ├── FormattedText.tsx             # todo.txt syntax highlighter (+proj, @ctx, (A), due:YYYY-MM-DD)
│   ├── LoginScreen.tsx               # Retro terminal-styled login screen for password protection
│   ├── Sidebar.tsx                   # Filter sidebar listing unique +projects and @contexts (with mobile drawer)
│   ├── StatusBar.tsx                 # Vim/Unix status bar displaying mode, task counters, theme toggle & logout
│   ├── TaskDetails.tsx               # Inspector drawer with editable creation date, due date, description, subtasks, comments
│   └── TaskList.tsx                  # Tabular task view optimized for touch & desktop
├── lib/
│   ├── auth.ts                       # Password verification & session cookie helpers
│   └── db.ts                         # Turso DB (@libsql/client) initialization, migration & CRUD helpers
├── types/
│   └── todo.ts                       # TypeScript interfaces for Task, Subtask, and Comment
├── utils/
│   └── todoParser.ts                 # Parsing & updating raw todo.txt text with creationDate & due:YYYY-MM-DD
├── .env.example                      # Example environment variables (APP_PASSWORD, Turso DB)
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```

---

## 🔒 Password Protection (`APP_PASSWORD`)
Authentication is controlled by the `APP_PASSWORD` environment variable.

- **Enabled:** If `APP_PASSWORD` is set in `.env.local` or environment, the app displays `LoginScreen` and protects `/api/tasks` endpoints with HTTP-only session cookies.
- **Disabled:** If `APP_PASSWORD` is omitted or empty, authentication is bypassed automatically.

---

## 🗄 Database & Persistence Layer (Turso DB)

Persistence is handled by `@libsql/client`, which supports both local LibSQL SQLite files and cloud-hosted Turso DB clusters.

### Environment Setup (`.env.local`)
```env
APP_PASSWORD=your_secret_password
TURSO_DATABASE_URL=libsql://your-database-name-org.turso.io
TURSO_AUTH_TOKEN=your-turso-auth-token
```

> **Fallback Mode:** If `TURSO_DATABASE_URL` is omitted, `lib/db.ts` automatically falls back to a local SQLite database file (`file:todo.db`), ensuring out-of-the-box local operation without external dependencies.

---

## 📅 Date & Due Date Support (`due:YYYY-MM-DD`)

- **Creation Date**: Editable directly in the Inspector (`TaskDetails.tsx`). Updating it modifies the leading `YYYY-MM-DD` date in the task's `raw` string.
- **Due Date**: Native `todo.txt` tag support (`due:YYYY-MM-DD`). Editable or clearable in the Inspector. Syncs dynamically with `raw` text and receives dedicated badge highlighting in `FormattedText.tsx`.

---

## 📱 Mobile Responsiveness

- **Header / Prompt**: Scaled text and padding to prevent auto-zoom on mobile inputs.
- **Mobile Filter Drawer**: Added `[Filters]` button on small screens to open a slide-over drawer for `+projects` and `@contexts`.
- **Inspector Drawer**: Full-screen overlay with `[← Back]` button for mobile viewports.
- **Touch-Friendly Controls**: Increased touch targets for checkboxes, delete buttons, and list rows.
