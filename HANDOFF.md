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
- **Flagship Recurring Tasks System (`rec:`)**:
  - Full `todo.txt` `rec:` tag parsing (`rec:1d`, `rec:2w`, `rec:1m`, `rec:1y`, `rec:weekday`, `rec:mwf`).
  - Supports **Relative Recurrence** (from completion date) and **Strict Recurrence** (`rec:strict:1w` / `rec:+1w` from original due date).
  - Automated Completion Spawning Engine: completing a task logs the historical instance and automatically spawns the next open occurrence with fresh subtask checklist (`[ ]`).
  - Inspector Drawer Recurrence Control Card with presets, mode toggles, `:skip` cycle button, and `:rec <rule>` terminal commands.
  - Calendar View Future Recurrence Projections (dimmed ghost chips on future dates).

---

## 🏗 System Architecture & Directory Structure

```
├── app/
│   ├── api/
│   │   ├── auth/route.ts
│   │   ├── health/route.ts           # Diagnostic endpoint for DB & Vercel serverless health
│   │   ├── recurring/route.ts        # Endpoint for listing recurring schedules
│   │   ├── tasks/
│   │   │   ├── route.ts
│   │   │   └── [id]/
│   │   │       ├── route.ts
│   │   │       ├── complete/route.ts # Complete & spawn next recurrence instance
│   │   │       └── skip/route.ts     # Skip occurrence cycle
│   │   └── templates/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── CalendarView.tsx              # Includes future recurrence projections
│   ├── CommandInput.tsx              # :rec, :skip, :recurring terminal commands
│   ├── ConfirmModal.tsx
│   ├── FormattedText.tsx
│   ├── LoginScreen.tsx
│   ├── Sidebar.tsx
│   ├── StatusBar.tsx
│   ├── SubtaskProgressBar.tsx
│   ├── SyntaxGuideModal.tsx          # rec: syntax guide documentation
│   ├── TaskDetails.tsx              # Recurrence pattern control card & presets
│   ├── TaskList.tsx                 # Visual terminal recurrence badges ([🔄 rec:1w], [⚡ strict:3d])
│   └── TemplateModal.tsx
├── lib/
│   ├── auth.ts
│   └── db.ts                         # Turso DB client with recurrence schema migrations
├── public/
├── types/
│   └── todo.ts                       # Extended with RecurrenceRule & Task recurrence types
├── utils/
│   ├── dateUtils.ts
│   ├── recurrenceEngine.ts           # Recurrence rule parser, due date math & spawning engine
│   ├── templateEngine.ts
│   └── todoParser.ts                 # Extended todo.txt rec: tag parser
├── HANDOFF.md
└── RECURRING_TASKS_FEATURE_PLAN.md
```
