# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Serverless Vercel 500 Error Prevention & Health Diagnostics**:
  - Fixed read-only filesystem crash on Vercel when `TURSO_DATABASE_URL` is omitted by defaulting to `file:/tmp/todo.db` in serverless environments (`process.env.VERCEL`).
  - Added comprehensive `console.error()` logging with stack traces, request context, and environment status across all API routes (`/api/tasks`, `/api/templates`, `/api/auth`).
  - Added diagnostic endpoint `GET /api/health` returning database connection status and serverless environment variables.
- **Universal Deletion Confirmation Modal (`ConfirmModal.tsx`)**:
  - Confirmation prompts before deleting tasks, templates, subtasks, comments, project tags (`+proj`), or context tags (`@ctx`).
- **Fixed Vercel 404 Logging & Asset Caching**:
  - Icons generated: `favicon.ico`, `apple-touch-icon.png`, `apple-touch-icon-precomposed.png`, `icon-192.png`, and `icon-512.png`.
- **Subtask Progress Bar Component (`SubtaskProgressBar.tsx`)**:
  - Displays a visual progress bar (`[2/4] 50%`) for tasks with subtasks across **List View**, **Calendar View**, and **Inspector Drawer**.
- **First-Class Task Templates System**:
  - Relational tables & dynamic token engine (`{today}`, `{due:+Nd}`, `{due:+Nw}`, `{due:+Nm}`, `{time:HH:MM}`).
  - Terminal commands `:template`, `:use <name>`, `:template save <name>` and `TemplateModal.tsx` gallery & builder.
- **Native Android & Tablet Application (`flutter_app/`)**:
  - Built with **Flutter 3.44+ & Dart** for native Android performance on phones and tablets.
  - Multi-column adaptive tablet dashboard layout (≥600dp) rendering Sidebar + Task Workspace + Inspector Drawer side-by-side.
  - Full `todo.txt` syntax parser, recurrence spawning engine, template token generator, calendar view, inspector drawer, and terminal command bar.
  - Automated GitHub Actions workflow (`.github/workflows/build-flutter-apk.yml`) building release APK artifacts on push.

---

## 🏗 System Architecture & Directory Structure

```
├── .github/
│   └── workflows/
│       └── build-flutter-apk.yml     # GitHub Actions CI workflow building Android APK
├── app/
│   ├── api/
│   │   ├── auth/route.ts
│   │   ├── health/route.ts           # Diagnostic endpoint for DB & Vercel serverless health
│   │   ├── recurring/route.ts        # Endpoint for listing recurring schedules
│   │   ├── tasks/
│   │   └── templates/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
├── flutter_app/                       # Native Flutter Android Application
│   ├── android/                      # Native Android Gradle configuration
│   ├── lib/
│   │   ├── models/                   # Task, Subtask, Comment, Template, RecurrenceRule
│   │   ├── screens/                  # HomeScreen (Adaptive Phone & Tablet layout)
│   │   ├── services/                 # StorageService (Offline-first SharedPreferences & SQLite)
│   │   ├── theme/                    # AppTheme (Terminal Dark & Light typography)
│   │   ├── utils/                    # todo_parser, recurrence_engine, template_engine, date_utils
│   │   └── widgets/                  # FormattedText, TaskList, CalendarView, InspectorDrawer, CommandInput
│   └── pubspec.yaml
├── lib/
├── public/
├── types/
├── utils/
├── ANDROID_APP_FEATURE_PLAN.md
├── HANDOFF.md
└── RECURRING_TASKS_FEATURE_PLAN.md
```
