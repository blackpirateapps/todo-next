# Production Implementation Plan: Flagship Android & Tablet Application (`todo-next`)

## 📌 Executive Summary
This plan details the end-to-end strategy for building a **flagship, fully-featured, production-ready Android application** for **Todo Next** supporting both Android smartphones and tablets (portrait & landscape orientation, foldables, and multi-window modes).

The app strictly preserves the **utilitarian terminal aesthetic** captured in the design spec (pure black `#000000` background, monospaced typography, `+project` / `@context` syntax highlighting, progress bars, calendar view with ghost recurrence projections, inspector drawer, and prompt command bar).

---

## 🏛 1. Visual Design & Tablet Multi-Column Layout Architecture

### A. Phone Layout (< 768px Viewport)
- **Top Command Header**: Compact command bar with view switcher `[List|Cal]`, `[Templates]`, `[?] Syntax`, and prompt input.
- **Main Area**: Displays Task List or Calendar View with full swipe/scroll support.
- **Drawer Panels**:
  - Left Slide-out Sidebar for filtering by Projects & Contexts.
  - Right Slide-out / Bottom Sheet Inspector for inspecting & editing task details, subtasks, comments, and recurrence patterns.

### B. Tablet Layout (≥ 768px Viewport / Landscape)
- **Multi-Column Terminal Dashboard**:
  - **Column 1 (Left Sidebar)**: Permanent navigation & filter panel showing `[ALL TASKS]`, `PROJECTS`, and `CONTEXTS`.
  - **Column 2 (Center Workspace)**: Full Task Table or Monthly/Weekly Calendar View.
  - **Column 3 (Right Inspector Drawer)**: Permanent Inspector Drawer for instant editing without modal popups.

![Design Reference](file:///home/dog/.gemini/antigravity-cli/brain/5b8425cf-74fe-4028-a641-34a2bffa928d/.user_uploaded/uploaded_media_1786027386469.png)

---

## ⚡ 2. Technology Stack & Native Tooling

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **App Framework** | Next.js (Static Export) + Capacitor 6 | Native Android wrapper with 100% UI feature parity |
| **Android Integration** | `@capacitor/android`, `@capacitor/core`, `@capacitor/cli` | Native Android lifecycle, storage, status bar, and splash screen |
| **Local Storage** | LocalStorage + IndexedDB (`@capacitor/preferences`) | 100% offline-first task storage & sync engine |
| **Build Tools** | Android SDK (`android-34`), Gradle 8+, OpenJDK 25 | Compiling native Android `.apk` package |

---

## 🛠 3. Feature Matrix (Production-Ready)

1. **Complete `todo.txt` Parser**:
   - Priority handling `(A)` to `(Z)`
   - Tagging `+project` and `@context`
   - Due dates `due:YYYY-MM-DD` and times `time:HH:MM`
   - Recurrence tags `rec:1d`, `rec:2w`, `rec:1m`, `rec:weekday`, `rec:strict:1w`
2. **Recurrence Spawning Engine**:
   - Next-instance auto-spawning on completion
   - Subtask checklist resetting
   - Occurrence skipping (`:skip` / `[Skip Cycle]`)
   - Calendar future projections (ghost chips)
3. **Task Templates System**:
   - Dynamic token interpolation (`{today}`, `{due:+3d}`, `{time:HH:MM}`)
   - Terminal commands `:template`, `:use <name>`, `:template save <name>`
   - Visual Template Gallery & Builder
4. **Command Bar System**:
   - Terminal prompt supporting `:add`, `:rec`, `:skip`, `:recurring`, `:template`, `:use`
   - Integrated `[?] Syntax` guide modal
5. **Universal Deletion Safeguards**:
   - Confirmation modals before deleting tasks, subtasks, projects, contexts, comments, or templates.

---

## 📱 4. Android SDK Environment & Build Setup

### Steps to Download & Prepare Build Tools:
1. **Install Android Command Line Tools**:
   - Path: `~/android-sdk/cmdline-tools/latest`
   - `sdkmanager` CLI for fetching platforms & build tools
2. **Fetch Android SDK Packages**:
   - `platforms;android-34`
   - `build-tools;34.0.0`
   - `platform-tools`
3. **Capacitor Configuration (`capacitor.config.json`)**:
   ```json
   {
     "appId": "com.todonext.app",
     "appName": "Todo Next",
     "webDir": "out",
     "server": {
       "androidScheme": "https"
     },
     "android": {
       "backgroundColor": "#000000",
       "allowMixedContent": true
     }
   }
   ```

---

## 🧪 5. Step-by-Step Execution Plan

- [ ] **Phase 1: Toolchain Setup**: Complete Android SDK download & configure environment variables (`ANDROID_HOME`, `PATH`).
- [ ] **Phase 2: Responsive Tablet Layout Polish**: Add responsive breakpoint classes to `page.tsx`, `Sidebar.tsx`, `TaskList.tsx`, and `TaskDetails.tsx` for tablet multi-column view.
- [ ] **Phase 3: Capacitor Project Initialization**: Add `@capacitor/core`, `@capacitor/cli`, `@capacitor/android` and run `npx cap init` + `npx cap add android`.
- [ ] **Phase 4: Next.js Static Export Build**: Update `next.config.ts` for static export (`output: 'export'`) and build web assets.
- [ ] **Phase 5: Sync & Native Android APK Assembly**: Execute `npx cap sync android` and compile Android APK via `./gradlew assembleDebug`.
- [ ] **Phase 6: Verification & Delivery**: Verify generated `.apk` package in `android/app/build/outputs/apk/debug/app-debug.apk`.
