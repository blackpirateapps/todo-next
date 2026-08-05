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

---

## 🏗 System Architecture & Directory Structure

```
├── app/
│   ├── api/
│   │   ├── auth/route.ts
│   │   ├── health/route.ts           # Diagnostic endpoint for DB & Vercel serverless health
│   │   ├── tasks/route.ts & [id]/route.ts
│   │   └── templates/route.ts, [id]/route.ts, [id]/instantiate/route.ts
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── CalendarView.tsx
│   ├── CommandInput.tsx
│   ├── ConfirmModal.tsx
│   ├── FormattedText.tsx
│   ├── LoginScreen.tsx
│   ├── Sidebar.tsx
│   ├── StatusBar.tsx
│   ├── SubtaskProgressBar.tsx
│   ├── SyntaxGuideModal.tsx
│   ├── TaskDetails.tsx
│   ├── TaskList.tsx
│   └── TemplateModal.tsx
├── lib/
│   ├── auth.ts
│   └── db.ts                         # Turso DB / LibSQL client with /tmp/todo.db serverless fallback
├── public/
│   ├── apple-touch-icon.png
│   ├── favicon.ico
│   ├── icon-192.png
│   ├── icon-512.png
│   ├── icon.jpg
│   ├── manifest.json
│   └── sw.js
├── types/
│   └── todo.ts
├── utils/
│   ├── dateUtils.ts
│   ├── templateEngine.ts
│   └── todoParser.ts
└── HANDOFF.md
```
