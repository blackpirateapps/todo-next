# Todo Next — Flagship Reference System

## Mission

Implement a **first-class Reference system** in Todo Next.

Todo Next is primarily a todo.txt-inspired task manager. Tasks represent things the user needs to **DO**. The new Reference system represents small pieces of information the user needs to **KNOW, KEEP, or REMEMBER**, but which are not actionable and therefore should not have a checkbox or completion state.

Examples:

* Phone numbers
* Addresses
* Wi-Fi information
* Keywords
* Short snippets
* URLs
* Meeting locations
* Account/reference information
* People/contact information
* Project facts
* Temporary information
* Small blocks of arbitrary text

The feature must be **flagship-quality**, fully integrated into both the Next.js web application and the Flutter Android application, while preserving the existing todo.txt task model and avoiding unnecessary complexity.

---

# 1. Core Product Philosophy

The fundamental distinction is:

```text
TASK
"I need to DO this."

REFERENCE
"I need to KNOW / KEEP this."
```

A Reference:

* is never a Task
* has no completed/uncompleted state
* has no checkbox
* does not participate in recurrence
* does not participate in task templates
* does not receive task due dates
* does not have subtasks
* does not have task comments
* does not get spawned by recurrence
* does not affect task completion statistics
* does not pollute the todo.txt parser

References should remain intentionally lightweight.

Do **not** turn Todo Next into a general-purpose notes application.

Do not introduce notebooks, folders, pages, rich document editing, nested documents, or a Notion/Obsidian-style hierarchy.

The feature should feel like a natural Unix/todo.txt extension:

> Tasks are things to do. References are things to keep.

---

# 2. Existing Project Constraints

The existing project already has:

* Next.js web application
* Turso database
* Firebase Authentication
* multi-tenant `users`
* authenticated API routes
* offline-first Flutter Android app
* SQLite/local persistence on Android
* bidirectional synchronization
* terminal command input
* Sidebar
* Task Workspace
* Inspector Drawer
* List View
* Calendar View
* todo.txt parser
* task templates
* recurrence engine
* subtasks
* comments
* multiple themes
* web localStorage caching
* Android SharedPreferences/SQLite persistence
* terminal styling
* comprehensive testing
* CI/CD

Do not regress any existing functionality.

Before changing anything:

1. Inspect the repository.
2. Understand the current database abstraction.
3. Understand authentication middleware/helpers.
4. Understand the existing Task model.
5. Understand web API conventions.
6. Understand Flutter storage conventions.
7. Understand how synchronization currently works.
8. Understand Sidebar navigation.
9. Understand Inspector Drawer architecture.
10. Understand CommandInput parsing.
11. Understand testing conventions.

Reuse established project patterns whenever possible.

Do not invent an unrelated architecture.

---

# 3. Reference Data Model

Create a new first-class `Reference` model.

Recommended TypeScript model:

```ts
export interface Reference {
  id: string;
  userId: string;

  title: string;
  content: string;

  tags: string[];

  createdAt: string;
  updatedAt: string;

  archived: boolean;
}
```

The implementation may adjust field naming to match existing project conventions, but the conceptual model must remain this simple.

## Required fields

### `id`

Unique Reference ID.

Use the same ID strategy already used by Tasks/Templates where appropriate.

### `userId`

Required for multi-tenant isolation.

Every Reference must belong to exactly one authenticated user.

### `title`

Short human-readable title.

Examples:

```text
John
Dentist
WiFi
Project X
Amazon return
Meeting location
```

Title can be empty.

### `content`

Arbitrary text.

The content may contain:

* multiple lines
* phone numbers
* addresses
* URLs
* keywords
* arbitrary snippets
* simple Markdown/plain text

Do not impose a rigid schema such as:

```text
phone
address
url
keyword
```

The content model must remain flexible.

### `tags`

Optional tags.

Reuse existing Todo Next tag conventions where practical.

References may use:

```text
+work
+personal
@people
@places
@home
```

However, tags must not accidentally become Tasks.

### `createdAt`

Creation timestamp.

### `updatedAt`

Last modification timestamp.

### `archived`

Boolean.

Archiving is preferable to deletion for normal lifecycle management, but permanent deletion must still be supported with confirmation.

---

# 4. Database

Add a new Turso table.

Conceptually:

```sql
CREATE TABLE references (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    archived INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
);
```

If tags are stored relationally, use a separate table:

```sql
CREATE TABLE reference_tags (
    reference_id TEXT NOT NULL,
    tag TEXT NOT NULL,

    PRIMARY KEY (reference_id, tag),

    FOREIGN KEY (reference_id)
        REFERENCES references(id)
        ON DELETE CASCADE
);
```

However, if the existing architecture has a simpler established approach for tags, follow it.

## Database requirements

Implement:

* schema migration
* create Reference
* get Reference
* list References
* update Reference
* archive Reference
* unarchive Reference
* permanently delete Reference
* search References
* tag filtering
* user isolation

All queries must be scoped by authenticated `user_id`.

Never allow a user to read or mutate another user's Reference by supplying its ID.

Add appropriate indexes for:

* `user_id`
* `user_id + archived`
* `updated_at`
* search fields if the chosen DB strategy supports it

Do not introduce unnecessary database complexity.

---

# 5. API

Create authenticated Reference endpoints following the conventions already used by `/api/tasks` and `/api/templates`.

Recommended API:

```text
GET    /api/references
POST   /api/references

GET    /api/references/[id]
PATCH  /api/references/[id]
DELETE /api/references/[id]

POST   /api/references/[id]/archive
POST   /api/references/[id]/restore
```

The exact routing can follow existing project conventions.

## GET `/api/references`

Support:

* active references
* archived references
* all references
* search
* tag filtering
* sorting

Suggested query parameters:

```text
?archived=false
?search=john
?tag=@people
?sort=updatedAt
?order=desc
```

Do not over-engineer pagination unless the existing application architecture requires it.

## POST

Accept:

```json
{
  "title": "John",
  "content": "+91 98765 43210",
  "tags": ["@people"]
}
```

Validate:

* title required
* content may be empty
* tags must be valid strings
* authenticated user required

## PATCH

Allow updating:

* title
* content
* tags
* archived

## DELETE

Permanent deletion requires explicit confirmation in the UI.

---

# 6. Authentication and Security

Reuse the existing authentication system.

Reference APIs must support the same authentication mechanisms already supported by Todo Next, including the project's current Firebase ID token/session mechanisms.

Do not create a second authentication system.

Every API operation must:

1. resolve authenticated user
2. derive `userId` from the authenticated identity
3. query/mutate only that user's References

Never trust a client-supplied `userId`.

Never allow:

```text
GET /api/references/other-users-id
```

to return another user's Reference.

Add tests specifically covering cross-user isolation.

---

# 7. Web UI

Add Reference as a first-class workspace.

The existing Sidebar should gain a Reference section.

Suggested structure:

```text
TODO NEXT

WORKSPACE
────────────────
> Tasks
> Calendar

REFERENCE
────────────────
> All
> Recent
> Archived

TAGS
────────────────
+work
+personal
@people
@places
```

Adapt this to the existing Sidebar design rather than replacing it.

Reference should remain visually consistent with the terminal aesthetic and all five existing themes.

---

# 8. Reference List

Create a dedicated Reference list/workspace.

Example:

```text
REFERENCE                                      [+ NEW]

John
+91 98765 43210                         @people

Dentist
14 Carter Road, Bandra                  @places

WiFi
Network: Home_5G                        @home

Project X
blue elephant                           +project-x
```

Requirements:

* no checkboxes
* no task completion controls
* clear distinction from Tasks
* keyboard navigation
* selection state
* search
* tag filtering
* archive filtering
* sorting
* create button
* empty state
* loading state
* error state
* responsive layout

Reuse existing task list/workspace patterns where appropriate, but do not make References look like fake Tasks.

---

# 9. Reference Card/List Item

Each Reference list item should display:

* title
* concise content preview
* tags
* optionally relative updated timestamp

For multiline content, show a clean preview rather than dumping the whole document into the list.

Example:

```text
John
+91 98765 43210
@people
```

Another:

```text
WiFi
Network: Home_5G · Password: ********
@home
```

Another:

```text
Dentist
14 Carter Road, Bandra
@places
```

Avoid excessive visual decoration.

---

# 10. Reference Inspector

Integrate Reference with the existing Inspector Drawer architecture.

When a Reference is selected, the Inspector should switch into Reference mode.

Example:

```text
┌──────────────────────────────┐
│ REFERENCE                    │
│                              │
│ John                         │
│ ───────────────────────────  │
│                              │
│ +91 98765 43210              │
│                              │
│ @people                      │
│                              │
│ Created: Aug 17, 2026        │
│ Updated: Aug 17, 2026        │
│                              │
│ [ Copy ] [ Edit ]            │
│                              │
│ [ Archive ]                  │
└──────────────────────────────┘
```

Do not display:

* completion status
* recurrence
* subtasks
* due date
* task priority

unless they are deliberately relevant to future Reference features.

---

# 11. Reference Editor

Create a clean Reference editor.

Fields:

```text
Title
[ John                         ]

Content
┌──────────────────────────────┐
│ +91 98765 43210              │
│                              │
└──────────────────────────────┘

Tags
[ @people ] [ +work ]

[ Cancel ] [ Save ]
```

Requirements:

* keyboard-friendly
* multiline content
* autosizing textarea where appropriate
* preserve line breaks
* clean terminal styling
* support all five themes
* validation
* unsaved-change protection if appropriate
* mobile-friendly
* tablet-friendly

Do not build a heavy rich-text editor.

Plain text is the default.

Optional lightweight Markdown rendering may be used if the project already has a suitable renderer, but editing should remain simple.

---

# 12. Create Reference Flow

The primary creation interaction should be fast.

Provide:

```text
[ + NEW REFERENCE ]
```

and terminal command support.

A new Reference should require only:

```text
Title
Content
```

Tags are optional.

Do not force the user through a complicated wizard.

---

# 13. Terminal Commands

Extend the existing `CommandParser`.

Add:

```text
:ref
:ref <title>
:refs
```

Recommended behavior:

### `:refs`

Navigate to Reference workspace.

### `:ref`

Open new Reference editor.

### `:ref John`

Open new Reference editor with title pre-filled:

```text
John
```

### Optional quick-create

If safe within the current parser design:

```text
:ref John | +91 98765 43210
```

creates:

```text
Title:
John

Content:
+91 98765 43210
```

Do not implement an ambiguous syntax that conflicts with existing todo.txt syntax.

If quick-create is implemented, document it clearly.

---

# 14. Keyboard Navigation

Reference must feel native to the existing terminal-style interface.

Support:

* navigation up/down
* Enter to inspect
* `n` or existing create shortcut for new Reference where appropriate
* Escape to close inspector/modal
* `/` or existing search shortcut
* archive shortcut if the application already has a consistent convention
* delete with confirmation
* copy content

Do not introduce shortcuts that conflict with existing Task shortcuts.

Document new shortcuts in the existing syntax/shortcut guide.

---

# 15. Search

Reference search is important.

Implement Reference search across:

* title
* content
* tags

Example:

```text
Search:
98765
```

returns:

```text
John
+91 98765 43210
```

Search:

```text
Carter
```

returns:

```text
Dentist
14 Carter Road, Bandra
```

Search:

```text
blue elephant
```

returns:

```text
Project X
blue elephant
```

Search should be case-insensitive.

Use the simplest reliable search implementation compatible with Turso and the existing application.

Do not prematurely introduce a full-text search subsystem unless data size or architecture genuinely requires it.

---

# 16. Global Search

If Todo Next already has or can naturally support a global command/search interface, extend it so that References can appear alongside Tasks.

Example:

```text
Ctrl+K

> 98765
```

Results:

```text
REFERENCE

John
+91 98765 43210

TASKS

Call John
```

The implementation should make clear which type each result belongs to.

If global search does not currently exist, implement the Reference-local search first and only add global search if it can be done cleanly without destabilizing the existing architecture.

---

# 17. Smart Content Actions

References are intentionally unstructured, but the UI can intelligently recognize common content.

Implement lightweight detection where useful.

## Phone numbers

If content contains a recognizable phone number:

```text
+91 98765 43210
```

show:

```text
[ Copy ] [ Call ]
```

On Android, use the appropriate native phone intent.

On Web, use:

```text
tel:
```

where appropriate.

## URLs

If content contains a URL:

```text
https://example.com
```

show:

```text
[ Copy ] [ Open ]
```

Use safe URL handling.

## Email addresses

Show:

```text
[ Copy ] [ Email ]
```

where appropriate.

## Addresses

Do not attempt unreliable geocoding automatically.

If a Reference looks like an address, optionally offer:

```text
[ Copy ] [ Open Map ]
```

only when a safe mapping URL can be generated.

Smart detection must never modify the underlying Reference content.

It is purely a convenience layer.

---

# 18. Copy Behavior

References should make copying information extremely easy.

Support:

```text
Copy title
Copy content
Copy full Reference
```

Suggested full-copy format:

```text
John
+91 98765 43210
@people
```

Do not include internal IDs.

Show lightweight confirmation/toast:

```text
Copied
```

Use the existing notification/toast system if available.

---

# 19. Archive

References should support archive/restore.

Archive is the normal way to retire stale information.

Example:

```text
[ Archive ]
```

moves the Reference out of the default active list.

Sidebar:

```text
Reference
  All
  Recent
  Archived
```

Archived References remain searchable when the user explicitly includes archived content.

Restore should return the Reference to active status.

---

# 20. Deletion

Use the existing universal `ConfirmModal`.

Deleting a Reference must not be instantaneous.

Example:

```text
Delete Reference?

"John"

This permanently deletes the reference.

[ Cancel ] [ Delete ]
```

Do not introduce another confirmation component.

Reuse the existing one.

---

# 21. Empty States

Create useful empty states.

No References:

```text
REFERENCE

Nothing here yet.

References are for information you want to keep,
but don't need to complete.

Examples:
  Phone numbers
  Addresses
  Keywords
  URLs
  Short notes

[ + NEW REFERENCE ]
```

No search results:

```text
No references found for:

"98765"
```

Archived empty:

```text
No archived references.
```

Keep the language concise and terminal-like.

---

# 22. Offline-First Android

The Android application must support References completely offline.

A user must be able to:

* create Reference offline
* edit Reference offline
* delete Reference offline
* archive Reference offline
* restore Reference offline
* search Reference offline
* view Reference offline
* copy Reference offline
* use smart actions when the OS/network permits

Do not require login to use local References.

This is consistent with the existing guest/offline-first behavior.

---

# 23. Android Storage

Extend the existing local storage/database system with a Reference table/model.

Recommended model:

```dart
class Reference {
  final String id;
  final String? userId;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
}
```

Adapt to existing Dart model conventions.

Make deserialization defensive, matching the existing robustness work.

Handle:

* null
* String/int/bool conversions where applicable
* missing optional fields
* malformed tags
* older cached data

Do not allow a malformed Reference to crash the Android application.

---

# 24. Sync

Integrate References into the existing bidirectional synchronization mechanism.

Required operations:

```text
Local create
→ server create

Local update
→ server update

Local archive
→ server archive

Local restore
→ server restore

Local delete
→ server delete

Server create
→ local create

Server update
→ local update

Server archive
→ local archive

Server delete
→ local delete
```

The existing sync architecture should be reused.

Do not create a completely separate synchronization protocol.

---

# 25. Offline Conflict Handling

Follow the existing Todo Next synchronization/conflict strategy.

At minimum:

* preserve local changes until successfully synced
* avoid silently losing Reference content
* use timestamps consistently
* handle deleted/archived records safely
* avoid resurrecting deleted References unintentionally

If the existing system does not have formal conflict resolution, implement a conservative last-write-wins strategy based on `updatedAt`, consistent with the existing architecture.

Document the behavior.

---

# 26. Flutter UI

Add:

```text
flutter_app/lib/models/reference.dart

flutter_app/lib/widgets/reference/
    reference_list.dart
    reference_item.dart
    reference_editor.dart
    reference_detail.dart
```

If the existing modular architecture suggests different names, follow its conventions.

The UI must work on:

* phone
* tablet
* portrait
* landscape

Tablet:

```text
Sidebar | Reference Workspace | Inspector
```

Phone:

```text
Reference Workspace
        ↓
Inspector slides in
```

Match the existing Task interaction pattern.

---

# 27. Theme Integration

References must work perfectly with all five themes:

* Pitch Black
* Clean White
* Catppuccin Mocha
* Gruvbox Dark
* Paper & Ink

Do not hard-code colors.

Use the existing theme variables / `AppTheme`.

Ensure:

* Reference list
* editor
* inspector
* empty states
* search
* archive state
* dialogs
* tags
* buttons

all render correctly in every theme.

---

# 28. Web Offline Behavior

The web application already caches Tasks/Templates in localStorage.

Extend this architecture to References.

On startup:

1. hydrate cached References immediately
2. render UI
3. fetch server References concurrently
4. reconcile/update local cache
5. update UI

Do not make References introduce a noticeable startup delay.

Follow the existing performance strategy:

```text
local cache
    ↓
instant UI
    ↓
server sync
```

---

# 29. Performance

References should be cheap.

Avoid:

* N+1 database queries
* fetching all tags independently
* unnecessary API calls
* blocking authentication
* blocking initial rendering
* repeated parsing of the same content

Use batching where the existing DB layer supports it.

If listing References and their tags requires multiple queries, use efficient batching.

---

# 30. Accessibility

Even though Todo Next is terminal-styled, the UI must remain usable.

Provide:

* keyboard focus
* visible focus states
* semantic buttons
* accessible labels
* adequate contrast
* screen-reader-friendly action names
* mobile touch targets

Do not sacrifice usability for terminal aesthetics.

---

# 31. Mobile Smart Actions

On Android:

Phone:

```text
[ Call ]
```

URL:

```text
[ Open ]
```

Email:

```text
[ Email ]
```

Address:

```text
[ Map ]
```

Use safe native intents.

Do not request unnecessary Android permissions.

Calling a phone number should preferably launch the dialer rather than silently initiate a call.

---

# 32. Tags

Reference tags should integrate with the existing tag system where possible.

Examples:

```text
@people
@places
@home
@work

+project-x
+client-acme
```

Do not automatically create task filters from Reference tags unless that is already a shared architecture.

A tag used only by References should still work correctly.

If the existing Sidebar aggregates tags across Tasks, decide explicitly whether Reference tags participate.

Preferred behavior:

* task tags remain task-oriented
* Reference tags are available inside Reference workspace
* do not unexpectedly change existing Task tag counts/filters

If a shared tag system is already present, preserve its semantics and clearly distinguish Reference filtering from Task filtering.

---

# 33. Reference Sorting

Default:

```text
Updated Date Descending
```

This makes recently used information easy to find.

Offer:

```text
Updated
Created
Alphabetical
```

with ascending/descending where appropriate.

Do not reuse task-specific sorting such as priority or due date.

---

# 34. Recent References

Provide a simple Recent view.

Recommended definition:

```text
updatedAt within the most recent N items
```

Do not overcomplicate it with a configurable time window initially.

Example:

```text
REFERENCE
> Recent
```

shows the most recently created/updated active References.

---

# 35. Reference Detail Formatting

Plain text should remain plain text.

Preserve:

* line breaks
* whitespace where meaningful
* URLs
* phone numbers
* email addresses

If the project already has `FormattedText`, consider whether it can safely render Reference content.

Do not allow Reference rendering to accidentally interpret task syntax as actionable Task metadata.

For example:

```text
(A) Important information
due:2026-08-20
rec:1w
```

inside a Reference must remain **content**.

It must not become a recurring Task.

---

# 36. Todo.txt Boundary

This is critical.

Do not modify the fundamental Task parser so that References become fake todo.txt entries.

Do not encode References as:

```text
NOTE:
REF:
R:
```

inside the Task database.

Do not give References:

* priorities
* due dates
* recurrence
* completion
* subtasks

unless a future feature explicitly introduces a separate Reference capability.

Keep the architecture:

```text
                 Todo Next
                    │
          ┌─────────┴─────────┐
          │                   │
        Tasks             References
          │                   │
      todo.txt          lightweight data
      semantics             storage
```

---

# 37. Command Documentation

Update the existing Syntax Guide.

Add:

```text
REFERENCE COMMANDS

:refs
  Open Reference workspace

:ref
  Create a new Reference

:ref <title>
  Create a Reference with a pre-filled title
```

If quick-create is implemented, document its exact syntax.

Also explain:

```text
TASK
Things you need to do.

REFERENCE
Things you need to keep or remember.
```

---

# 38. Settings

Do not create a separate Reference settings system.

If appropriate, add only small relevant settings such as:

* show archived references
* default Reference sort

Do not overbuild configuration.

---

# 39. API Error Handling

Follow the existing API error format.

Return appropriate HTTP codes:

```text
400 invalid input
401 unauthenticated
403 unauthorized
404 reference not found
409 conflict where appropriate
500 unexpected server error
```

Include useful server-side diagnostics consistent with existing logging.

Do not leak:

* database internals
* authentication secrets
* other users' data
* stack traces to clients

---

# 40. Tests — Web

Add comprehensive tests.

At minimum:

## Database

* create Reference
* read Reference
* update Reference
* archive
* restore
* delete
* search
* tags
* user isolation

## API

* authentication required
* valid create
* invalid create
* update
* delete
* archive
* restore
* cross-user access denied
* search
* archived filtering

## UI

* Reference workspace renders
* empty state
* create Reference
* edit Reference
* delete confirmation
* archive
* restore
* search
* tag filter
* Inspector integration
* keyboard navigation where testable

## Regression

Existing Task tests must continue passing.

---

# 41. Tests — Flutter

Add:

```text
reference_model_test.dart
reference_storage_test.dart
reference_widget_test.dart
reference_editor_test.dart
reference_search_test.dart
reference_sync_test.dart
```

Adapt naming to existing conventions.

Test:

* JSON parsing
* malformed JSON resilience
* local CRUD
* archive/restore
* search
* rendering
* editor
* offline behavior
* sync behavior
* phone/tablet layouts where practical

Existing:

```text
flutter analyze
flutter test
```

must continue to pass.

---

# 42. Migration Safety

The Reference migration must be additive.

Existing:

* Tasks
* Templates
* Users
* recurrence
* comments
* subtasks

must remain untouched except where explicitly required for shared infrastructure.

The migration must be safe for existing production databases.

Do not require manual destructive database operations.

---

# 43. Backward Compatibility

Existing users must see exactly the same Task behavior after upgrading.

No existing Task should:

* become a Reference
* disappear
* change status
* change due date
* lose recurrence
* lose subtasks
* lose comments
* lose tags

Do not perform automatic heuristic conversion of existing Tasks into References.

This feature starts empty for existing users unless the user explicitly creates References.

---

# 44. UX Copy

Use concise language.

Preferred:

```text
Reference
References
New Reference
Archive
Restore
Copy
Search references
```

Avoid:

```text
Knowledge Base
Personal Wiki
Document
Database Entry
Note-taking System
```

The feature should feel lightweight.

---

# 45. Visual Identity

Reference UI should look like it belongs to Todo Next.

Use:

* terminal typography
* existing borders
* existing syntax colors
* existing spacing
* existing modal style
* existing buttons
* existing Inspector patterns
* existing status bar
* existing theme system

Do not introduce a visually unrelated card-heavy SaaS design.

References can have subtle visual distinction, for example:

```text
REF
```

or:

```text
▸
```

rather than a checkbox.

---

# 46. Recommended Reference Icons

If icons are already used, keep them subtle.

Possible:

```text
▸ Reference
```

or:

```text
[REF]
```

Avoid introducing large emoji-heavy UI.

The terminal aesthetic should remain primary.

---

# 47. Smart Type Detection

Implement a reusable utility for recognizing common content types.

Conceptually:

```ts
type ReferenceAction =
  | "phone"
  | "email"
  | "url"
  | "address"
  | "copy";
```

The detector should be conservative.

False positives are worse than missing a convenience action.

The detector must never mutate content.

For example:

```text
+91 98765 43210
```

may produce:

```text
phone
```

but:

```text
Order number 98765 43210
```

should not necessarily be treated as a phone number.

Keep detection heuristic and optional.

---

# 48. Security of Sensitive References

References may contain sensitive information.

Do not log Reference contents.

Do not include Reference content in:

```text
console.log()
console.error()
analytics events
telemetry
error messages
```

unless explicitly required and safely redacted.

Never expose Reference content in health diagnostics.

Never include content in URLs.

Be particularly careful with:

* passwords
* API keys
* access codes
* account numbers

The UI should not claim that References are a secure password manager.

This is a lightweight information store, not a dedicated secrets vault.

---

# 49. Sync Security

Reference content must be transmitted only through authenticated API calls.

Do not:

* put content into query strings unnecessarily
* log request bodies
* expose content in diagnostics
* cache another user's Reference data

Respect the existing Firebase authentication model.

---

# 50. Android Permissions

Do not add permissions merely because smart actions exist.

For phone:

* launch dialer
* do not silently call

For maps:

* launch map URL/application
* no location permission required merely to open a map

For email:

* launch email client

Keep permissions minimal.

---

# 51. Documentation

Update:

```text
HANDOFF.md
```

because the project's explicit operating rule requires HANDOFF.md to be updated after significant feature work.

Document:

* Reference feature
* database schema
* API routes
* web components
* Flutter components
* sync behavior
* commands
* tests
* architectural decisions
* migration
* any limitations

Also update relevant:

```text
README
Syntax Guide
feature documentation
```

if those documents exist.

Do not create redundant documentation if an existing document is the appropriate location.

---

# 52. HANDOFF Requirement

At the end of implementation:

1. Update `HANDOFF.md`.
2. Clearly document the Reference system.
3. Record all new files.
4. Record schema changes.
5. Record API changes.
6. Record Flutter changes.
7. Record web changes.
8. Record sync behavior.
9. Record test status.
10. Record any known limitations.

Then:

```bash
git status
git diff
```

Review all changes.

Commit the implementation with a meaningful commit message.

Push the commit to the configured remote according to the project's normal workflow.

If pushing is unavailable, clearly report that the commit was created but could not be pushed.

---

# 53. Quality Gate

Before declaring the feature complete, verify:

## Web

```bash
npm test
npm run lint
npm run build
```

or the project's actual equivalent commands.

## Flutter

```bash
flutter analyze
flutter test
```

No analyzer errors.

No test regressions.

## Database

Verify migration succeeds against:

* fresh database
* existing database
* production-like schema

## Authentication

Verify:

* logged-out API rejected
* logged-in API works
* user A cannot access user B's Reference

## UI

Manually verify:

* Pitch Black
* Clean White
* Catppuccin Mocha
* Gruvbox Dark
* Paper & Ink

on:

* desktop
* phone
* tablet

## Offline

Verify:

* create offline
* edit offline
* archive offline
* delete offline
* restart application
* data persists
* reconnect
* data synchronizes

---

# 54. Definition of Done

The Reference feature is complete only when all of the following are true:

### Architecture

* [ ] Reference is a first-class domain object
* [ ] Task architecture remains unchanged
* [ ] todo.txt parser remains Task-focused
* [ ] Reference has no completion semantics

### Database

* [ ] References table exists
* [ ] user isolation enforced
* [ ] migration implemented
* [ ] CRUD implemented
* [ ] archive implemented
* [ ] restore implemented
* [ ] search implemented
* [ ] tags supported

### API

* [ ] authenticated CRUD
* [ ] archive/restore
* [ ] search
* [ ] tag filtering
* [ ] secure user isolation
* [ ] correct error handling

### Web

* [ ] Sidebar integration
* [ ] Reference workspace
* [ ] Reference list
* [ ] Reference editor
* [ ] Inspector integration
* [ ] search
* [ ] archive
* [ ] restore
* [ ] delete confirmation
* [ ] copy
* [ ] smart actions
* [ ] keyboard navigation
* [ ] all themes supported
* [ ] local cache/offline hydration

### Flutter

* [ ] Reference model
* [ ] local persistence
* [ ] offline CRUD
* [ ] sync
* [ ] Reference workspace
* [ ] editor
* [ ] inspector/detail
* [ ] search
* [ ] archive/restore
* [ ] delete confirmation
* [ ] copy
* [ ] native smart actions
* [ ] phone layout
* [ ] tablet layout
* [ ] all themes supported

### Commands

* [ ] `:refs`
* [ ] `:ref`
* [ ] `:ref <title>`
* [ ] documentation updated

### Security

* [ ] no cross-user access
* [ ] no content logging
* [ ] no content in diagnostics
* [ ] no unnecessary permissions
* [ ] authenticated sync

### Quality

* [ ] tests added
* [ ] existing tests pass
* [ ] Flutter analyze passes
* [ ] build passes
* [ ] migration tested
* [ ] HANDOFF.md updated
* [ ] changes committed
* [ ] changes pushed

---

# 55. Important Implementation Principle

Do not interpret this specification as a reason to over-engineer.

The flagship quality comes from **integration and polish**, not from making the Reference model complicated.

The ideal Reference is:

```text
┌─────────────────────────────────────────┐
│ John                                    │
│                                         │
│ +91 98765 43210                         │
│                                         │
│ @people                                 │
│                                         │
│ [ Copy ] [ Call ]                       │
└─────────────────────────────────────────┘
```

It should take seconds to create, seconds to find, and seconds to copy.

The user should never wonder:

> "Why isn't this a Task?"

The answer should be obvious:

> "Because I don't need to do anything with it. I just need to keep it."

That is the core UX principle of the entire feature.

# Final Instruction to the Coding Agent

Work directly in the existing Todo Next repository.

First inspect the current implementation and identify the exact files, database abstractions, authentication helpers, synchronization mechanisms, web components, Flutter services, and test infrastructure that should be extended.

Then implement the Reference system end-to-end.

Prefer existing project patterns over introducing new frameworks or architectural layers.

Do not rewrite unrelated code.

Do not regress Tasks, Templates, Recurrence, Calendar, Subtasks, Comments, Themes, Authentication, Offline Mode, or Sync.

Implement the feature incrementally, testing after each major layer.

When complete, run the full relevant test/build/analyzer suite, update `HANDOFF.md`, review the diff, commit the changes, and push them according to the project's normal workflow.

The final result should feel like a **native part of Todo Next**, not an add-on.
