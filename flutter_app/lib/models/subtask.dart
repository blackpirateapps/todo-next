class Subtask {
  final String id;
  final String? taskId;
  final String title;
  final String raw;
  final bool completed;

  Subtask({
    required this.id,
    this.taskId,
    required this.title,
    required this.raw,
    required this.completed,
  });

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    String? raw,
    bool? completed,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      raw: raw ?? this.raw,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'raw': raw,
      'completed': completed,
    };
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      title: json['title'] as String? ?? json['raw'] as String? ?? '',
      raw: json['raw'] as String? ?? json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }
}
