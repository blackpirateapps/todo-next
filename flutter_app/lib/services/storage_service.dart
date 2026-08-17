import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/comment.dart';
import '../models/template.dart';
import '../models/reference.dart';
import '../utils/todo_parser.dart';

class StorageService {
  static const String _tasksKey = 'todo_next_cached_tasks';
  static const String _templatesKey = 'todo_next_cached_templates';
  static const String _referencesKey = 'todo_next_cached_references';

  static final List<Map<String, dynamic>> _initialTasksData = [
    {
      'id': 't1',
      'raw': '(A) 2026-08-06 Implement core parsing logic for +backend @dev due:2026-08-12',
      'description': 'Need to write a robust regex parser that handles priorities (A-Z), dates, +projects, and @contexts natively without breaking on malformed strings. Reference the original todo.txt spec.',
      'subtasks': [
        {'id': 't1-1', 'title': 'Write unit tests for edge cases', 'raw': 'Write unit tests for edge cases', 'completed': true},
        {'id': 't1-2', 'title': 'Integrate with main loop', 'raw': 'Integrate with main loop', 'completed': false}
      ],
      'comments': [
        {'id': 'c1', 'author': 'sys', 'timestamp': '2026-08-05 10:00', 'text': 'Started initial scaffolding.'}
      ]
    },
    {
      'id': 't2',
      'raw': '(B) 2026-08-05 Provision new database cluster +infra @ops due:2026-08-15',
      'description': 'Scale up the PostgreSQL cluster to handle the new analytics load. Ensure pgBouncer is configured correctly.',
      'subtasks': [],
      'comments': []
    },
    {
      'id': 't3',
      'raw': 'x 2026-08-05 2026-08-01 Renew SSL certificates +infra @admin',
      'description': 'Use certbot for automated renewal. Check cron jobs.',
      'subtasks': [],
      'comments': []
    },
    {
      'id': 't4',
      'raw': 'Update vimrc with new LSP configurations @personal',
      'description': 'Switching from coc.nvim to native Neovim LSP. Need to map standard keys (gd, K, etc).',
      'subtasks': [],
      'comments': []
    },
    {
      'id': 't5',
      'raw': '(C) Draft Q3 architecture review +docs @management due:2026-08-20',
      'description': 'Focus on the migration from legacy monolith to the new microservices architecture. Highlight cost savings.',
      'subtasks': [],
      'comments': [
        {'id': 'c2', 'author': 'lead', 'timestamp': '2026-08-03 14:30', 'text': 'Make sure to include the AWS bill projections.'}
      ]
    },
    {
      'id': 't6',
      'raw': 'Buy coffee beans @errands',
      'description': 'Get the dark roast from the local roaster.',
      'subtasks': [],
      'comments': []
    }
  ];

  static final List<Map<String, dynamic>> _starterTemplatesData = [
    {
      'id': 'tmpl-1',
      'name': 'Sprint Release Checklist',
      'rawTemplate': '(A) Deploy release v1.0 +infra @ops due:{due:+2d} {time:10:00}',
      'description': 'Checklist for deploying a production release candidate.',
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'projects': ['+infra'],
      'contexts': ['@ops'],
      'subtasks': [
        {'id': 'tmpls-1', 'title': 'Run unit tests & E2E suite', 'position': 0},
        {'id': 'tmpls-2', 'title': 'Tag git release candidate', 'position': 1},
        {'id': 'tmpls-3', 'title': 'Apply database migrations', 'position': 2},
        {'id': 'tmpls-4', 'title': 'Monitor metrics on dashboard', 'position': 3}
      ]
    },
    {
      'id': 'tmpl-2',
      'name': 'Weekly Code Review',
      'rawTemplate': '(B) Conduct weekly team code review +dev @review due:{due:+5d}',
      'description': 'Weekly team peer review workflow.',
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'projects': ['+dev'],
      'contexts': ['@review'],
      'subtasks': [
        {'id': 'tmpls-5', 'title': 'Check open pull requests', 'position': 0},
        {'id': 'tmpls-6', 'title': 'Audit dependencies for security updates', 'position': 1},
        {'id': 'tmpls-7', 'title': 'Post feedback comments', 'position': 2}
      ]
    },
    {
      'id': 'tmpl-3',
      'name': 'Inbox Zero & Daily Prep',
      'rawTemplate': '(C) Morning prep and inbox zero @personal',
      'description': 'Daily morning organization routine.',
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'projects': [],
      'contexts': ['@personal'],
      'subtasks': [
        {'id': 'tmpls-8', 'title': 'Review priority A tasks', 'position': 0},
        {'id': 'tmpls-9', 'title': 'Clear unread emails & messages', 'position': 1},
        {'id': 'tmpls-10', 'title': 'Set daily goal focus', 'position': 2}
      ]
    }
  ];

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasksKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      // Initialize with seed tasks
      final tasks = _initialTasksData.map((data) {
        final parsed = parseRawToStructured(data['raw'] as String);
        final subtasksList = (data['subtasks'] as List)
            .map((s) => Subtask.fromJson(Map<String, dynamic>.from(s)))
            .toList();
        final commentsList = (data['comments'] as List)
            .map((c) => Comment.fromJson(Map<String, dynamic>.from(c)))
            .toList();

        return Task(
          id: data['id'] as String,
          title: parsed.title,
          raw: data['raw'] as String,
          status: parsed.completed ? 'completed' : 'open',
          completed: parsed.completed,
          priority: parsed.priority,
          creationDate: parsed.creationDate,
          completionDate: parsed.completionDate,
          dueDate: parsed.dueDate,
          dueTime: parsed.dueTime,
          recurrence: parsed.recurrence,
          description: data['description'] as String? ?? '',
          projects: parsed.projects,
          contexts: parsed.contexts,
          subtasks: subtasksList,
          comments: commentsList,
        );
      }).toList();

      await saveTasks(tasks);
      return tasks;
    }

    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Task.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonStr);
  }

  Future<List<Template>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_templatesKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      final templates = _starterTemplatesData
          .map((data) => Template.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      await saveTemplates(templates);
      return templates;
    }

    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Template.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  static final List<Map<String, dynamic>> _starterReferencesData = [
    {
      'id': 'ref-1',
      'title': 'John (Backend Lead)',
      'content': '+91 98765 43210\njohn.doe@example.com',
      'tags': ['@people', '+work'],
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'archived': false,
    },
    {
      'id': 'ref-2',
      'title': 'Home Wi-Fi Network',
      'content': 'SSID: Home_5G_Fiber\nPassword: CoffeeVimCode2026!',
      'tags': ['@home', '+infra'],
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'archived': false,
    },
    {
      'id': 'ref-3',
      'title': 'Dr. Sharma Clinic',
      'content': '14 Carter Road, Bandra West, Mumbai 400050\nTel: +91 22 2640 1234',
      'tags': ['@places', '@health'],
      'createdAt': '2026-08-06T10:00:00Z',
      'updatedAt': '2026-08-06T10:00:00Z',
      'archived': false,
    }
  ];

  Future<void> saveTemplates(List<Template> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(templates.map((t) => t.toJson()).toList());
    await prefs.setString(_templatesKey, jsonStr);
  }

  Future<List<Reference>> loadReferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_referencesKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      final refs = _starterReferencesData
          .map((data) => Reference.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      await saveReferences(refs);
      return refs;
    }

    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((item) => Reference.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveReferences(List<Reference> references) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(references.map((r) => r.toJson()).toList());
    await prefs.setString(_referencesKey, jsonStr);
  }

  static const String _showIconsKey = 'todo_next_show_icons';

  Future<bool> loadShowIcons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showIconsKey) ?? false;
  }

  Future<void> saveShowIcons(bool showIcons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showIconsKey, showIcons);
  }
}

