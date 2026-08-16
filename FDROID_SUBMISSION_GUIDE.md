# 📦 F-Droid Submission Guide for Todo Next

This repository is fully configured and ready for submission to the official **F-Droid** repository.

---

## 📋 Readiness Checklist

| Requirement | Status | Details |
| :--- | :--- | :--- |
| **Open Source License** | ✅ Ready | [MIT License](file:///home/dog/git/todo-next/LICENSE) in root |
| **No Non-Free Dependencies** | ✅ Ready | Pure open-source Flutter dependencies (zero proprietary trackers/blobs) |
| **Offline-First (No Forced Login)** | ✅ Ready | Complete guest mode with local SQLite / SharedPreferences storage |
| **Fastlane Metadata Structure** | ✅ Ready | Located at [`fastlane/metadata/android/en-US/`](file:///home/dog/git/todo-next/fastlane/metadata/android/en-US/) |
| **App Title & Descriptions** | ✅ Ready | `title.txt`, `short_description.txt`, `full_description.txt` |
| **App Icon** | ✅ Ready | 512x512 PNG at `fastlane/metadata/android/en-US/images/icon.png` |
| **Feature Graphic** | ✅ Ready | 1024x500 PNG at `fastlane/metadata/android/en-US/images/featureGraphic.png` |
| **Phone Screenshots** | ✅ Ready | Located at `fastlane/metadata/android/en-US/images/phoneScreenshots/` |
| **F-Droid Recipe Template** | ✅ Ready | Pre-configured at [`fdroid/com.blackpiratex.todo.yml`](file:///home/dog/git/todo-next/fdroid/com.blackpiratex.todo.yml) |

---

## 🚀 How to Submit to F-Droid

There are two official ways to submit `Todo Next` to F-Droid:

### Option A: Open a Request for Packaging (RFP) Issue (Easiest)

1. Go to F-Droid's Issue Tracker on GitLab:
   👉 **https://gitlab.com/fdroid/rfp/-/issues/new**
2. Choose the **`App Inclusion Request`** template.
3. Fill in the required details:
   - **App Name**: `Todo Next`
   - **Package Name**: `com.blackpiratex.todo`
   - **License**: `MIT`
   - **Source Code**: `https://github.com/blackpirateapps/todo-next`
   - **Issue Tracker**: `https://github.com/blackpirateapps/todo-next/issues`
   - **Summary**: `Lightweight, terminal-styled task manager inspired by todo.txt`
   - **Build Tool**: `Flutter (stable)`
   - **Subdir**: `flutter_app`
4. Paste the content of [`fdroid/com.blackpiratex.todo.yml`](file:///home/dog/git/todo-next/fdroid/com.blackpiratex.todo.yml) into the issue description.
5. Submit the issue. The F-Droid community team will review and merge it.

---

### Option B: Submit a Merge Request Directly to `fdroiddata` (Fastest)

1. Fork **https://gitlab.com/fdroid/fdroiddata** to your GitLab account.
2. Clone your fork locally:
   ```bash
   git clone https://gitlab.com/<your-username>/fdroiddata.git
   cd fdroiddata
   ```
3. Copy the metadata file into the `metadata/` folder:
   ```bash
   cp /path/to/todo-next/fdroid/com.blackpiratex.todo.yml metadata/com.blackpiratex.todo.yml
   ```
4. Commit and push your branch:
   ```bash
   git checkout -b add-com.blackpiratex.todo
   git add metadata/com.blackpiratex.todo.yml
   git commit -m "Add com.blackpiratex.todo"
   git push origin add-com.blackpiratex.todo
   ```
5. Open a **Merge Request** against `fdroid/fdroiddata:master`.

---

## 🏷️ Release Tagging Instructions

F-Droid uses Git tags to trigger automated builds. When releasing a new version:

1. Update the version in [`flutter_app/pubspec.yaml`](file:///home/dog/git/todo-next/flutter_app/pubspec.yaml):
   ```yaml
   version: 1.0.0+1
   ```
2. Create and push a Git tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. F-Droid's automated build bot will periodically check for new tags, build the APK from source, and publish it to the F-Droid store.
