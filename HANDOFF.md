# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Advanced Sorting & Filtering in List View**:
  - **Sorting**: Creation Date, Due Date, Name/Title, Priority (Ascending `[ASC ↑]` & Descending `[DESC ↓]`).
  - **Filtering**: Status (`All`, `Open`, `Completed`), Priority (`All`, `(A)`, `(B)`, `(C)`, `None`), Period (`Month / Year`).
  - Works globally on All Tasks as well as Project- and Context-specific filtered views.
- **Editable Projects (+proj) & Contexts (@ctx) in Inspector**: Add or delete project/context tags directly in `TaskDetails.tsx`, updating `task_projects` and `task_contexts` DB tables.
- **Interactive Syntax Guide (`[?] Syntax`)**: Built-in cheat sheet (`SyntaxGuideModal.tsx`) detailing `todo.txt` rules for priorities, projects, contexts, due dates, and times.
- **Editable Task Name in Inspector**: Task Name / raw string is directly editable at the top of the Inspector (`TaskDetails.tsx`).
- **Project Title & Branding**: App title set to **Todo Next** across layout metadata, PWA web app manifest, and icons.
- **Full PWA & Offline Support**: Web App Manifest (`manifest.json`), custom PWA app icons, Service Worker (`sw.js`), and offline task caching.
- **Unsaved Changes & Sync Indicator**: Real-time status badge in `StatusBar.tsx` (`[Synced ✓]`, `[Syncing...]`, `[Unsaved (N)]`, `[Offline - N pending]`) with background queue syncing.
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
│   ├── layout.tsx                    # Main HTML layout wrapper with metadata title "Todo Next" & SW script
│   └── page.tsx                      # Main container managing view mode, drag-and-drop, offline queue & API sync
├── components/
│   ├── CalendarView.tsx              # Monthly & 24-hour Weekly calendar grid with Drag & Drop (Desktop & Mobile)
│   ├── CommandInput.tsx              # Terminal prompt (> input, :add command, [?] Syntax guide & List/Calendar view switcher)
│   ├── FormattedText.tsx             # todo.txt syntax highlighter (+proj, @ctx, (A), due:YYYY-MM-DD)
│   ├── LoginScreen.tsx               # Retro terminal-styled login screen for password protection
│   ├── Sidebar.tsx                   # Filter sidebar listing unique +projects and @contexts (with mobile drawer)
│   ├── StatusBar.tsx                 # Vim/Unix status bar with sync status indicator ([Synced], [Unsaved], [Offline])
│   ├── SyntaxGuideModal.tsx          # Modal popup cheat sheet explaining todo.txt syntax rules
│   ├── TaskDetails.tsx               # Inspector drawer with editable task name, projects, contexts, dates, description, subtasks, comments
│   └── TaskList.tsx                  # Tabular task view with multi-field sorting (Asc/Desc) & filtering (Status, Pri, Month/Year)
├── lib/
│   ├── auth.ts                       # Password verification & session cookie helpers
│   └── db.ts                         # Turso DB (@libsql/client) normalized schema, migration & CRUD helpers
├── public/
│   ├── manifest.json                 # Web App Manifest for PWA installation
│   ├── sw.js                         # Service Worker for offline asset caching
│   └── icon.jpg                      # 512x512 PWA App Icon
├── types/
│   └── todo.ts                       # TypeScript interfaces for Task, Subtask, and Comment
├── utils/
│   ├── dateUtils.ts                  # Calendar date grid generators (getMonthDays, getWeekDays, ISO format)
│   └── todoParser.ts                 # Structured parser & serializer converting between raw todo.txt and DB columns
├── .env.example                      # Example environment variables (APP_PASSWORD, Turso DB)
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```
