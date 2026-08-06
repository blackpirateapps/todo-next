import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/comment.dart';
import '../models/template.dart';
import '../services/storage_service.dart';
import '../utils/todo_parser.dart';
import '../utils/template_engine.dart';
import '../utils/recurrence_engine.dart';
import '../widgets/command_input.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_list.dart';
import '../widgets/calendar_view.dart';
import '../widgets/inspector_drawer.dart';
import '../widgets/template_modal.dart';
import '../widgets/syntax_guide_modal.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/status_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isLight;

  const HomeScreen({
    super.key,
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
  bool _isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _storageService.loadTasks();
    final templates = await _storageService.loadTemplates();
    setState(() {
      _tasks = tasks;
      _templates = templates;
      if (_tasks.isNotEmpty && _selectedTask == null) {
        _selectedTask = _tasks.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  Future<void> _saveTemplates() async {
    await _storageService.saveTemplates(_templates);
  }

  void _handleToggleTask(String id) {
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

    setState(() {
      _tasks[idx] = updatedTask;
      if (nextTaskInstance != null) {
        _tasks.insert(0, nextTaskInstance);
      }
      if (_selectedTask?.id == id) {
        _selectedTask = updatedTask;
      }
    });

    _saveTasks();
  }

  void _handleSkipRecurrence(String id) {
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
    });

    _saveTasks();
  }

  void _handleUpdateTask(String id, Map<String, dynamic> updates) {
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
    });

    _saveTasks();
  }

  void _handleMoveTask(String taskId, String targetDate, String? targetTime) {
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
    });

    _saveTasks();
  }

  void _handleDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialogWidget(
        title: 'Delete Task',
        message: 'Are you sure you want to delete "${task.title}"?',
        isLight: widget.isLight,
        onConfirm: () {
          setState(() {
            _tasks.removeWhere((t) => t.id == task.id);
            if (_selectedTask?.id == task.id) {
              _selectedTask = _tasks.isNotEmpty ? _tasks.first : null;
            }
          });
          _saveTasks();
        },
      ),
    );
  }

  void _handleInstantiateTemplate(String templateId) {
    final tmpl = _templates.firstWhere((t) => t.id == templateId || t.name.toLowerCase().contains(templateId.toLowerCase()));
    final newTask = instantiateTaskFromTemplate(tmpl);

    setState(() {
      _tasks.insert(0, newTask);
      _selectedTask = newTask;
    });

    _saveTasks();
  }

  void _handleSaveAsTemplate(Task task) {
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
    });

    _saveTemplates();
    _openTemplatesModal();
  }

  void _handleDeleteTemplate(String templateId) {
    setState(() {
      _templates.removeWhere((t) => t.id == templateId);
    });
    _saveTemplates();
  }

  void _handleCommandSubmit(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) return;

    // Filter command
    if (trimmed == ':recurring') {
      setState(() => _activeFilter = 'rec:');
      _commandController.clear();
      return;
    }

    // Skip command
    if (trimmed == ':skip') {
      if (_selectedTask != null) {
        _handleSkipRecurrence(_selectedTask!.id);
        _commandController.clear();
      }
      return;
    }

    // Recurrence command
    if (trimmed.startsWith(':rec ')) {
      final recVal = trimmed.substring(5).trim();
      if (_selectedTask != null) {
        if (recVal == 'off' || recVal == 'none' || recVal == 'clear') {
          final newRaw = buildRawFromStructured(
            title: _selectedTask!.title,
            priority: _selectedTask!.priority,
            creationDate: _selectedTask!.creationDate,
            completionDate: _selectedTask!.completionDate,
            dueDate: _selectedTask!.dueDate,
            dueTime: _selectedTask!.dueTime,
            recurrence: null,
            completed: _selectedTask!.completed,
            projects: _selectedTask!.projects,
            contexts: _selectedTask!.contexts,
          );
          _handleUpdateTask(_selectedTask!.id, {'recurrence': null, 'raw': newRaw});
        } else {
          final cleanRec = recVal.startsWith('rec:') ? recVal.substring(4) : recVal;
          final newRaw = buildRawFromStructured(
            title: _selectedTask!.title,
            priority: _selectedTask!.priority,
            creationDate: _selectedTask!.creationDate,
            completionDate: _selectedTask!.completionDate,
            dueDate: _selectedTask!.dueDate,
            dueTime: _selectedTask!.dueTime,
            recurrence: cleanRec,
            completed: _selectedTask!.completed,
            projects: _selectedTask!.projects,
            contexts: _selectedTask!.contexts,
          );
          _handleUpdateTask(_selectedTask!.id, {'recurrence': cleanRec, 'raw': newRaw});
        }
        _commandController.clear();
      }
      return;
    }

    // Template command
    if (trimmed == ':template') {
      _openTemplatesModal();
      _commandController.clear();
      return;
    }

    if (trimmed.startsWith(':use ')) {
      final tmplName = trimmed.substring(5).trim();
      _handleInstantiateTemplate(tmplName);
      _commandController.clear();
      return;
    }

    if (trimmed.startsWith(':template save ')) {
      if (_selectedTask != null) {
        _handleSaveAsTemplate(_selectedTask!);
      }
      _commandController.clear();
      return;
    }

    // :add ... or search filter
    if (trimmed.startsWith(':add ')) {
      final newTaskRaw = trimmed.substring(5);
      final parsed = parseRawToStructured(newTaskRaw);

      final newTask = Task(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        title: parsed.title,
        raw: newTaskRaw,
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
      });

      _saveTasks();
    } else {
      // Treat as live search filter
      setState(() {
        _activeFilter = trimmed;
      });
    }
  }

  void _openTemplatesModal() {
    showDialog(
      context: context,
      builder: (context) => TemplateModalWidget(
        templates: _templates,
        isLight: widget.isLight,
        onInstantiateTemplate: _handleInstantiateTemplate,
        onCreateTemplate: (tmpl) {
          setState(() => _templates.insert(0, tmpl));
          _saveTemplates();
        },
        onDeleteTemplate: _handleDeleteTemplate,
      ),
    );
  }

  void _openSyntaxModal() {
    showDialog(
      context: context,
      builder: (context) => SyntaxGuideModalWidget(isLight: widget.isLight),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: widget.isLight ? Colors.white : Colors.black,
        body: const Center(child: Text('Loading Todo Next System...')),
      );
    }

    final filteredTasks = _getFilteredTasks();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600; // Tablet threshold

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isTablet
          ? Drawer(
              child: SidebarWidget(
                tasks: _tasks,
                activeFilter: _activeFilter,
                isLight: widget.isLight,
                onFilterClick: (filter) {
                  setState(() => _activeFilter = filter);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Top Command Bar
            CommandInputWidget(
              controller: _commandController,
              onSubmit: _handleCommandSubmit,
              onToggleSidebar: () {
                if (!isTablet) {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              onOpenTemplates: _openTemplatesModal,
              onOpenSyntax: _openSyntaxModal,
              onChangeView: (view) => setState(() => _activeView = view),
              activeView: _activeView,
              isLight: widget.isLight,
            ),

            // Main Body Area
            Expanded(
              child: Row(
                children: [
                  // Column 1: Left Sidebar (Tablet Only)
                  if (isTablet)
                    SidebarWidget(
                      tasks: _tasks,
                      activeFilter: _activeFilter,
                      isLight: widget.isLight,
                      onFilterClick: (filter) => setState(() => _activeFilter = filter),
                    ),

                  // Column 2: Center Workspace (List or Calendar)
                  Expanded(
                    child: _activeView == 'list'
                        ? TaskListWidget(
                            tasks: filteredTasks,
                            selectedTaskId: _selectedTask?.id,
                            isLight: widget.isLight,
                            onSelectTask: (t) => setState(() => _selectedTask = t),
                            onToggleTask: _handleToggleTask,
                            onDeleteTask: _handleDeleteTask,
                          )
                        : CalendarViewWidget(
                            tasks: filteredTasks,
                            selectedTaskId: _selectedTask?.id,
                            isLight: widget.isLight,
                            onSelectTask: (t) => setState(() => _selectedTask = t),
                            onToggleTask: _handleToggleTask,
                            onMoveTask: _handleMoveTask,
                            onCreateTaskAtDate: (dateISO, timeStr) {
                              final timeTag = timeStr != null ? ' time:$timeStr' : '';
                              _commandController.text = ':add (A) New task due:$dateISO$timeTag ';
                            },
                          ),
                  ),

                  // Column 3: Right Inspector Drawer (Tablet Only or Mobile Selected Overlay)
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

            // Bottom Status Bar
            StatusBarWidget(
              filteredCount: filteredTasks.length,
              totalCount: _tasks.length,
              activeFilter: _activeFilter,
              isLight: widget.isLight,
              onToggleTheme: widget.onToggleTheme,
            ),
          ],
        ),
      ),

      // Mobile Inspector Drawer (Bottom Sheet)
      endDrawer: (!isTablet && _selectedTask != null)
          ? Drawer(
              width: screenWidth * 0.85,
              child: InspectorDrawerWidget(
                task: _selectedTask,
                isLight: widget.isLight,
                onClose: () => Navigator.of(context).pop(),
                onUpdateTask: _handleUpdateTask,
                onSaveAsTemplate: _handleSaveAsTemplate,
                onSkipRecurrence: _handleSkipRecurrence,
              ),
            )
          : null,
    );
  }
}
