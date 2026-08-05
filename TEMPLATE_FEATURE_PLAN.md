# Production Implementation Plan: Task Templates Feature (`todo-next`)

## 📌 Executive Summary
The **Task Templates** feature brings first-class, Unix-inspired automation to `todo-next`. It allows users to define, manage, and instantiate complex multi-step tasks (with priorities, projects, contexts, subtasks, descriptions, and relative due dates) using both terminal commands (`:template`, `:use`) and a rich visual Template Gallery.

---

## 🏛 1. Data Architecture & Database Schema (Turso DB)

To maintain database normalization, templates will be stored in relational tables matching the existing `tasks` architecture.

### Schema Definition (`lib/db.ts`)

```sql
-- 1. Main Templates Table
CREATE TABLE IF NOT EXISTS templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  raw_template TEXT NOT NULL,
  description TEXT DEFAULT '',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- 2. Template Projects (Junction Table)
CREATE TABLE IF NOT EXISTS template_projects (
  id TEXT PRIMARY KEY,
  template_id TEXT NOT NULL,
  project TEXT NOT NULL,
  FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);

-- 3. Template Contexts (Junction Table)
CREATE TABLE IF NOT EXISTS template_contexts (
  id TEXT PRIMARY KEY,
  template_id TEXT NOT NULL,
  context TEXT NOT NULL,
  FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);

-- 4. Template Subtasks Table
CREATE TABLE IF NOT EXISTS template_subtasks (
  id TEXT PRIMARY KEY,
  template_id TEXT NOT NULL,
  title TEXT NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (template_id) REFERENCES templates(id) ON DELETE CASCADE
);
```

### Pre-seeded Starter Templates
Upon database initialization, if `COUNT(templates) === 0`, 3 production starter templates will be automatically seeded:
1. **Sprint Release Checklist**: `(A) Deploy release v1.0 +infra @ops due:{due:+2d} time:10:00`
2. **Weekly Code Review**: `(B) Conduct weekly team code review +dev @review due:{due:+5d}`
3. **Inbox Zero & Daily Prep**: `(C) Morning prep and inbox zero @personal`

---

## ⚡ 2. Dynamic Token & Variable Specification (`utils/templateEngine.ts`)

Templates support smart dynamic tokens that are evaluated at runtime when a task is instantiated.

| Token Syntax | Resolution Rule | Example Output |
| :--- | :--- | :--- |
| `{today}` | Current date in `YYYY-MM-DD` | `2026-08-06` |
| `{due:+Nd}` | `N` days from current date | `{due:+3d}` → `due:2026-08-09` |
| `{due:+Nw}` | `N` weeks from current date | `{due:+1w}` → `due:2026-08-13` |
| `{due:+Nm}` | `N` months from current date | `{due:+1m}` → `due:2026-09-06` |
| `{time:HH:MM}` | Time tag in `HH:MM` | `time:14:30` |
| `{var:Name}` | Interactive user prompt before instantiation | Replaced by user input |

### Interpolation Algorithm
```ts
export function instantiateTemplate(
  template: Template,
  varOverrides?: Record<string, string>
): { task: Partial<Task>; subtasks: Subtask[] }
```

---

## 🛠 3. API Specification

| Endpoint | Method | Description | Auth Protected |
| :--- | :--- | :--- | :--- |
| `/api/templates` | `GET` | Fetch all templates with projects, contexts, & subtasks | Yes |
| `/api/templates` | `POST` | Create new template or save from task ID | Yes |
| `/api/templates/[id]` | `PATCH` | Update template fields or subtasks | Yes |
| `/api/templates/[id]` | `DELETE` | Delete a template | Yes |
| `/api/templates/[id]/instantiate` | `POST` | Resolve tokens and insert instantiated task to DB | Yes |

---

## 🖥 4. User Experience & UI Component Specs

### A. Terminal Command Integration (`CommandInput.tsx`)
- `:template` → Opens the Template Manager Modal.
- `:use <template_name_or_id>` → Instantiates template immediately with default tokens.
- `:template save <name>` → Converts current selected task into a template.

### B. Template Gallery & Editor Modal (`TemplateModal.tsx`)
- **Gallery Tab**: Searchable grid of template cards displaying raw syntax preview, projects, contexts, and subtask count.
- **`[Use Template]` Button**: One-click task generation.
- **Template Builder**: Visual editor to build templates with live preview showing resolved dates.

### C. Inspector Drawer Integration (`TaskDetails.tsx`)
- Add **`[Save as Template]`** button in the Inspector header.
- Prompts for template name and creates a template with current subtasks, description, projects, and contexts.

### D. Navigation Integration
- Add **`[Templates]`** button next to `[?] Syntax` in the command prompt header.

---

## 📱 5. PWA, Offline Caching & Unsaved Sync Strategy

1. **LocalStorage Caching**: `todo_next_cached_templates` stores templates locally for offline access.
2. **Pending Queue**: Operations performed offline are added to `todo_next_pending_template_queue`.
3. **Sync Indicator**: Status bar displays `[Unsaved Templates]` or `[Syncing...]` and automatically flushes queue when connectivity returns.

---

## 🧪 6. Execution & Testing Verification Plan

1. **Database Schema Verification**: Run TypeScript type check (`npx tsc --noEmit`) and DB table creation.
2. **Token Interpolation Unit Testing**: Verify relative date math (`{due:+3d}`, `{due:+1w}`).
3. **Next.js Production Build**: Execute `npm run build` to ensure static & dynamic route compilation.
4. **Git Commit & Push**: Commit changes to repository.
