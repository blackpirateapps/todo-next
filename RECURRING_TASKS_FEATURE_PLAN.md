# Production Implementation Plan: Flagship Recurring Tasks Feature (`todo-next`)

## 📌 Executive Summary
The **Recurring Tasks** feature upgrades `todo-next` into a power-user productivity powerhouse. Built on the standard Unix `todo.txt` `rec:` spec (and extended for modern scheduling), it automates repetitive workflows with zero friction. It supports both **relative recurrence** (due date calculated from completion date) and **strict recurrence** (due date calculated from original due date), subtask resetting, occurrence skipping, visual terminal badges, calendar projections, and full offline PWA sync.

---

## 🏛 1. Data Architecture & Database Schema (Turso DB)

To support recurring tasks, the `tasks` table in `lib/db.ts` will be migrated to include recurrence metadata.

### A. Database Schema Migration (`lib/db.ts`)
```sql
-- Add recurrence column to main tasks table
ALTER TABLE tasks ADD COLUMN recurrence TEXT DEFAULT NULL;
ALTER TABLE tasks ADD COLUMN parent_recurring_id TEXT DEFAULT NULL;
```

### B. TypeScript Interface Extensions (`types/todo.ts`)
```ts
export type RecurrenceUnit = 'd' | 'w' | 'm' | 'y' | 'weekday' | 'mwf';
export type RecurrenceMode = 'completion' | 'strict'; // relative to completion vs original due date

export interface RecurrenceRule {
  raw: string;                 // e.g. "rec:1w", "rec:strict:3d", "rec:+2w"
  interval: number;            // e.g. 1, 3, 2
  unit: RecurrenceUnit;        // 'd' | 'w' | 'm' | 'y' | 'weekday' | 'mwf'
  mode: RecurrenceMode;        // 'completion' (default) | 'strict'
}

export interface Task {
  id: string;
  title: string;
  raw: string;
  status: 'open' | 'completed';
  completed: boolean;
  priority: string | null;
  creationDate: string;
  completionDate?: string;
  dueDate?: string;
  dueTime?: string;
  description: string;
  recurrence?: string;         // e.g. "rec:1w" or "rec:strict:2d"
  parentRecurringId?: string;  // ID of origin recurring task
  projects: string[];
  contexts: string[];
  subtasks: Subtask[];
  comments: Comment[];
}
```

---

## ⚡ 2. Parser & Recurrence Logic Engine (`utils/recurrenceEngine.ts` & `utils/todoParser.ts`)

### A. `todo.txt` Syntax Support
The parser will recognize `rec:` tags inside `raw` task strings:

| Syntax | Description | Example Next Due Calculation |
| :--- | :--- | :--- |
| `rec:1d`, `rec:3d` | Every N days (relative to completion date) | Completed Aug 6 → Next due Aug 7 |
| `rec:1w`, `rec:2w` | Every N weeks (relative to completion date) | Completed Aug 6 → Next due Aug 13 |
| `rec:1m`, `rec:6m` | Every N months (same day of month) | Completed Aug 6 → Next due Sept 6 |
| `rec:1y` | Every N years | Completed Aug 6, 2026 → Next due Aug 6, 2027 |
| `rec:weekday` | Every weekday (Mon-Fri) | Completed Fri Aug 7 → Next due Mon Aug 10 |
| `rec:strict:1w` or `rec:+1w` | Strict recurrence (calculated from original `due:`) | Due Aug 1, completed Aug 6 → Next due Aug 8 |

### B. Recurrence Algorithm Engine
```ts
export function parseRecurrenceRule(rawTag: string): RecurrenceRule | null;
export function calculateNextDueDate(
  currentDueDate: string | undefined,
  completionDate: string,
  rule: RecurrenceRule
): { nextDueDate: string; nextDueTime?: string };

export function spawnNextRecurrenceInstance(
  completedTask: Task,
  completionDate: string
): Task;
```

### C. Completion Spawning Strategy
When a user completes a recurring task (`completed: true`):
1. **Preserve History**: The current task is marked `completed` with `completionDate = today` and saved to the database.
2. **Spawn Active Instance**: A new `open` task instance is created:
   - **ID**: Fresh `t${Date.now()}`
   - **Creation Date**: `today`
   - **Due Date**: Calculated `nextDueDate` (preserving `dueTime` if present)
   - **Priority, Title, Projects, Contexts, Description**: Inherited from parent task
   - **Subtasks**: Cloned from parent, with `completed: false` for a fresh checklist!
   - **Recurrence Tag**: Preserved (`rec:...`)
   - **Parent Link**: `parentRecurringId = completedTask.id`

---

## 🛠 3. API & Backend Specification

| Endpoint | Method | Description | Payload |
| :--- | :--- | :--- | :--- |
| `/api/tasks` | `POST` | Supports `recurrence` field on insertion | `Task` |
| `/api/tasks/[id]` | `PATCH` | Updates `recurrence` string & triggers auto-recalculation if requested | `Partial<Task>` |
| `/api/tasks/[id]/complete` | `POST` | Atomically marks task completed and spawns next instance | `{ completionDate?: string }` |
| `/api/tasks/[id]/skip` | `POST` | Advances due date to next cycle without marking task completed | `{}` |
| `/api/recurring` | `GET` | Fetches overview of all active recurring rules & scheduled dates | N/A |

---

## 🖥 4. User Experience & UI Component Specs

### A. Terminal Visual Badges (`TaskList.tsx` & `CalendarView.tsx`)
- Display terminal badge `[🔄 rec:1w]` or `[⚡ strict:3d]` in cyan/purple text alongside task titles.
- Special hover tooltip showing next scheduled recurrence.

### B. Inspector Drawer Integration (`TaskDetails.tsx`)
Add a dedicated **Recurrence Control Card** in the Inspector sidebar:
- **Preset Buttons**: `[Daily]`, `[Weekdays]`, `[Weekly]`, `[Monthly]`, `[Custom]`.
- **Mode Toggle**: `[Relative to Completion]` vs `[Strict Due Date]`.
- **Quick Action Bar**:
  - `[Skip Next Occurrence]`: Advances due date without logging completion.
  - `[Remove Recurrence]`: Strips `rec:` tag from task.

### C. Terminal Command System (`CommandInput.tsx`)
- `:rec <rule>` → Sets recurrence on currently selected task (e.g. `:rec 1w`, `:rec strict:2d`, `:rec off`).
- `:skip` → Skips next occurrence of selected task.
- `:recurring` → Sets filter to display all recurring tasks.

### D. Calendar View Future Projections (`CalendarView.tsx`)
- Render dimmed "Ghost/Projected" calendar chips on future dates based on active recurrence rules, giving users a clear visual roadmap of upcoming workload.

---

## 📱 5. PWA, Offline Caching & Unsaved Sync Strategy

1. **Client-Side Instant Spawning**: If offline, completing a recurring task generates the next instance immediately in local state (`localStorage`) and queues a `SPAWN_RECURRING` mutation in `pendingQueue`.
2. **Conflict Resolution**: Idempotent task IDs prevent duplicate task creation when flushing sync queue upon reconnect.

---

## 🧪 6. Execution & Verification Plan

1. **DB Migration**: Verify `ALTER TABLE tasks ADD COLUMN recurrence TEXT;` executes cleanly without breaking existing databases.
2. **Parser Unit Tests**: Test parsing of `rec:1d`, `rec:2w`, `rec:1m`, `rec:strict:1w`, `rec:+3d`, `rec:weekday`.
3. **Completion & Spawning Tests**: Ensure subtasks reset to uncompleted while main task marks completed.
4. **Skip Action Verification**: Verify `:skip` moves due date accurately without duplicating task.
5. **Next.js Production Build**: Run `npm run build` to confirm static & serverless route compilation.
