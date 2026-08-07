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
    final isCompleted = json['completed'] == true || json['completed'] == 1;

    return Subtask(
      id: (json['id'] ?? 's-${DateTime.now().millisecondsSinceEpoch}').toString(),
      taskId: json['taskId']?.toString(),
      title: (json['title'] ?? json['raw'] ?? '').toString(),
      raw: (json['raw'] ?? json['title'] ?? '').toString(),
      completed: isCompleted,
    );
  }
}
