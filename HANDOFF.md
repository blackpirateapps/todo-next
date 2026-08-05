# AI Handoff Document - Todo-Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Interactive Calendar View** (Monthly & Weekly grids, Due Date vs Created Date mode)
- **Password Authentication** (`APP_PASSWORD`)
- **Mobile Responsiveness** (Sidebar drawer, full-screen inspector, touch sizing)
- **Editable Creation & Due Dates**
- **Turso DB Persistence** (`@libsql/client`)

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
│   └── page.tsx                      # Main container managing view mode, auth state, mobile drawers & API sync
├── components/
│   ├── CalendarView.tsx              # Monthly & Weekly calendar grid plotting tasks by Due or Creation date
│   ├── CommandInput.tsx              # Terminal prompt (> input, :add command & List/Calendar view switcher)
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
│   ├── dateUtils.ts                  # Calendar date grid generators (getMonthDays, getWeekDays, ISO format)
│   └── todoParser.ts                 # Parsing & updating raw todo.txt text with creationDate & due:YYYY-MM-DD
├── .env.example                      # Example environment variables (APP_PASSWORD, Turso DB)
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```

---

## 📅 Calendar View (`CalendarView.tsx`)
- **View Modes**: Toggle between **Month** view (42-day calendar grid) and **Week** view (7-day expanded column grid).
- **Date Source Switcher**:
  - `[Due Date]`: Plot tasks by `due:YYYY-MM-DD` tag.
  - `[Created Date]`: Plot tasks by task creation date (`task.creationDate`).
- **Interactive Tasks**: Tasks render as interactive chips on their respective day cells with status toggles (`[ ]` / `[x]`), syntax highlighting, and click-to-inspect.
- **Date Navigation**: Previous `[<]`, Next `[>]`, and `[Today]` jump buttons.

---

## 🔒 Password Protection (`APP_PASSWORD`)
Authentication is controlled by the `APP_PASSWORD` environment variable.

- **Enabled:** If `APP_PASSWORD` is set in `.env.local` or environment, the app displays `LoginScreen` and protects `/api/tasks` endpoints with HTTP-only session cookies.
- **Disabled:** If `APP_PASSWORD` is omitted or empty, authentication is bypassed automatically.

---

## 🗄 Database & Persistence Layer (Turso DB)
Persistence is handled by `@libsql/client`, supporting both local SQLite files (`file:todo.db`) and cloud-hosted Turso DB clusters (`TURSO_DATABASE_URL` + `TURSO_AUTH_TOKEN`).
