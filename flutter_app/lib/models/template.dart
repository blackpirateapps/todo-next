import 'dart:convert';

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
    int parsedPos = 0;
    if (json['position'] is int) {
      parsedPos = json['position'] as int;
    } else if (json['position'] != null) {
      parsedPos = int.tryParse(json['position'].toString()) ?? 0;
    }

    return TemplateSubtask(
      id: (json['id'] ?? 'tmpls-${DateTime.now().millisecondsSinceEpoch}').toString(),
      templateId: json['templateId']?.toString(),
      title: (json['title'] ?? '').toString(),
      position: parsedPos,
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

    return Template(
      id: (json['id'] ?? 'tmpl-${DateTime.now().millisecondsSinceEpoch}').toString(),
      name: (json['name'] ?? '').toString(),
      rawTemplate: (json['rawTemplate'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      projects: parseStringList(json['projects']),
      contexts: parseStringList(json['contexts']),
      subtasks: subtasksRaw.whereType<Map>().map((e) => TemplateSubtask.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  Template copyWith({
    String? id,
    String? name,
    String? rawTemplate,
    String? description,
    String? createdAt,
    String? updatedAt,
    List<String>? projects,
    List<String>? contexts,
    List<TemplateSubtask>? subtasks,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      rawTemplate: rawTemplate ?? this.rawTemplate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

