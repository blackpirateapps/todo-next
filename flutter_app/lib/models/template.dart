class TemplateSubtask {
  final String id;
  final String? templateId;
  final String title;
  final int position;

  TemplateSubtask({
    required this.id,
    this.templateId,
    required this.title,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'position': position,
    };
  }

  factory TemplateSubtask.fromJson(Map<String, dynamic> json) {
    return TemplateSubtask(
      id: json['id'] as String,
      templateId: json['templateId'] as String?,
      title: json['title'] as String? ?? '',
      position: json['position'] as int? ?? 0,
    );
  }
}

class Template {
  final String id;
  final String name;
  final String rawTemplate;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<String> projects;
  final List<String> contexts;
  final List<TemplateSubtask> subtasks;

  Template({
    required this.id,
    required this.name,
    required this.rawTemplate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.projects,
    required this.contexts,
    required this.subtasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rawTemplate': rawTemplate,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'projects': projects,
      'contexts': contexts,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      rawTemplate: json['rawTemplate'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      projects: (json['projects'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      contexts: (json['contexts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      subtasks: (json['subtasks'] as List<dynamic>?)?.map((e) => TemplateSubtask.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
