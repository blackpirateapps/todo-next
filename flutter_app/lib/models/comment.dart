class Comment {
  final String? id;
  final String? taskId;
  final String author;
  final String timestamp;
  final String text;

  Comment({
    this.id,
    this.taskId,
    required this.author,
    required this.timestamp,
    required this.text,
  });

  Comment copyWith({
    String? id,
    String? taskId,
    String? author,
    String? timestamp,
    String? text,
  }) {
    return Comment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'author': author,
      'timestamp': timestamp,
      'text': text,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String?,
      taskId: json['taskId'] as String?,
      author: json['author'] as String? ?? 'user',
      timestamp: json['timestamp'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}
