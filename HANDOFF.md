# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

Recently updated with:
- **Full SaaS Conversion & Firebase Authentication (Web & Android App)**:
  - Converted app from single-user to multi-tenant SaaS application allowing open user sign-up and log-in with email & password via Firebase Auth.
  - Multi-tenancy database schema: added `users` table (`id`, `email`, `username`, `is_migrated`, `created_at`) and `user_id` foreign keys to `tasks` and `templates`.
  - Endpoint security: all API routes (`/api/tasks`, `/api/templates`, etc.) verify Firebase ID tokens passed via `Authorization: Bearer <token>`, `x-app-session`, or HTTP cookies.
  - Added dedicated SaaS auth API endpoints `POST /api/auth/login` and `POST /api/auth/signup`.
  - Updated Android application (`flutter_app/`) `ApiService` and `LoginDialogWidget` to support Email & Password login/signup matching the SaaS web backend.
  - Vercel Serverless Compatibility: added `serverExternalPackages: ["firebase-admin", "jwks-rsa", "jose"]` in `next.config.ts` and dynamic imports with resilient JWT parsing fallback in `lib/firebaseAdmin.ts` to prevent `ERR_REQUIRE_ESM` serverless bundling crashes on Vercel.
  - Completed single-user to `bpx` (`hi@sudipx.in`) database migration and cleaned up legacy migration routes.
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
- **Native Android & Tablet Application (`flutter_app/`)**:
  - Built with **Flutter 3.44+ & Dart** for native Android performance on phones and tablets.
  - Multi-column adaptive tablet dashboard layout (≥600dp) rendering Sidebar + Task Workspace + Inspector Drawer side-by-side.
  - Mobile UI/UX Optimizations:
    - Fixed top bar overflow on phone screens with responsive 2-line layout in `CommandInputWidget`.
    - Added retro terminal `FloatingActionButton` (`+ NEW TASK`) and quick task creation modal (`_openAddTaskModal`).
    - Fixed task tap interaction to automatically slide open the Inspector Drawer on mobile phones.
    - Wrapped `SidebarWidget` in `SafeArea` to prevent status bar/notch overlap.
    - Responsive `TemplateModalWidget` gallery preventing button clipping on narrow displays.
  - Full `todo.txt` syntax parser, recurrence spawning engine, template token generator, calendar view, inspector drawer, and terminal command bar.
  - Passes `flutter analyze` with **0 issues found**.
- **Bi-directional Web Sync & Header Authentication**:
  - Live bi-directional sync between Android app and web backend (`https://todo-next-five-mu.vercel.app/api`).
  - Extended Next.js backend (`lib/auth.ts` & `app/api/auth/route.ts`) with `Authorization: Bearer <token>` and `x-app-session` headers.
  - Native password login modal (`LoginDialogWidget`) in Flutter for protected instances.
- **F-Droid Open-Source Submission Package (`fastlane/` & `fdroid/`)**:
  - Application ID updated to `com.blackpiratex.todo` in `build.gradle.kts`.
  - Created open-source FOSS [`LICENSE`](file:///home/dog/git/todo-next/LICENSE) file (MIT License, Copyright BlackPirateX).
  - Configured Fastlane metadata under `fastlane/metadata/android/en-US/`: `short_description.txt`, `full_description.txt`, `changelogs/1.txt`, `icon.png`, and high-res phone screenshots (`1.png`, `2.png`, `3.png`).
  - Generated F-Droid build metadata specification file [`fdroid/com.blackpiratex.todo.yml`](file:///home/dog/git/todo-next/fdroid/com.blackpiratex.todo.yml) ready for direct submission to `fdroiddata` repository via Merge Request.
  - Tagged Git release `v1.0.0` matching `versionName` and `versionCode: 1`.
- **Automated CircleCI CI/CD Pipeline (`.circleci/config.yml`)**:
  - CircleCI workflow automated on push to `main` & `master`.
  - Runs environment check (`flutter doctor -v`), static code analysis (`flutter analyze`), and compiles release `.apk` packages.
  - Automatically stores generated release APK artifacts (`todo-next-android-app/app-release.apk`) in CircleCI artifact storage.

---

## 📌 Standard Operating Rule for AI Assistant
> [!IMPORTANT]
> **Always update `HANDOFF.md` whenever significant code, feature, schema, architecture, or workflow changes are completed, and commit & push the updated handoff document.**

---

## 🏗 System Architecture & Directory Structure

```
├── .github/
│   └── workflows/
│       └── build-flutter-apk.yml     # GitHub Actions CI workflow building Android APK
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   ├── route.ts
│   │   │   ├── legacy-verify/route.ts # Verify APP_PASSWORD env variable for bpx migration
│   │   │   └── migrate-bpx/route.ts   # Execute zero-data-loss migration for account bpx
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
│   ├── LoginScreen.tsx               # Firebase Auth login/signup & bpx migration wizard
│   ├── Sidebar.tsx
│   ├── StatusBar.tsx                 # Displays logged-in user email and sync indicator
│   ├── SubtaskProgressBar.tsx
│   ├── SyntaxGuideModal.tsx          # rec: syntax guide documentation
│   ├── TaskDetails.tsx              # Recurrence pattern control card & presets
│   ├── TaskList.tsx                 # Visual terminal recurrence badges ([🔄 rec:1w], [⚡ strict:3d])
│   └── TemplateModal.tsx
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
├── ANDROID_APP_FEATURE_PLAN.md
├── HANDOFF.md
└── RECURRING_TASKS_FEATURE_PLAN.md
```
