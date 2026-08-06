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
    return Task(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      raw: json['raw'] as String? ?? '',
      status: json['status'] as String? ?? (json['completed'] == true ? 'completed' : 'open'),
      completed: json['completed'] as bool? ?? false,
      priority: json['priority'] as String?,
      creationDate: json['creationDate'] as String? ?? '',
      completionDate: json['completionDate'] as String?,
      dueDate: json['dueDate'] as String?,
      dueTime: json['dueTime'] as String?,
      description: json['description'] as String? ?? '',
      recurrence: json['recurrence'] as String?,
      parentRecurringId: json['parentRecurringId'] as String?,
      projects: (json['projects'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      contexts: (json['contexts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      subtasks: (json['subtasks'] as List<dynamic>?)?.map((e) => Subtask.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)?.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
