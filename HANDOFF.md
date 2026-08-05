# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Universal Deletion Confirmation Modal (`ConfirmModal.tsx`)**:
  - Every deletion action across the entire app prompts the user for confirmation before executing:
    - Task deletions in `TaskList.tsx`.
    - Template deletions in `TemplateModal.tsx`.
    - Subtask, comment, project tag (`+proj`), and context tag (`@ctx`) deletions in `TaskDetails.tsx`.
- **Fixed Vercel 404 Logging & Asset Caching**:
  - Generated missing icon assets: `favicon.ico`, `apple-touch-icon.png`, `apple-touch-icon-precomposed.png`, `icon-192.png`, and `icon-512.png`.
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
│   │   ├── tasks/route.ts & [id]/route.ts
│   │   └── templates/route.ts, [id]/route.ts, [id]/instantiate/route.ts
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── CalendarView.tsx
│   ├── CommandInput.tsx
│   ├── ConfirmModal.tsx              # Universal deletion confirmation dialog
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
│   └── db.ts
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
