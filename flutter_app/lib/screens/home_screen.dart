import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/comment.dart';
import '../models/template.dart';
import '../models/reference.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../utils/todo_parser.dart';
import '../utils/template_engine.dart';
import '../utils/recurrence_engine.dart';
import '../utils/reference_utils.dart';
import '../utils/command_parser.dart';
import '../theme/app_theme.dart';
import '../widgets/command_input.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_list.dart';
import '../widgets/calendar_view.dart';
import '../widgets/inspector_drawer.dart';
import '../widgets/reference/reference_list.dart';
import '../widgets/reference/reference_drawer.dart';
import '../widgets/reference/reference_editor_dialog.dart';
import '../widgets/settings_modal.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/login_dialog.dart';
import '../widgets/status_bar.dart';
import '../widgets/modals/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  final AppThemeId currentTheme;
  final Function(AppThemeId theme) onSelectTheme;
  final VoidCallback onToggleTheme;
  final bool isLight;
  final AppFontSize currentFontSize;
  final Function(AppFontSize size)? onSelectFontSize;

  const HomeScreen({
    super.key,
    required this.currentTheme,
    required this.onSelectTheme,
    required this.onToggleTheme,
    required this.isLight,
    this.currentFontSize = AppFontSize.normal,
    this.onSelectFontSize,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _commandController = TextEditingController();

  List<Task> _tasks = [];
  List<Template> _templates = [];
  List<Reference> _references = [];
  Task? _selectedTask;
  Reference? _selectedReference;
  String _activeFilter = '';
  String _activeView = 'list'; // 'list' | 'calendar' | 'references'
  String _syncStatus = 'synced'; // 'synced' | 'syncing' | 'offline'
  bool _isLoading = true;
  bool _showIcons = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initAndLoadData();
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _initAndLoadData() async {
    // 1. Instant Offline-First Hydration (0ms load time)
    try {
      final localTasks = await _storageService.loadTasks();
      final localTemplates = await _storageService.loadTemplates();
      final localReferences = await _storageService.loadReferences();
      final savedShowIcons = await _storageService.loadShowIcons();

      if (mounted) {
        setState(() {
          _tasks = localTasks;
          _templates = localTemplates;
          _references = localReferences;
          _showIcons = savedShowIcons;
          if (_tasks.isNotEmpty && _selectedTask == null) {
            _selectedTask = _tasks.first;
          }
          if (_references.isNotEmpty && _selectedReference == null) {
            _selectedReference = _references.first;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // 2. Non-blocking Background API Sync
    _syncRemoteData();
  }

  Future<void> _syncRemoteData() async {
    if (mounted) setState(() => _syncStatus = 'syncing');

    try {
      await ApiService.init();

      // Parallel remote fetch
      final authFuture = ApiService.checkAuthStatus();
      final dataFuture = Future.wait([
        ApiService.fetchTasks(),
        ApiService.fetchTemplates(),
        ApiService.fetchReferences(),
      ]);

      await authFuture;
      final results = await dataFuture;
      final remoteTasks = results[0] as List<Task>?;
      final remoteTemplates = results[1] as List<Template>?;
      final remoteReferences = results[2] as List<Reference>?;

      if (remoteTasks != null) {
        if (mounted) {
          setState(() {
            _tasks = remoteTasks;
            if (remoteTemplates != null) _templates = remoteTemplates;
            if (remoteReferences != null) _references = remoteReferences;

            if (_tasks.isNotEmpty) {
              final stillExists = _tasks.any((t) => t.id == _selectedTask?.id);
              if (!stillExists) _selectedTask = _tasks.first;
            }
            if (_references.isNotEmpty) {
              final refExists = _references.any((r) => r.id == _selectedReference?.id);
              if (!refExists) _selectedReference = _references.first;
            }
            _syncStatus = 'synced';
          });
        }
        await _storageService.saveTasks(remoteTasks);
        if (remoteTemplates != null) await _storageService.saveTemplates(remoteTemplates);
        if (remoteReferences != null) await _storageService.saveReferences(remoteReferences);
      } else {
        if (mounted) setState(() => _syncStatus = 'offline');
      }
    } catch (_) {
      if (mounted) setState(() => _syncStatus = 'offline');
    }
  }

  void _openLoginModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginDialogWidget(
        isLight: widget.isLight,
        onLoginSuccess: _syncRemoteData,
      ),
    );
  }

  List<Task> _getFilteredTasks() {
    List<Task> result = List.from(_tasks);
    if (_activeFilter.isNotEmpty) {
      if (_activeFilter.startsWith('+') || _activeFilter.startsWith('@')) {
        result = result.where((t) =>
          t.projects.contains(_activeFilter) || t.contexts.contains(_activeFilter)
        ).toList();
      } else {
        final q = _activeFilter.toLowerCase();
        result = result.where((t) =>
          t.raw.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)
        ).toList();
      }
    }
    return result;
  }

  void _selectTaskAndOpenInspector(Task task, bool isTablet) {
    setState(() {
      _selectedTask = task;
    });
    if (!isTablet) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _selectReferenceAndOpenInspector(Reference reference, bool isTablet) {
    setState(() {
      _selectedReference = reference;
    });
    if (!isTablet) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  // --- TASK CRUD HANDLERS ---
  Future<void> _handleToggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final isNowCompleted = !task.completed;
    final today = DateTime.now().toIso8601String().split('T')[0];

    String newRaw = task.raw;
    if (isNowCompleted) {
      newRaw = 'x $today ${task.raw.replaceAll(RegExp(r'^\([A-Z]\)\s'), '')}';
    } else {
      newRaw = task.raw.replaceAll(RegExp(r'^x\s+\d{4}-\d{2}-\d{2}\s+'), '');
      if (task.priority != null) newRaw = '(${task.priority}) $newRaw';
    }

    final updated = task.copyWith(
      completed: isNowCompleted,
      status: isNowCompleted ? 'completed' : 'open',
      raw: newRaw,
      completionDate: isNowCompleted ? today : null,
    );

    Task? nextInstance;
    if (isNowCompleted && task.recurrence != null) {
      nextInstance = spawnNextRecurrenceInstance(task, today);
    }

    setState(() {
      _tasks[index] = updated;
      if (nextInstance != null) {
        _tasks.insert(0, nextInstance);
      }
      if (_selectedTask?.id == id) {
        _selectedTask = updated;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.updateTask(id, {
      'completed': isNowCompleted,
      'status': isNowCompleted ? 'completed' : 'open',
      'raw': newRaw,
      'completionDate': isNowCompleted ? today : null,
    });

    if (nextInstance != null) {
      await ApiService.createTask(nextInstance);
    }

    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleSkipRecurrence(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    if (task.recurrence == null) return;

    final skipped = skipRecurrenceOccurrence(task);

    setState(() {
      _tasks[index] = skipped;
      if (_selectedTask?.id == id) {
        _selectedTask = skipped;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.updateTask(id, {
      'dueDate': skipped.dueDate,
      'raw': skipped.raw,
    });
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleUpdateTask(String id, Map<String, dynamic> updates) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final old = _tasks[index];
    final updated = old.copyWith(
      title: updates['title'] ?? old.title,
      raw: updates['raw'] ?? old.raw,
      description: updates['description'] ?? old.description,
      priority: updates.containsKey('priority') ? updates['priority'] : old.priority,
      dueDate: updates.containsKey('dueDate') ? updates['dueDate'] : old.dueDate,
      dueTime: updates.containsKey('dueTime') ? updates['dueTime'] : old.dueTime,
      recurrence: updates.containsKey('recurrence') ? updates['recurrence'] : old.recurrence,
      projects: updates['projects'] != null ? List<String>.from(updates['projects']) : old.projects,
      contexts: updates['contexts'] != null ? List<String>.from(updates['contexts']) : old.contexts,
      subtasks: updates['subtasks'] != null
          ? (updates['subtasks'] as List).map((s) => Subtask.fromJson(s)).toList()
          : old.subtasks,
      comments: updates['comments'] != null
          ? (updates['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : old.comments,
    );

    setState(() {
      _tasks[index] = updated;
      if (_selectedTask?.id == id) {
        _selectedTask = updated;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.updateTask(id, updates);
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleMoveTask(String taskId, String targetDate, String? targetTime) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final newRaw = updateRawDates(
      task.raw,
      newCreationDate: task.creationDate,
      newDueDate: targetDate,
      newTime: targetTime,
    );
    final parsed = parseRawToStructured(newRaw, task.creationDate);

    final updates = {
      'raw': newRaw,
      'dueDate': parsed.dueDate,
      'dueTime': parsed.dueTime,
      'creationDate': parsed.creationDate,
    };

    await _handleUpdateTask(taskId, updates);
  }

  void _handleDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialogWidget(
        title: 'DELETE TASK',
        message: 'Are you sure you want to delete task "${task.title}"?',
        isLight: widget.isLight,
        onConfirm: () async {
          setState(() {
            _tasks.removeWhere((t) => t.id == task.id);
            if (_selectedTask?.id == task.id) {
              _selectedTask = _tasks.isNotEmpty ? _tasks.first : null;
            }
            _syncStatus = 'syncing';
          });

          await _storageService.saveTasks(_tasks);

          final ok = await ApiService.deleteTask(task.id);
          if (mounted) {
            setState(() {
              _syncStatus = ok ? 'synced' : 'offline';
            });
          }
        },
      ),
    );
  }

  // --- TEMPLATE HANDLERS ---
  Future<void> _handleInstantiateTemplate(String templateId) async {
    final tmpl = _templates.firstWhere(
      (t) => t.id == templateId || t.name.toLowerCase() == templateId.toLowerCase(),
      orElse: () => _templates.first,
    );

    final newTask = instantiateTaskFromTemplate(tmpl);

    setState(() {
      _tasks.insert(0, newTask);
      _selectedTask = newTask;
      _activeView = 'list';
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final created = await ApiService.createTask(newTask);
    if (mounted) {
      setState(() {
        _syncStatus = created != null ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleSaveAsTemplate(Task task) async {
    final newTmpl = Template(
      id: 'tmpl-${DateTime.now().millisecondsSinceEpoch}',
      name: task.title.isNotEmpty ? task.title : 'Saved Task Template',
      rawTemplate: task.raw,
      description: task.description,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      projects: task.projects,
      contexts: task.contexts,
      subtasks: task.subtasks.asMap().entries.map((e) {
        return TemplateSubtask(
          id: 'tmpls-${DateTime.now().millisecondsSinceEpoch}-${e.key}',
          title: e.value.raw.isNotEmpty ? e.value.raw : e.value.title,
          position: e.key,
        );
      }).toList(),
    );

    await _handleCreateTemplate(newTmpl);
    _openTemplatesModal();
  }

  Future<void> _handleCreateTemplate(Template template) async {
    setState(() {
      _templates.insert(0, template);
      _syncStatus = 'syncing';
    });

    await _storageService.saveTemplates(_templates);

    final ok = await ApiService.createTemplate(template);
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleUpdateTemplate(String id, Map<String, dynamic> updates) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final old = _templates[index];
    final updated = old.copyWith(
      name: updates['name'] ?? old.name,
      rawTemplate: updates['rawTemplate'] ?? old.rawTemplate,
      description: updates['description'] ?? old.description,
      updatedAt: DateTime.now().toIso8601String(),
      projects: updates['projects'] != null ? List<String>.from(updates['projects']) : old.projects,
      contexts: updates['contexts'] != null ? List<String>.from(updates['contexts']) : old.contexts,
      subtasks: updates['subtasks'] != null
          ? (updates['subtasks'] as List).map((s) => TemplateSubtask.fromJson(s)).toList()
          : old.subtasks,
    );

    setState(() {
      _templates[index] = updated;
      _syncStatus = 'syncing';
    });

    await _storageService.saveTemplates(_templates);

    final ok = await ApiService.updateTemplate(id, updates);
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleDeleteTemplate(String templateId) async {
    setState(() {
      _templates.removeWhere((t) => t.id == templateId);
      _syncStatus = 'syncing';
    });

    await _storageService.saveTemplates(_templates);

    final ok = await ApiService.deleteTemplate(templateId);
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  // --- REFERENCE HANDLERS ---
  void _openNewReferenceDialog([String? initialTitle, String? initialContent]) {
    showDialog(
      context: context,
      builder: (context) => ReferenceEditorDialog(
        isLight: widget.isLight,
        initialTitle: initialTitle,
        initialContent: initialContent,
        onSave: (title, content, tags) {
          _handleCreateReference(title, content, tags);
        },
      ),
    );
  }

  void _openEditReferenceDialog(Reference ref) {
    showDialog(
      context: context,
      builder: (context) => ReferenceEditorDialog(
        reference: ref,
        isLight: widget.isLight,
        onSave: (title, content, tags) {
          _handleUpdateReference(ref.id, {
            'title': title,
            'content': content,
            'tags': tags,
          });
        },
      ),
    );
  }

  Future<void> _handleCreateReference(String title, String content, List<String> tags) async {
    final now = DateTime.now().toIso8601String();
    final newRef = Reference(
      id: 'ref-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      archived: false,
    );

    setState(() {
      _references.insert(0, newRef);
      _selectedReference = newRef;
      _activeView = 'references';
      _syncStatus = 'syncing';
    });

    await _storageService.saveReferences(_references);

    final created = await ApiService.createReference(newRef);
    if (mounted) {
      setState(() {
        _syncStatus = created != null ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleUpdateReference(String id, Map<String, dynamic> updates) async {
    final index = _references.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final old = _references[index];
    final updated = old.copyWith(
      title: updates['title'] ?? old.title,
      content: updates['content'] ?? old.content,
      tags: updates['tags'] != null ? List<String>.from(updates['tags']) : old.tags,
      archived: updates.containsKey('archived') ? updates['archived'] as bool : old.archived,
      updatedAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _references[index] = updated;
      if (_selectedReference?.id == id) {
        _selectedReference = updated;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveReferences(_references);

    final ok = await ApiService.updateReference(id, updates);
    if (mounted) {
      setState(() {
        _syncStatus = ok ? 'synced' : 'offline';
      });
    }
  }

  Future<void> _handleArchiveReference(String id, bool archive) async {
    await _handleUpdateReference(id, {'archived': archive});
  }

  void _handleDeleteReference(Reference ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialogWidget(
        title: 'DELETE REFERENCE',
        message: 'Are you sure you want to delete reference "${ref.title}"?',
        isLight: widget.isLight,
        onConfirm: () async {
          setState(() {
            _references.removeWhere((r) => r.id == ref.id);
            if (_selectedReference?.id == ref.id) {
              _selectedReference = _references.isNotEmpty ? _references.first : null;
            }
            _syncStatus = 'syncing';
          });

          await _storageService.saveReferences(_references);

          final ok = await ApiService.deleteReference(ref.id);
          if (mounted) {
            setState(() {
              _syncStatus = ok ? 'synced' : 'offline';
            });
          }
        },
      ),
    );
  }

  // --- COMMAND BAR HANDLER ---
  Future<void> _handleCommandSubmit(String val) async {
    final cmd = CommandParser.parse(val);
    if (cmd == null) return;

    if (cmd is OpenSettingsCommand) {
      _openSettingsModal(cmd.tabIndex);
      _commandController.clear();
      return;
    }

    if (cmd is ChangeThemeCommand) {
      final mappedTheme = AppTheme.fromKey(cmd.themeKey);
      widget.onSelectTheme(mappedTheme);
      _commandController.clear();
      return;
    }

    if (cmd is FilterRecurringCommand) {
      setState(() => _activeFilter = 'rec:');
      _commandController.clear();
      return;
    }

    if (cmd is SkipRecurrenceCommand) {
      if (_selectedTask != null) {
        await _handleSkipRecurrence(_selectedTask!.id);
        _commandController.clear();
      }
      return;
    }

    if (cmd is SetRecurrenceCommand) {
      if (_selectedTask != null) {
        final newRaw = buildRawFromStructured(
          title: _selectedTask!.title,
          priority: _selectedTask!.priority,
          creationDate: _selectedTask!.creationDate,
          completionDate: _selectedTask!.completionDate,
          dueDate: _selectedTask!.dueDate,
          dueTime: _selectedTask!.dueTime,
          recurrence: cmd.rule,
          completed: _selectedTask!.completed,
          projects: _selectedTask!.projects,
          contexts: _selectedTask!.contexts,
        );
        await _handleUpdateTask(_selectedTask!.id, {'recurrence': cmd.rule, 'raw': newRaw});
        _commandController.clear();
      }
      return;
    }

    if (cmd is OpenReferencesCommand) {
      setState(() => _activeView = 'references');
      _commandController.clear();
      return;
    }

    if (cmd is OpenNewReferenceCommand) {
      _openNewReferenceDialog(cmd.initialTitle);
      _commandController.clear();
      return;
    }

    if (cmd is QuickCreateReferenceCommand) {
      final autoTags = ReferenceUtils.extractTagsFromText('${cmd.title} ${cmd.content}');
      await _handleCreateReference(cmd.title, cmd.content, autoTags);
      _commandController.clear();
      return;
    }

    if (cmd is OpenTemplatesCommand) {
      _openTemplatesModal();
      _commandController.clear();
      return;
    }

    if (cmd is UseTemplateCommand) {
      await _handleInstantiateTemplate(cmd.templateName);
      _commandController.clear();
      return;
    }

    if (cmd is SaveTemplateCommand) {
      if (_selectedTask != null) {
        await _handleSaveAsTemplate(_selectedTask!);
      }
      _commandController.clear();
      return;
    }

    if (cmd is AddTaskCommand) {
      final parsed = parseRawToStructured(cmd.rawTask);

      final newTask = Task(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        title: parsed.title,
        raw: cmd.rawTask,
        status: parsed.completed ? 'completed' : 'open',
        completed: parsed.completed,
        priority: parsed.priority,
        creationDate: parsed.creationDate,
        dueDate: parsed.dueDate,
        dueTime: parsed.dueTime,
        recurrence: parsed.recurrence,
        description: '',
        projects: parsed.projects,
        contexts: parsed.contexts,
        subtasks: [],
        comments: [],
      );

      setState(() {
        _tasks.insert(0, newTask);
        _selectedTask = newTask;
        _activeView = 'list';
        _commandController.clear();
        _syncStatus = 'syncing';
      });

      await _storageService.saveTasks(_tasks);

      final created = await ApiService.createTask(newTask);
      if (mounted) {
        setState(() {
          _syncStatus = created != null ? 'synced' : 'offline';
        });
      }
      return;
    }

    if (cmd is SetFilterCommand) {
      setState(() {
        _activeFilter = cmd.filterQuery;
      });
    }
  }

  void _openAddTaskModal() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        isLight: widget.isLight,
        onCommandSubmit: _handleCommandSubmit,
      ),
    );
  }

  void _toggleShowIcons(bool value) {
    setState(() => _showIcons = value);
    _storageService.saveShowIcons(value);
  }

  void _openSettingsModal([int initialTab = 0]) {
    showDialog(
      context: context,
      builder: (context) => SettingsModalWidget(
        templates: _templates,
        isLight: widget.isLight,
        currentTheme: widget.currentTheme,
        onSelectTheme: widget.onSelectTheme,
        onInstantiateTemplate: _handleInstantiateTemplate,
        onCreateTemplate: _handleCreateTemplate,
        onUpdateTemplate: _handleUpdateTemplate,
        onDeleteTemplate: _handleDeleteTemplate,
        onForceSync: _syncRemoteData,
        userEmail: ApiService.userEmail,
        syncStatus: _syncStatus,
        showIcons: _showIcons,
        onToggleIcons: _toggleShowIcons,
        onLogout: () async {
          await ApiService.logout();
          setState(() {
            _tasks = [];
            _templates = [];
            _references = [];
            _selectedTask = null;
            _selectedReference = null;
          });
        },
        onLogin: _openLoginModal,
        initialTabIndex: initialTab,
        currentFontSize: widget.currentFontSize,
        onSelectFontSize: widget.onSelectFontSize,
      ),
    );
  }

  void _openTemplatesModal() {
    _openSettingsModal(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: widget.isLight ? Colors.white : Colors.black,
        body: Center(
          child: Text(
            'LOADING DATABASE...',
            style: AppTheme.monoStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.isLight ? Colors.cyan[900] : Colors.cyan[400],
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isReferenceView = _activeView == 'references';
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.isLight ? Colors.white : Colors.black,
      drawer: !isTablet
          ? Drawer(
              child: SidebarWidget(
                tasks: _tasks,
                references: _references,
                activeFilter: _activeFilter,
                activeView: _activeView,
                isLight: widget.isLight,
                showIcons: _showIcons,
                onChangeView: (view) {
                  setState(() => _activeView = view);
                  Navigator.of(context).pop();
                },
                onFilterClick: (filter) {
                  setState(() => _activeFilter = filter);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan[700],
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: Text(
          isReferenceView ? 'NEW REF' : 'NEW TASK',
          style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: isReferenceView ? () => _openNewReferenceDialog() : _openAddTaskModal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            CommandInputWidget(
              controller: _commandController,
              onSubmit: _handleCommandSubmit,
              onToggleSidebar: () {
                if (!isTablet) {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              onOpenTemplates: _openTemplatesModal,
              onOpenSettings: _openSettingsModal,
              onChangeView: (view) => setState(() => _activeView = view),
              activeView: _activeView,
              isLight: widget.isLight,
              showIcons: _showIcons,
            ),
            Expanded(
              child: Row(
                children: [
                  if (isTablet)
                    SidebarWidget(
                      tasks: _tasks,
                      references: _references,
                      activeFilter: _activeFilter,
                      activeView: _activeView,
                      isLight: widget.isLight,
                      showIcons: _showIcons,
                      onChangeView: (view) => setState(() => _activeView = view),
                      onFilterClick: (filter) => setState(() => _activeFilter = filter),
                    ),

                  // Middle Workspace View
                  Expanded(
                    child: isReferenceView
                        ? ReferenceListWidget(
                            references: _references,
                            selectedReferenceId: _selectedReference?.id,
                            isLight: widget.isLight,
                            activeFilter: _activeFilter,
                            showIcons: _showIcons,
                            onSelectReference: (r) => _selectReferenceAndOpenInspector(r, isTablet),
                            onDeleteReference: _handleDeleteReference,
                            onOpenNewReference: () => _openNewReferenceDialog(),
                          )
                        : _activeView == 'list'
                            ? TaskListWidget(
                                tasks: filteredTasks,
                                selectedTaskId: _selectedTask?.id,
                                isLight: widget.isLight,
                                showIcons: _showIcons,
                                onSelectTask: (t) => _selectTaskAndOpenInspector(t, isTablet),
                                onToggleTask: _handleToggleTask,
                                onDeleteTask: _handleDeleteTask,
                              )
                            : CalendarViewWidget(
                                tasks: filteredTasks,
                                selectedTaskId: _selectedTask?.id,
                                isLight: widget.isLight,
                                onSelectTask: (t) => _selectTaskAndOpenInspector(t, isTablet),
                                onToggleTask: _handleToggleTask,
                                onMoveTask: _handleMoveTask,
                                onCreateTaskAtDate: (dateISO, timeStr) {
                                  final timeTag = timeStr != null ? ' time:$timeStr' : '';
                                  _commandController.text = ':add (A) New task due:$dateISO$timeTag ';
                                },
                              ),
                  ),

                  // Tablet Right Drawer
                  if (isTablet)
                    isReferenceView
                        ? ReferenceDrawerWidget(
                            reference: _selectedReference,
                            isLight: widget.isLight,
                            showIcons: _showIcons,
                            onClose: () => setState(() => _selectedReference = null),
                            onEdit: _openEditReferenceDialog,
                            onArchive: _handleArchiveReference,
                            onDelete: _handleDeleteReference,
                          )
                        : InspectorDrawerWidget(
                            task: _selectedTask,
                            isLight: widget.isLight,
                            showIcons: _showIcons,
                            onClose: () => setState(() => _selectedTask = null),
                            onUpdateTask: _handleUpdateTask,
                            onSaveAsTemplate: _handleSaveAsTemplate,
                            onSkipRecurrence: _handleSkipRecurrence,
                          ),
                ],
              ),
            ),
            StatusBarWidget(
              filteredCount: isReferenceView ? _references.where((r) => !r.archived).length : filteredTasks.length,
              totalCount: isReferenceView ? _references.length : _tasks.length,
              activeFilter: _activeFilter,
              syncStatus: _syncStatus,
              isLight: widget.isLight,
              currentTheme: widget.currentTheme,
              onToggleTheme: widget.onToggleTheme,
              onForceSync: _syncRemoteData,
              showIcons: _showIcons,
            ),
          ],
        ),
      ),
      endDrawer: (!isTablet && (isReferenceView ? _selectedReference != null : _selectedTask != null))
          ? Drawer(
              width: screenWidth * 0.88,
              child: SafeArea(
                child: isReferenceView
                    ? ReferenceDrawerWidget(
                        reference: _selectedReference,
                        isLight: widget.isLight,
                        showIcons: _showIcons,
                        onClose: () => Navigator.of(context).pop(),
                        onEdit: (ref) {
                          Navigator.of(context).pop();
                          _openEditReferenceDialog(ref);
                        },
                        onArchive: (id, arch) {
                          _handleArchiveReference(id, arch);
                        },
                        onDelete: (ref) {
                          Navigator.of(context).pop();
                          _handleDeleteReference(ref);
                        },
                      )
                    : InspectorDrawerWidget(
                        task: _selectedTask,
                        isLight: widget.isLight,
                        showIcons: _showIcons,
                        onClose: () => Navigator.of(context).pop(),
                        onUpdateTask: _handleUpdateTask,
                        onSaveAsTemplate: _handleSaveAsTemplate,
                        onSkipRecurrence: _handleSkipRecurrence,
                      ),
              ),
            )
          : null,
    );
  }
}
