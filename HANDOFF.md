# AI Handoff Document - Todo-Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Normalized Relational DB Schema & Migration**: Structured multi-table schema (`tasks`, `task_projects`, `task_contexts`, `subtasks`, `comments`) with automated legacy schema migration.
- **Drag & Drop Task Rescheduling**: Native HTML5 Drag and Drop for Desktop and Touch gesture tracking for Mobile.
- **Weekly 24-Hour View with Y-Axis Time Slots**: Hourly time slots (`00:00` to `23:00`) plotted on the Y-axis.
- **Click-to-Create Tasks**: Clicking empty calendar slots pre-fills the command prompt with specific date (`due:YYYY-MM-DD`) and time (`time:HH:MM`).
- **Password Authentication** (`APP_PASSWORD`).
- **Mobile Responsiveness** (Sidebar drawer, full-screen inspector, touch sizing).

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
│   └── page.tsx                      # Main container managing view mode, drag-and-drop & API sync
├── components/
│   ├── CalendarView.tsx              # Monthly & 24-hour Weekly calendar grid with Drag & Drop (Desktop & Mobile)
│   ├── CommandInput.tsx              # Terminal prompt (> input, :add command & List/Calendar view switcher)
│   ├── FormattedText.tsx             # todo.txt syntax highlighter (+proj, @ctx, (A), due:YYYY-MM-DD)
│   ├── LoginScreen.tsx               # Retro terminal-styled login screen for password protection
│   ├── Sidebar.tsx                   # Filter sidebar listing unique +projects and @contexts (with mobile drawer)
│   ├── StatusBar.tsx                 # Vim/Unix status bar displaying mode, task counters, theme toggle & logout
│   ├── TaskDetails.tsx               # Inspector drawer with editable creation date, due date, description, subtasks, comments
│   └── TaskList.tsx                  # Tabular task view optimized for touch & desktop
├── lib/
│   ├── auth.ts                       # Password verification & session cookie helpers
│   └── db.ts                         # Turso DB (@libsql/client) normalized schema, migration & CRUD helpers
├── types/
│   └── todo.ts                       # TypeScript interfaces for Task, Subtask, and Comment
├── utils/
│   ├── dateUtils.ts                  # Calendar date grid generators (getMonthDays, getWeekDays, ISO format)
│   └── todoParser.ts                 # Structured parser & serializer converting between raw todo.txt and DB columns
├── .env.example                      # Example environment variables (APP_PASSWORD, Turso DB)
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```

---

## 🗄 Database Schema & Automatic Migration

### Normalized Relational Tables (`lib/db.ts`)
- **`tasks`**: `id`, `title`, `status`, `priority`, `creation_date`, `completion_date`, `due_date`, `due_time`, `description`
- **`task_projects`**: `id`, `task_id`, `project` (Foreign Key -> `tasks.id` ON DELETE CASCADE)
- **`task_contexts`**: `id`, `task_id`, `context` (Foreign Key -> `tasks.id` ON DELETE CASCADE)
- **`subtasks`**: `id`, `task_id`, `title`, `completed` (Foreign Key -> `tasks.id` ON DELETE CASCADE)
- **`comments`**: `id`, `task_id`, `author`, `timestamp`, `text` (Foreign Key -> `tasks.id` ON DELETE CASCADE)

### Migration Plan
Upon initialization (`initDb()`), the system inspects the `tasks` table via `PRAGMA table_info(tasks)`:
- If a legacy schema is detected (e.g. single `raw` text column or JSON text columns), it creates a temporary table `tasks_normalized`, parses existing raw task strings into structured columns, moves projects, contexts, subtasks, and comments into dedicated relational tables, and renames `tasks_normalized` to `tasks`.
- Future deployments migrate automatically without data loss.

---

## 🖐 Drag & Drop & Click-to-Create

- **Desktop & Mobile Drag & Drop**: Drag any task card onto a new date cell (in Month View) or specific time slot cell (in Week View) to automatically reschedule the task. Dragging updates `due_date` and `due_time` in DB and `raw` text for UI highlighting.
- **24-Hour Week View Y-Axis**: Weekly View displays hours `00:00` through `23:00` along the Y-axis. Tasks with `time:HH:MM` or due dates align automatically to their hour slot.
- **Click-to-Create**:
  - In **Month View**: Clicking an empty space in a date cell pre-fills the prompt with `:add (A) New task due:YYYY-MM-DD time:HH:MM `.
  - In **Week View**: Clicking an hourly slot pre-fills the prompt with `:add (A) New task due:YYYY-MM-DD time:HH:MM ` for that exact hour slot.
