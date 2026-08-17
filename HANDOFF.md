# AI Handoff Document - Todo Next (todo.txt & Turso DB)

## 📌 Project Overview
`todo-next` (Title: **Todo Next**) is a lightweight, terminal-styled task manager heavily influenced by the **`todo.txt` format** and **Unix philosophy**. It provides a fast, minimalist interface with keyboard navigation, syntax highlighting for projects (`+project`), contexts (`@context`), priorities (`(A)`, `(B)`), due dates (`due:YYYY-MM-DD`), dual theme support (Dark/Light mode), and full **List & Calendar views**.

- **Interactive Onboarding & Landing Experience (`components/OnboardingPage.tsx`)**:
  - Replaced immediate raw login screen with a rich terminal-styled **Onboarding & Landing Page** for unauthenticated users.
  - **Hero & Value Proposition**: Introduces Todo Next's Unix philosophy, standard `todo.txt` parsing, instant local-first speed, and native Android sync.
  - **Live Interactive Syntax Playground**: Real-time interactive AST parser and smart action sandbox directly on the frontpage with interactive preset snippets (`Priority Task`, `Recurring Sprint`, `Strict Daily Habit`, `Smart Reference`).
  - **Feature Matrix & Deep Dives**: Showcases Actionable Tasks, Recurrence Engine, Smart Reference system, Dynamic Task Templates, and Dual Workspaces.
  - **Interactive Multi-Theme Previews**: Live theme switcher right on the landing page allowing visitors to preview all 5 terminal themes.
  - **Seamless Authentication Flow**: Calls to action (`[ 🚀 Launch Free Workspace ]`, `[ Sign In ]`, `[ Get Started ]`) seamlessly transition into the `LoginScreen` with pre-selected `LOGIN` or `SIGNUP` modes, with a `[ ← Back to Overview ]` return option.
- **Flagship Reference System (Web & Native Android)**:
  - **Philosophy & Distinction**: Separates actionable todo.txt items from static non-actionable reference material (phone numbers, addresses, emails, meeting links, server configs, Wi-Fi credentials, cheat sheets).
  - **Data Model & Turso Database Schema**:
    - `references` table (`id`, `user_id`, `title`, `content`, `archived`, `created_at`, `updated_at`) with indexes on `user_id`, `created_at`, and `archived`.
    - `reference_tags` relational table (`id`, `reference_id`, `tag`) with index on `tag`.
    - Integrated with `db.batch()` for 1-roundtrip atomic querying and CRUD operations.
  - **Smart Actions Engine (`referenceUtils.ts` & `reference_utils.dart`)**:
    - **Phone Numbers**: Auto-detected via international/local regex -> One-click Call action (`tel:<number>`).
    - **URLs & Links**: Auto-detected via web URL pattern -> One-click Open in Browser action.
    - **Email Addresses**: Auto-detected via email regex -> One-click Compose Mail action (`mailto:<email>`).
    - **Addresses & Locations**: Auto-detected postal codes / street patterns -> One-click Google Maps search action.
    - **Quick Copy**: Formats reference title, content, and tags neatly for instant clipboard sharing.
  - **Web Application Workspace & UI (`components/Reference*.tsx`)**:
    - Sidebar Workspaces Switcher: Toggle between **Tasks** (`[ Tasks ]`) and **References** (`[ References ]`).
    - Reference List Workspace (`ReferenceList.tsx`): Real-time search, tab filters (`All`, `Recent (15)`, `Archived`), and tag pills.
    - Inline Sidebar Viewing & Editing (`ReferenceDetails.tsx`): Completely eliminates popup modals! The inspector drawer seamlessly transforms into the inline editor and creator, supporting Title, Content, auto-tag extraction, live Smart Actions previews, and instant saving.
    - Command Bar & Terminal Commands: `:refs` / `:ref` (open sidebar creator), `:ref <title>`, `:ref <title> | <content>`.
    - Local Caching & Sync: Optimistic UI updates with instant `localStorage` hydration and non-blocking API sync.
  - **Native Android & Tablet Implementation (`flutter_app/`)**:
    - Model: `Reference` model with defensive deserialization and `copyWith`.
    - Local Cache: `StorageService` using `SharedPreferences` with default seed references.
    - API Client: `ApiService` methods for `fetchReferences`, `createReference`, `updateReference`, `deleteReference`, `archiveReference`, `restoreReference`.
    - Widgets: `ReferenceListWidget`, `ReferenceItemWidget`, `ReferenceDrawerWidget`, `ReferenceEditorDialog`.
    - Responsive Tablet & Mobile layout in `HomeScreen` with animated drawer transitions and swipe navigation.
    - Terminal Command Parser: Extended with `OpenReferencesCommand`, `OpenNewReferenceCommand`, and `QuickCreateReferenceCommand`.
  - **Syntax Guide & Help**: Documented reference system commands and examples in `SyntaxGuideModal.tsx` and `SyntaxGuideTab.dart`.
  - **Full Test Coverage**: Unit tests, storage tests, smart action tests, and widget tests passing across web and mobile.
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
  - **Android Instant Launch Crash Resolution**:
    - **Native ClassNotFoundException Fix**: Fixed package mismatch where Android `namespace` was changed to `com.blackpiratex.todo` in `build.gradle.kts` while `MainActivity.kt` was located under `com.todonext.flutter_app`. Relocated `MainActivity.kt` to `android/app/src/main/kotlin/com/blackpiratex/todo/MainActivity.kt` with package `com.blackpiratex.todo`.
    - **Safe Deferred Dialog Lifecycle**: Fixed `HomeScreen` calling `showDialog()` immediately inside async `initState` sequence by wrapping in `WidgetsBinding.instance.addPostFrameCallback` with `mounted` checks and protective try/catch blocks.
    - **Defensive Model Deserialization**: Made `Task.fromJson`, `Template.fromJson`, `TemplateSubtask.fromJson`, `Subtask.fromJson`, and `Comment.fromJson` resilient against `null` values, type conversions (`int` vs `String`, `bool` vs `int`/`String`), and `Map<dynamic, dynamic>` subtask/comment decoding.
    - **Resilient Font Loading Fallbacks**: Added try/catch fallback in `AppTheme.monoStyle` and text themes to safely fallback to system `monospace` if `GoogleFonts` runtime HTTP download fails or the device is offline.
    - **Layout Overflow & Assertion Fixes**: Wrapped `SidebarWidget` `ListTile` in `Material` to prevent DecoratedBox splash clipping assertions, and made `SubtaskProgressBar` and `InspectorDrawerWidget` header rows flexible to prevent `RenderFlex` overflow.
  - Passes `flutter analyze` and `flutter test` with **0 issues found**.
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
  - Custom Keystore Support: automatically decodes `KEYSTORE_BASE64` and generates `key.properties` dynamically when CircleCI environment variables (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`) are present.
  - Fixed YAML syntax error in `.circleci/config.yml` caused by unindented lines inside multiline command block for `key.properties` generation.
  - Automatically stores generated release APK artifacts (`todo-next-android-app/app-release.apk`) in CircleCI artifact storage.
- **Android App Version Bump (`v1.1.0+2`) & F-Droid Update**:
  - Bumped Android application version to **`v1.1.0`** (`versionCode: 2`, `versionName: "1.1.0"`) in `flutter_app/pubspec.yaml`.
  - Added Fastlane metadata changelog `fastlane/metadata/android/en-US/changelogs/2.txt`.
  - Updated F-Droid build definition `fdroid/com.blackpiratex.todo.yml` with `v1.1.0` build instructions and `CurrentVersion: 1.1.0` / `CurrentVersionCode: 2`.
- **Manual GitHub Actions Release Workflow (`.github/workflows/release.yml`)**:
  - Dedicated workflow triggered manually via `workflow_dispatch` to compile, package, and publish official production releases.
  - **Configurable Inputs**: Git tag name (e.g. `v1.1.0`), release title, changelog/notes, draft toggle, and pre-release toggle.
  - **Full Validation & Test Matrix**: Runs Web bundle verification (`npm ci && npm run build`), Flutter static analysis (`flutter analyze --no-fatal-infos`), and Flutter unit/widget tests (`flutter test`).
  - **Signing & Multi-Architecture Packages**:
    - Generates Universal Fat APK (`todo-next-vX.Y.Z-universal.apk`).
    - Generates Split-per-ABI APKs (`arm64-v8a`, `armeabi-v7a`, `x86_64`).
    - Generates Android App Bundle (`todo-next-vX.Y.Z.aab`).
    - Computes SHA-256 checksums (`sha256sums.txt`).
  - **Automated GitHub Release Publishing**: Automatically creates GitHub release tag and attaches all compiled APKs, AAB bundles, and checksum files using `softprops/action-gh-release@v2`.
- **GitHub Actions Android APK Build & Test Workflow (`.github/workflows/build-flutter-apk.yml`)**:
  - Triggered on `push` and `pull_request` to `main` / `master`, plus manual dispatch (`workflow_dispatch`).
  - Sets up Java 17 (`actions/setup-java@v4`) and stable Flutter SDK with dependency caching (`subosito/flutter-action@v2`).
  - Runs `flutter doctor -v`, `flutter analyze --no-fatal-infos`, and `flutter test`.
  - Dynamically decodes `KEYSTORE_BASE64` into `upload-keystore.jks` and writes `flutter_app/android/key.properties` if repository secrets are provided, falling back to debug signing if omitted.
  - Compiles release APK (`flutter build apk --release --no-tree-shake-icons`) and uploads artifacts (`actions/upload-artifact@v4`) under artifact name `todo-next-android-apk`.
- **Web Default Sorting, Filters & Initial Load Performance Optimizations**:
  - Default Task Sorting: default sort set to **Creation Date Descending** (`creationDate` `desc`).
  - Default Task Filtering: default status filter set to **Open** (`open`), priority filter to **All** (`all`), and period filter to **All** (`all`).
  - Initial Load Acceleration:
    - Hydrates UI instantly (0ms load lag) from `localStorage` cached tasks/templates on mount.
    - Executed `/api/tasks` and `/api/templates` API requests concurrently via `Promise.all`.
    - Made `/api/auth` session sync non-blocking.
    - Implemented database batching via `db.batch()` in `lib/db.ts` for `getAllTasks()` and `getAllTemplates()`, reducing server-side Turso DB roundtrips from 5 down to 1 single request.
- **Multi-Theme System (Web App)**:
  - Added support for 5 developer and terminal themes:
    - **🌙 Pitch Black (`dark`)**: Retro pitch black canvas with cyan/green terminal syntax.
    - **☀️ Clean White (`light`)**: Crisp minimal light canvas for daytime legibility.
    - **🐱 Catppuccin Mocha (`mocha`)**: Soothing pastel dark theme with soft mauve, sapphire, and sky accents.
    - **🌰 Gruvbox Dark (`gruvbox-dark`)**: Warm retro groove palette with aqua, olive green, and earthy warm tones.
    - **📜 Paper & Ink (`paper-ink`)**: Warm linen paper background with rich typewriter ink typography.
  - Implemented CSS variables and CSS custom properties in [`app/globals.css`](file:///home/dog/git/todo-next/app/globals.css) bound to `data-theme` attribute on the root container.
  - Updated [`components/SettingsModal.tsx`](file:///home/dog/git/todo-next/components/SettingsModal.tsx) theme gallery with interactive cards, color palette swatches, and active indicators.
  - Updated [`components/StatusBar.tsx`](file:///home/dog/git/todo-next/components/StatusBar.tsx) to display the active theme badge (e.g. `[🐱 Catppuccin Mocha]`) and cycle themes on click.
  - Added terminal commands `:theme` and `:theme <name>` (`:theme mocha`, `:theme gruvbox`, `:theme paper`, `:theme dark`, `:theme light`) in `CommandInput`.
  - Persisted user theme preference in `localStorage.setItem('todo_next_theme', theme)`.
- **Multi-Theme Engine & Settings Modal Port (Flutter App)**:
  - Ported complete multi-theme architecture to Flutter (`flutter_app/lib/theme/app_theme.dart`):
    - Added `enum AppThemeId { dark, light, mocha, gruvboxDark, paperInk }` with complete `ThemeDefinition` models and `ThemeData` builders.
    - Persisted theme selection in `SharedPreferences` (key: `todo_next_theme`).
  - Added Unified Settings Modal (`flutter_app/lib/widgets/settings_modal.dart`):
    - **Tab 1: Themes**: Visual selection cards for all 5 themes with palette swatches, descriptions, active badges, and 1-tap switching. Also includes System & Account Diagnostics.
    - **Tab 2: Task Templates Manager & Editor**: Template search, `[ Use ]`, `[ Edit ]` inline editor, `[ + New Template ]` builder, and delete confirmation.
    - **Tab 3: Syntax Guide**: Full `todo.txt` syntax reference covering priorities, projects, contexts, due dates, tokens, recurrence rules, and terminal commands.
  - Header & Status Bar Updates:
    - Added `[⚙️ Settings]` button to `CommandInputWidget`.
    - Added active theme badge button to `StatusBarWidget` (`[🌙 Pitch Black]`, `[☀️ Clean White]`, `[🐱 Catppuccin Mocha]`, `[🌰 Gruvbox Dark]`, `[📜 Paper & Ink]`) with 1-tap cycling.
  - Added Terminal Commands to Mobile App:
    - `:settings` & `:theme` -> Open Settings Modal.
    - `:theme <name>` (`:theme mocha`, `:theme gruvbox`, `:theme paper`, `:theme dark`, `:theme light`) -> Direct theme switching.
    - `:syntax` -> Open Syntax Guide.
  - Default Sorting & Filtering:
    - Updated `TaskListWidget` defaults to **Creation Date Descending** (`SortOrder.desc`) and **Open** tasks (`StatusFilter.open`).
- **Flutter Codebase Modularization & Refactoring for Maintainability**:
  - Modularized large monolithic widget files (>25-30KB) into focused, single-responsibility sub-components under organized domain directories:
    - `flutter_app/lib/widgets/settings/`: `theme_settings_tab.dart`, `templates_settings_tab.dart`, `syntax_guide_tab.dart`, and `template_form_dialog.dart` (reduced `settings_modal.dart` from 29KB down to 6.0KB).
    - `flutter_app/lib/widgets/inspector/`: `inspector_header.dart`, `inspector_title_section.dart`, `inspector_metadata_section.dart`, `inspector_recurrence_card.dart`, `inspector_tags_section.dart`, `inspector_description_section.dart`, `inspector_subtasks_section.dart`, and `inspector_comments_section.dart` (reduced `inspector_drawer.dart` from 27KB down to 4.5KB).
    - `flutter_app/lib/widgets/calendar/`: `calendar_header.dart`, `calendar_weekday_header.dart`, and `calendar_day_cell.dart` (reduced `calendar_view.dart` from 20KB down to 4.9KB).
    - `flutter_app/lib/widgets/task_list/`: `task_list_toolbar.dart`, `task_list_header.dart`, and `task_list_item.dart` (reduced `task_list.dart` from 16KB down to 5.2KB).
    - `flutter_app/lib/widgets/modals/`: `add_task_dialog.dart` (extracted from `home_screen.dart`).
    - `flutter_app/lib/utils/command_parser.dart`: Extracted sealed command hierarchy and parser (`CommandParser`) for `:settings`, `:theme`, `:syntax`, `:recurring`, `:skip`, `:rec`, `:template`, `:use`, `:template save`, `:add`, and filter queries.
  - Zero-feature loss: 100% of UI styles, shortcuts, drag & drop, formatting, recurrence rules, dialogs, and token behaviors preserved.
- **Android App Launcher Icons & Full Offline Support**:
  - **Brand Launcher Icons**: Generated high-resolution Android launcher icons across all mipmap densities (`mipmap-mdpi` 48x48, `mipmap-hdpi` 72x72, `mipmap-xhdpi` 96x96, `mipmap-xxhdpi` 144x144, `mipmap-xxxhdpi` 192x192) using the official brand icon asset (`public/icon-512.png`), replacing the default Flutter icon.
  - **Full Offline Use Without Login (Guest Mode)**:
    - The mobile application operates 100% locally by default with zero login required. All tasks, templates, subtasks, recurrence, and theme configurations persist offline via SQLite / SharedPreferences.
    - Added `[ Continue Offline ]` and close actions to `LoginDialogWidget` allowing instant dismissal.
  - **Split Per-ABI & Universal APK Build CI Pipelines**:
    - Updated `.github/workflows/build-flutter-apk.yml` and `.circleci/config.yml` to run `flutter build apk --release --split-per-abi` and `flutter build apk --release`.
    - Produces architecture-optimized APKs for `arm64-v8a`, `armeabi-v7a`, and `x86_64` (significantly reducing download and install size from ~45MB down to ~15-16MB per device) alongside the universal bundle.
  - **F-Droid Package Preparation & Fastlane Standardization**:
    - **Fastlane Metadata**: Verified and configured complete metadata in `fastlane/metadata/android/en-US/`: `title.txt` ("Todo Next"), `short_description.txt` (80 chars), `full_description.txt` (detailing offline-first, 5 themes, todo.txt specs, recurrence, and templates), `icon.png` (512x512 PNG), and `featureGraphic.png` (1024x500 PNG).
    - **F-Droid Build Recipe**: Created official metadata template in [`fdroid/com.blackpiratex.todo.yml`](file:///home/dog/git/todo-next/fdroid/com.blackpiratex.todo.yml) configured for automated `flutter: stable` builds.
    - **Submission Guide**: Created comprehensive documentation in [`FDROID_SUBMISSION_GUIDE.md`](file:///home/dog/git/todo-next/FDROID_SUBMISSION_GUIDE.md) outlining both GitLab RFP issue submission and direct `fdroiddata` Merge Request procedures.

---

## 📌 Standard Operating Rule for AI Assistant
> [!IMPORTANT]
> **Always update `HANDOFF.md` whenever significant code, feature, schema, architecture, or workflow changes are completed, and commit & push the updated handoff document.**

---

## 🏗 System Architecture & Directory Structure

```
├── .github/
│   └── workflows/
│       ├── build-flutter-apk.yml     # GitHub Actions CI workflow building Android APK
│       └── release.yml               # Manual release workflow publishing APKs/AAB to GitHub Releases
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   ├── route.ts
│   │   │   ├── legacy-verify/route.ts # Verify APP_PASSWORD env variable for bpx migration
│   │   │   └── migrate-bpx/route.ts   # Execute zero-data-loss migration for account bpx
│   │   ├── health/route.ts           # Diagnostic endpoint for DB & Vercel serverless health
│   │   ├── recurring/route.ts        # Endpoint for listing recurring schedules
│   │   ├── references/               # Reference System API routes
│   │   │   ├── route.ts              # GET /api/references, POST /api/references
│   │   │   └── [id]/
│   │   │       ├── route.ts          # GET, PATCH, DELETE /api/references/[id]
│   │   │       ├── archive/route.ts  # POST /api/references/[id]/archive
│   │   │       └── restore/route.ts  # POST /api/references/[id]/restore
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
│   ├── CommandInput.tsx              # :rec, :skip, :ref, :refs terminal commands & [Refs] switch
│   ├── ConfirmModal.tsx
│   ├── FormattedText.tsx
│   ├── LoginScreen.tsx               # Firebase Auth login/signup & bpx migration wizard
│   ├── OnboardingPage.tsx            # Terminal-styled interactive Landing & Onboarding page
│   ├── ReferenceDetails.tsx          # Inline Reference Viewing & Editing Sidebar with Smart Actions
│   ├── ReferenceList.tsx             # Reference Workspace List (search, tabs, tag filters)
│   ├── Sidebar.tsx                   # Workspaces Switcher ([ Tasks ] vs [ References ])
│   ├── StatusBar.tsx                 # Displays logged-in user email and sync indicator
│   ├── SubtaskProgressBar.tsx
│   ├── SyntaxGuideModal.tsx          # rec: & :ref syntax guide documentation
│   ├── TaskDetails.tsx              # Recurrence pattern control card & presets
│   ├── TaskList.tsx                 # Visual terminal recurrence badges ([🔄 rec:1w], [⚡ strict:3d])
│   └── TemplateModal.tsx
├── flutter_app/                       # Native Flutter Android Application
│   ├── android/                      # Native Android Gradle configuration
│   ├── lib/
│   │   ├── models/                   # Task, Subtask, Comment, Template, RecurrenceRule, Reference
│   │   ├── screens/                  # HomeScreen (Adaptive Phone & Tablet layout)
│   │   ├── services/                 # ApiService, StorageService (Tasks, Templates, References)
│   │   ├── theme/                    # AppTheme (5 Developer & Terminal Themes)
│   │   ├── utils/                    # command_parser, todo_parser, recurrence_engine, template_engine, reference_utils, date_utils
│   │   └── widgets/
│   │       ├── calendar/             # CalendarHeader, CalendarWeekdayHeader, CalendarDayCell
│   │       ├── inspector/            # Header, Title, Metadata, Recurrence, Tags, Desc, Subtasks, Comments
│   │       ├── modals/               # AddTaskDialog
│   │       ├── reference/            # ReferenceListWidget, ReferenceItemWidget, ReferenceDrawerWidget, ReferenceEditorDialog
│   │       ├── settings/             # ThemeSettingsTab, TemplatesSettingsTab, SyntaxGuideTab, TemplateFormDialog
│   │       ├── task_list/            # TaskListToolbar, TaskListHeader, TaskListItem
│   │       ├── calendar_view.dart    # Calendar View coordinator
│   │       ├── command_input.dart    # Command Bar & quick action buttons ([Tasks]/[Refs])
│   │       ├── confirm_dialog.dart   # Universal Confirmation dialog
│   │       ├── formatted_text.dart   # todo.txt syntax highlight renderer
│   │       ├── inspector_drawer.dart # Inspector Drawer coordinator
│   │       ├── login_dialog.dart     # Authentication modal
│   │       ├── settings_modal.dart   # Unified Settings coordinator
│   │       ├── sidebar.dart          # Tag & filter navigation sidebar (Workspaces section)
│   │       ├── status_bar.dart       # Status and sync indicator
│   │       └── subtask_progress_bar.dart # Progress bar [2/4]
│   ├── test/                         # widget_test, app_launch_test, command_parser_test, components_test, reference_model_test, reference_utils_test, reference_storage_test, reference_widget_test
│   └── pubspec.yaml
├── lib/
│   ├── auth.ts
│   └── db.ts                         # Turso DB client with references schema & batching
├── public/
├── types/
│   └── todo.ts                       # Extended with Reference & SmartAction interfaces
├── utils/
│   ├── dateUtils.ts
│   ├── recurrenceEngine.ts           # Recurrence rule parser, due date math & spawning engine
│   ├── referenceUtils.ts             # Smart action detection regex & copy formatter
│   ├── templateEngine.ts
│   └── todoParser.ts                 # Extended todo.txt rec: tag parser
├── ANDROID_APP_FEATURE_PLAN.md
├── HANDOFF.md
├── reference-feature.md
└── RECURRING_TASKS_FEATURE_PLAN.md
```
