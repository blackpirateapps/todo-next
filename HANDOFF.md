# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **First-Class Task Templates System**:
  - **Relational Tables & Migration**: `templates`, `template_projects`, `template_contexts`, `template_subtasks` in Turso DB with 3 production starter templates.
  - **Dynamic Token Engine**: Token interpolation for `{today}`, `{due:+Nd}`, `{due:+Nw}`, `{due:+Nm}`, and `{time:HH:MM}`.
  - **Terminal Commands**: `:template` (open modal), `:use <name>` (instantiate template), `:template save <name>` (convert task to template).
  - **UI Template Gallery & Builder**: `TemplateModal.tsx` for searching, creating, editing, and instantiating templates with live preview.
  - **Inspector Action**: `[Save Template]` button in `TaskDetails.tsx`.
- **Advanced Sorting & Filtering in List View**:
  - **Sorting**: Creation Date, Due Date, Name/Title, Priority (Ascending `[ASC ↑]` & Descending `[DESC ↓]`).
  - **Filtering**: Status (`All`, `Open`, `Completed`), Priority (`All`, `(A)`, `(B)`, `(C)`, `None`), Period (`Month / Year`).
- **Editable Projects (+proj), Contexts (@ctx), and Task Name in Inspector**.
- **Interactive Syntax Guide (`[?] Syntax`)**: Cheat sheet (`SyntaxGuideModal.tsx`) detailing `todo.txt` syntax rules.
- **Project Title & Branding**: App title set to **Todo Next** across metadata, manifest, and PWA icons.
- **Full PWA & Offline Support**: Web App Manifest (`manifest.json`), custom icons, Service Worker (`sw.js`), `localStorage` caching, and real-time sync status indicator (`[Synced ✓]`, `[Syncing...]`, `[Unsaved (N)]`, `[Offline - N pending]`).
- **Drag & Drop Task Rescheduling**: Native HTML5 Drag and Drop for Desktop and Touch gesture tracking for Mobile.
- **Weekly 24-Hour View with Y-Axis Time Slots**: Hourly time slots (`00:00` to `23:00`) plotted on the Y-axis.

---

## 🏗 System Architecture & Directory Structure

```
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   └── route.ts              # GET (auth status), POST (login), DELETE (logout)
│   │   ├── tasks/
│   │   │   ├── route.ts              # GET (all tasks), POST (create task)
│   │   │   └── [id]/route.ts          # PATCH (update task), DELETE (remove task)
│   │   └── templates/
│   │       ├── route.ts              # GET (all templates), POST (create template)
│   │       └── [id]/
│   │           ├── route.ts          # PATCH (update template), DELETE (remove template)
│   │           └── instantiate/
│   │               └── route.ts      # POST (instantiate task from template ID)
│   ├── globals.css                   # Tailwind v4 directives & font configurations
│   ├── layout.tsx                    # Main HTML layout wrapper with metadata title "Todo Next" & SW script
│   └── page.tsx                      # Main container managing view mode, drag-and-drop, templates, offline queue & API sync
├── components/
│   ├── CalendarView.tsx              # Monthly & 24-hour Weekly calendar grid with Drag & Drop (Desktop & Mobile)
│   ├── CommandInput.tsx              # Terminal prompt (> input, :add, :template, :use, [Templates] & [?] Syntax)
│   ├── FormattedText.tsx             # todo.txt syntax highlighter (+proj, @ctx, (A), due:YYYY-MM-DD)
│   ├── LoginScreen.tsx               # Retro terminal-styled login screen for password protection
│   ├── Sidebar.tsx                   # Filter sidebar listing unique +projects and @contexts (with mobile drawer)
│   ├── StatusBar.tsx                 # Vim/Unix status bar with sync status indicator ([Synced], [Unsaved], [Offline])
│   ├── SyntaxGuideModal.tsx          # Modal popup cheat sheet explaining todo.txt syntax rules
│   ├── TaskDetails.tsx               # Inspector drawer with editable task name, projects, contexts, dates, description, subtasks, comments & [Save Template]
│   ├── TaskList.tsx                  # Tabular task view with multi-field sorting (Asc/Desc) & filtering (Status, Pri, Month/Year)
│   └── TemplateModal.tsx             # Template Gallery & Builder modal with live token preview
├── lib/
│   ├── auth.ts                       # Password verification & session cookie helpers
│   └── db.ts                         # Turso DB (@libsql/client) normalized schema, migration & CRUD helpers for tasks & templates
├── public/
│   ├── manifest.json                 # Web App Manifest for PWA installation
│   ├── sw.js                         # Service Worker for offline asset caching
│   └── icon.jpg                      # 512x512 PWA App Icon
├── types/
│   └── todo.ts                       # TypeScript interfaces for Task, Subtask, Comment, Template, and TemplateSubtask
├── utils/
│   ├── dateUtils.ts                  # Calendar date grid generators (getMonthDays, getWeekDays, ISO format)
│   ├── templateEngine.ts             # Dynamic token resolution engine ({today}, {due:+Nd}, {time:HH:MM}, {var:Name})
│   └── todoParser.ts                 # Structured parser & serializer converting between raw todo.txt and DB columns
├── TEMPLATE_FEATURE_PLAN.md          # Complete Production Implementation Plan for Task Templates
├── .env.example                      # Example environment variables (APP_PASSWORD, Turso DB)
└── HANDOFF.md                        # AI Handoff Documentation (this document)
```
