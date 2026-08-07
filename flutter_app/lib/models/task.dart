import 'dart:convert';
import 'subtask.dart';
import 'comment.dart';

class Task {
  final String id;
  final String title;
  final String raw;
  final String status; // 'open' | 'completed'
  final bool completed;
  final String? priority;
  final String creationDate;
  final String? completionDate;
  final String? dueDate;
  final String? dueTime;
  final String description;
  final String? recurrence;
  final String? parentRecurringId;
  final List<String> projects;
  final List<String> contexts;
  final List<Subtask> subtasks;
  final List<Comment> comments;

  Task({
    required this.id,
    required this.title,
    required this.raw,
    required this.status,
    required this.completed,
    this.priority,
    required this.creationDate,
    this.completionDate,
    this.dueDate,
    this.dueTime,
    required this.description,
    this.recurrence,
    this.parentRecurringId,
    required this.projects,
    required this.contexts,
    required this.subtasks,
    required this.comments,
  });

  Task copyWith({
    String? id,
    String? title,
    String? raw,
    String? status,
    bool? completed,
    String? priority,
    String? creationDate,
    String? completionDate,
    String? dueDate,
    String? dueTime,
    String? description,
    String? recurrence,
    String? parentRecurringId,
    List<String>? projects,
    List<String>? contexts,
    List<Subtask>? subtasks,
    List<Comment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      raw: raw ?? this.raw,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      creationDate: creationDate ?? this.creationDate,
      completionDate: completionDate ?? this.completionDate,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      description: description ?? this.description,
      recurrence: recurrence ?? this.recurrence,
      parentRecurringId: parentRecurringId ?? this.parentRecurringId,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'raw': raw,
      'status': status,
      'completed': completed,
      'priority': priority,
      'creationDate': creationDate,
      'completionDate': completionDate,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'description': description,
      'recurrence': recurrence,
      'parentRecurringId': parentRecurringId,
      'projects': projects,
      'contexts': contexts,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    List<dynamic> subtasksRaw = [];
    if (json['subtasks'] != null) {
      if (json['subtasks'] is List) {
        subtasksRaw = json['subtasks'] as List;
      } else if (json['subtasks'] is String) {
        try {
          final decoded = jsonDecode(json['subtasks'] as String);
          if (decoded is List) subtasksRaw = decoded;
        } catch (_) {}
      }
    }

    List<dynamic> commentsRaw = [];
    if (json['comments'] != null) {
      if (json['comments'] is List) {
        commentsRaw = json['comments'] as List;
      } else if (json['comments'] is String) {
        try {
          final decoded = jsonDecode(json['comments'] as String);
          if (decoded is List) commentsRaw = decoded;
        } catch (_) {}
      }
    }

    List<String> parseStringList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    final isCompleted = json['completed'] == true || json['completed'] == 1 || json['status'] == 'completed';

    return Task(
      id: (json['id'] ?? 't-${DateTime.now().millisecondsSinceEpoch}').toString(),
      title: (json['title'] ?? '').toString(),
      raw: (json['raw'] ?? '').toString(),
      status: (json['status'] ?? (isCompleted ? 'completed' : 'open')).toString(),
      completed: isCompleted,
      priority: json['priority']?.toString(),
      creationDate: (json['creationDate'] ?? '').toString(),
      completionDate: json['completionDate']?.toString(),
      dueDate: json['dueDate']?.toString(),
      dueTime: json['dueTime']?.toString(),
      description: (json['description'] ?? '').toString(),
      recurrence: json['recurrence']?.toString(),
      parentRecurringId: json['parentRecurringId']?.toString(),
      projects: parseStringList(json['projects']),
      contexts: parseStringList(json['contexts']),
      subtasks: subtasksRaw.whereType<Map>().map((e) => Subtask.fromJson(Map<String, dynamic>.from(e))).toList(),
      comments: commentsRaw.whereType<Map>().map((e) => Comment.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
