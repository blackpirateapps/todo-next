# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Subtask Progress Bar Component (`SubtaskProgressBar.tsx`)**:
  - Automatically displays a visual progress bar (`[2/4] 50%`) for any task with subtasks across **List View**, **Calendar View**, and **Inspector Drawer**.
- **First-Class Task Templates System**:
  - **Relational Tables & Migration**: `templates`, `template_projects`, `template_contexts`, `template_subtasks` in Turso DB with 3 production starter templates.
  - **Dynamic Token Engine**: Token interpolation for `{today}`, `{due:+Nd}`, `{due:+Nw}`, `{due:+Nm}`, and `{time:HH:MM}`.
  - **Terminal Commands**: `:template` (open modal), `:use <name>` (instantiate template), `:template save <name>` (convert task to template).
  - **UI Template Gallery & Builder**: `TemplateModal.tsx` for searching, creating, editing, and instantiating templates with live preview.
- **Advanced Sorting & Filtering in List View**:
  - **Sorting**: Creation Date, Due Date, Name/Title, Priority (Ascending `[ASC ↑]` & Descending `[DESC ↓]`).
  - **Filtering**: Status (`All`, `Open`, `Completed`), Priority (`All`, `(A)`, `(B)`, `(C)`, `None`), Period (`Month / Year`).
- **Editable Projects (+proj), Contexts (@ctx), and Task Name in Inspector**.
- **Interactive Syntax Guide (`[?] Syntax`)**: Cheat sheet (`SyntaxGuideModal.tsx`) detailing `todo.txt` syntax rules.
- **Project Title & Branding**: App title set to **Todo Next** across metadata, manifest, and PWA icons.
- **Full PWA & Offline Support**: Web App Manifest (`manifest.json`), custom icons, Service Worker (`sw.js`), `localStorage` caching, and real-time sync status indicator (`[Synced ✓]`, `[Syncing...]`, `[Unsaved (N)]`, `[Offline - N pending]`).
- **Drag & Drop Task Rescheduling**: Native HTML5 Drag and Drop for Desktop and Touch gesture tracking for Mobile.

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
│   ├── FormattedText.tsx
│   ├── LoginScreen.tsx
│   ├── Sidebar.tsx
│   ├── StatusBar.tsx
│   ├── SubtaskProgressBar.tsx        # Visual subtask progress bar component
│   ├── SyntaxGuideModal.tsx
│   ├── TaskDetails.tsx
│   ├── TaskList.tsx
│   └── TemplateModal.tsx
├── lib/
│   ├── auth.ts
│   └── db.ts
├── public/
│   ├── manifest.json
│   ├── sw.js
│   └── icon.jpg
├── types/
│   └── todo.ts
├── utils/
│   ├── dateUtils.ts
│   ├── templateEngine.ts
│   └── todoParser.ts
└── HANDOFF.md
```
