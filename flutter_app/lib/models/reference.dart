class Reference {
  final String id;
  final String? userId;
  final String title;
  final String content;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;
  final bool archived;

  const Reference({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      parsedTags = (json['tags'] as List)
          .map((t) => t?.toString() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    }

    bool isArchived = false;
    if (json['archived'] is bool) {
      isArchived = json['archived'] as bool;
    } else if (json['archived'] is int) {
      isArchived = (json['archived'] as int) == 1;
    } else if (json['archived'] is String) {
      isArchived = json['archived'] == '1' || json['archived'] == 'true';
    }

    return Reference(
      id: json['id']?.toString() ?? 'ref-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      tags: parsedTags,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      archived: isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'archived': archived,
    };
  }

  Reference copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
    bool? archived,
  }) {
    return Reference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
    );
  }
}
