import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/comment.dart';
import '../models/template.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../utils/todo_parser.dart';
import '../utils/template_engine.dart';
import '../utils/recurrence_engine.dart';
import '../utils/command_parser.dart';
import '../theme/app_theme.dart';
import '../widgets/command_input.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_list.dart';
import '../widgets/calendar_view.dart';
import '../widgets/inspector_drawer.dart';
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

  const HomeScreen({
    super.key,
    required this.currentTheme,
    required this.onSelectTheme,
    required this.onToggleTheme,
    required this.isLight,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _commandController = TextEditingController();

  List<Task> _tasks = [];
  List<Template> _templates = [];
  Task? _selectedTask;
  String _activeFilter = '';
  String _activeView = 'list'; // 'list' | 'calendar'
  String _syncStatus = 'synced'; // 'synced' | 'syncing' | 'offline'
  bool _isLoading = true;

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
    try {
      await ApiService.init();

      final authStatus = await ApiService.checkAuthStatus();
      if (authStatus['authRequired'] == true && authStatus['authenticated'] != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LoginDialogWidget(
                isLight: widget.isLight,
                onLoginSuccess: () {
                  _loadDataFromWebOrCache();
                },
              ),
            );
          }
        });
      } else {
        await _loadDataFromWebOrCache();
      }
    } catch (_) {
      await _loadDataFromWebOrCache();
    }
  }

  Future<void> _loadDataFromWebOrCache() async {
    if (mounted) setState(() => _syncStatus = 'syncing');

    try {
      final remoteTasks = await ApiService.fetchTasks();
      final remoteTemplates = await ApiService.fetchTemplates();

      if (remoteTasks != null) {
        if (mounted) {
          setState(() {
            _tasks = remoteTasks;
            if (remoteTemplates != null) _templates = remoteTemplates;
            if (_tasks.isNotEmpty && _selectedTask == null) {
              _selectedTask = _tasks.first;
            }
            _syncStatus = 'synced';
            _isLoading = false;
          });
        }
        await _storageService.saveTasks(_tasks);
        if (remoteTemplates != null) await _storageService.saveTemplates(_templates);
        return;
      }
    } catch (_) {}

    // Offline fallback
    try {
      final localTasks = await _storageService.loadTasks();
      final localTemplates = await _storageService.loadTemplates();
      if (mounted) {
        setState(() {
          _tasks = localTasks;
          _templates = localTemplates;
          if (_tasks.isNotEmpty && _selectedTask == null) {
            _selectedTask = _tasks.first;
          }
          _syncStatus = 'offline';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _tasks = [];
          _templates = [];
          _syncStatus = 'offline';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleToggleTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final taskToUpdate = _tasks[idx];
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isNowCompleted = !taskToUpdate.completed;

    String newRaw = taskToUpdate.raw;
    if (isNowCompleted) {
      newRaw = 'x $today ${taskToUpdate.raw.replaceAll(RegExp(r'^\([A-Z]\)\s'), '')}';
    } else {
      newRaw = taskToUpdate.raw.replaceAll(RegExp(r'^x \d{4}-\d{2}-\d{2}\s'), '');
      if (taskToUpdate.priority != null && taskToUpdate.priority!.isNotEmpty) {
        newRaw = '(${taskToUpdate.priority}) $newRaw';
      }
    }

    final updatedTask = taskToUpdate.copyWith(
      completed: isNowCompleted,
      status: isNowCompleted ? 'completed' : 'open',
      raw: newRaw,
      completionDate: isNowCompleted ? today : null,
    );

    Task? nextTaskInstance;
    if (isNowCompleted && taskToUpdate.recurrence != null && taskToUpdate.recurrence!.isNotEmpty) {
      nextTaskInstance = spawnNextRecurrenceInstance(taskToUpdate, today);
    }

    // Optimistic UI update
    setState(() {
      _tasks[idx] = updatedTask;
      if (nextTaskInstance != null) {
        _tasks.insert(0, nextTaskInstance);
      }
      if (_selectedTask?.id == id) {
        _selectedTask = updatedTask;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    // Web API sync
    bool ok = false;
    if (isNowCompleted && taskToUpdate.recurrence != null && taskToUpdate.recurrence!.isNotEmpty) {
      ok = await ApiService.completeTask(id, today);
    } else {
      ok = await ApiService.updateTask(id, updatedTask.toJson());
    }

    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });
  }

  Future<void> _handleSkipRecurrence(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final taskToSkip = _tasks[idx];
    if (taskToSkip.recurrence == null || taskToSkip.recurrence!.isEmpty) return;

    final skipped = skipRecurrenceOccurrence(taskToSkip);

    setState(() {
      _tasks[idx] = skipped;
      if (_selectedTask?.id == id) {
        _selectedTask = skipped;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.skipTask(id);
    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });
  }

  Future<void> _handleUpdateTask(String id, Map<String, dynamic> updates) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final current = _tasks[idx];
    final updated = current.copyWith(
      raw: updates['raw'] as String? ?? current.raw,
      title: updates['title'] as String? ?? current.title,
      priority: updates.containsKey('priority') ? updates['priority'] as String? : current.priority,
      creationDate: updates['creationDate'] as String? ?? current.creationDate,
      completionDate: updates.containsKey('completionDate') ? updates['completionDate'] as String? : current.completionDate,
      dueDate: updates.containsKey('dueDate') ? updates['dueDate'] as String? : current.dueDate,
      dueTime: updates.containsKey('dueTime') ? updates['dueTime'] as String? : current.dueTime,
      recurrence: updates.containsKey('recurrence') ? updates['recurrence'] as String? : current.recurrence,
      completed: updates['completed'] as bool? ?? current.completed,
      status: updates['status'] as String? ?? current.status,
      description: updates['description'] as String? ?? current.description,
      projects: updates['projects'] != null ? List<String>.from(updates['projects']) : current.projects,
      contexts: updates['contexts'] != null ? List<String>.from(updates['contexts']) : current.contexts,
      subtasks: updates['subtasks'] != null
          ? (updates['subtasks'] as List).map((s) => Subtask.fromJson(Map<String, dynamic>.from(s))).toList()
          : current.subtasks,
      comments: updates['comments'] != null
          ? (updates['comments'] as List).map((c) => Comment.fromJson(Map<String, dynamic>.from(c))).toList()
          : current.comments,
    );

    setState(() {
      _tasks[idx] = updated;
      if (_selectedTask?.id == id) {
        _selectedTask = updated;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.updateTask(id, updates);
    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });
  }

  Future<void> _handleMoveTask(String taskId, String targetDate, String? targetTime) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    final taskToMove = _tasks[idx];
    final newRaw = updateRawDates(taskToMove.raw, newDueDate: targetDate, newTime: targetTime);
    final parsed = parseRawToStructured(newRaw, taskToMove.creationDate);

    final updated = taskToMove.copyWith(
      raw: newRaw,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
    );

    setState(() {
      _tasks[idx] = updated;
      if (_selectedTask?.id == taskId) {
        _selectedTask = updated;
      }
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final ok = await ApiService.updateTask(taskId, {
      'raw': newRaw,
      'dueDate': parsed.dueDate,
      'dueTime': parsed.dueTime,
    });

    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });
  }

  void _handleDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialogWidget(
        title: 'Delete Task',
        message: 'Are you sure you want to delete "${task.title}"?',
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
          setState(() {
            _syncStatus = ok ? 'synced' : 'offline';
          });
        },
      ),
    );
  }

  Future<void> _handleInstantiateTemplate(String templateId) async {
    final tmpl = _templates.firstWhere(
      (t) => t.id == templateId || t.name.toLowerCase().contains(templateId.toLowerCase()),
    );
    final newTask = instantiateTaskFromTemplate(tmpl);

    setState(() {
      _tasks.insert(0, newTask);
      _selectedTask = newTask;
      _syncStatus = 'syncing';
    });

    await _storageService.saveTasks(_tasks);

    final created = await ApiService.createTask(newTask);
    setState(() {
      _syncStatus = created != null ? 'synced' : 'offline';
    });
  }

  Future<void> _handleSaveAsTemplate(Task task) async {
    final newTmpl = Template(
      id: 'tmpl-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Template: ${task.title}',
      rawTemplate: task.raw,
      description: task.description,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      projects: List.from(task.projects),
      contexts: List.from(task.contexts),
      subtasks: task.subtasks.asMap().entries.map((e) => TemplateSubtask(
        id: 'tmpls-${DateTime.now().millisecondsSinceEpoch}-${e.key}',
        title: e.value.raw,
        position: e.key,
      )).toList(),
    );

    setState(() {
      _templates.insert(0, newTmpl);
      _syncStatus = 'syncing';
    });

    await _storageService.saveTemplates(_templates);

    final ok = await ApiService.createTemplate(newTmpl);
    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });

    _openTemplatesModal();
  }

  Future<void> _handleDeleteTemplate(String templateId) async {
    setState(() {
      _templates.removeWhere((t) => t.id == templateId);
      _syncStatus = 'syncing';
    });
    await _storageService.saveTemplates(_templates);

    final ok = await ApiService.deleteTemplate(templateId);
    setState(() {
      _syncStatus = ok ? 'synced' : 'offline';
    });
  }

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
        _commandController.clear();
        _syncStatus = 'syncing';
      });

      await _storageService.saveTasks(_tasks);

      final created = await ApiService.createTask(newTask);
      setState(() {
        _syncStatus = created != null ? 'synced' : 'offline';
      });
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

  void _openSettingsModal([int initialTab = 0]) {
    showDialog(
      context: context,
      builder: (context) => SettingsModalWidget(
        templates: _templates,
        isLight: widget.isLight,
        currentTheme: widget.currentTheme,
        onSelectTheme: widget.onSelectTheme,
        initialTabIndex: initialTab,
        onInstantiateTemplate: _handleInstantiateTemplate,
        onCreateTemplate: (tmpl) async {
          setState(() {
            _templates.insert(0, tmpl);
            _syncStatus = 'syncing';
          });
          await _storageService.saveTemplates(_templates);
          final ok = await ApiService.createTemplate(tmpl);
          setState(() => _syncStatus = ok ? 'synced' : 'offline');
        },
        onUpdateTemplate: (id, updates) async {
          final idx = _templates.indexWhere((t) => t.id == id);
          if (idx != -1) {
            final cur = _templates[idx];
            final updated = Template(
              id: cur.id,
              name: updates['name'] ?? cur.name,
              rawTemplate: updates['rawTemplate'] ?? cur.rawTemplate,
              description: updates['description'] ?? cur.description,
              createdAt: cur.createdAt,
              updatedAt: updates['updatedAt'] ?? DateTime.now().toIso8601String(),
              projects: cur.projects,
              contexts: cur.contexts,
              subtasks: cur.subtasks,
            );
            setState(() {
              _templates[idx] = updated;
              _syncStatus = 'syncing';
            });
            await _storageService.saveTemplates(_templates);
            final ok = await ApiService.updateTemplate(id, updates);
            setState(() => _syncStatus = ok ? 'synced' : 'offline');
          }
        },
        onDeleteTemplate: _handleDeleteTemplate,
        syncStatus: _syncStatus,
        onForceSync: _loadDataFromWebOrCache,
      ),
    );
  }

  void _openTemplatesModal() {
    _openSettingsModal(1);
  }

  List<Task> _getFilteredTasks() {
    if (_activeFilter.isEmpty) return _tasks;

    final query = _activeFilter.toLowerCase();

    return _tasks.where((t) {
      if (_activeFilter.startsWith('+')) return t.projects.contains(_activeFilter);
      if (_activeFilter.startsWith('@')) return t.contexts.contains(_activeFilter);
      if (_activeFilter.startsWith('rec:')) return t.recurrence != null && t.recurrence!.isNotEmpty;

      return t.raw.toLowerCase().contains(query) ||
          t.title.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);
    }).toList();
  }

  void _selectTaskAndOpenInspector(Task task, bool isTablet) {
    setState(() => _selectedTask = task);
    if (!isTablet) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: widget.isLight ? Colors.white : Colors.black,
        body: const Center(child: Text('Connecting to Todo Next Server...')),
      );
    }

    final filteredTasks = _getFilteredTasks();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isTablet
          ? Drawer(
              child: SafeArea(
                child: SidebarWidget(
                  tasks: _tasks,
                  activeFilter: _activeFilter,
                  isLight: widget.isLight,
                  onFilterClick: (filter) {
                    setState(() => _activeFilter = filter);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan[700],
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: Text(
          'NEW TASK',
          style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: _openAddTaskModal,
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
            ),
            Expanded(
              child: Row(
                children: [
                  if (isTablet)
                    SidebarWidget(
                      tasks: _tasks,
                      activeFilter: _activeFilter,
                      isLight: widget.isLight,
                      onFilterClick: (filter) => setState(() => _activeFilter = filter),
                    ),
                  Expanded(
                    child: _activeView == 'list'
                        ? TaskListWidget(
                            tasks: filteredTasks,
                            selectedTaskId: _selectedTask?.id,
                            isLight: widget.isLight,
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
                  if (isTablet)
                    InspectorDrawerWidget(
                      task: _selectedTask,
                      isLight: widget.isLight,
                      onClose: () => setState(() => _selectedTask = null),
                      onUpdateTask: _handleUpdateTask,
                      onSaveAsTemplate: _handleSaveAsTemplate,
                      onSkipRecurrence: _handleSkipRecurrence,
                    ),
                ],
              ),
            ),
            StatusBarWidget(
              filteredCount: filteredTasks.length,
              totalCount: _tasks.length,
              activeFilter: _activeFilter,
              syncStatus: _syncStatus,
              isLight: widget.isLight,
              currentTheme: widget.currentTheme,
              onToggleTheme: widget.onToggleTheme,
              onForceSync: _loadDataFromWebOrCache,
            ),
          ],
        ),
      ),
      endDrawer: (!isTablet && _selectedTask != null)
          ? Drawer(
              width: screenWidth * 0.88,
              child: SafeArea(
                child: InspectorDrawerWidget(
                  task: _selectedTask,
                  isLight: widget.isLight,
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
