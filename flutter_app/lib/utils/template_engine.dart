import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/template.dart';
import 'todo_parser.dart';

String resolveTemplateTokens(String rawTemplate, [Map<String, String>? varOverrides]) {
  final now = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(now);

  String result = rawTemplate;

  // Replace {today}
  result = result.replaceAll('{today}', todayStr);

  // Replace {due:+Nd}
  result = result.replaceAllMapped(RegExp(r'\{due:\+(\d+)d\}'), (match) {
    final days = int.tryParse(match.group(1)!) ?? 0;
    final d = now.add(Duration(days: days));
    return 'due:${DateFormat('yyyy-MM-dd').format(d)}';
  });

  // Replace {due:+Nw}
  result = result.replaceAllMapped(RegExp(r'\{due:\+(\d+)w\}'), (match) {
    final weeks = int.tryParse(match.group(1)!) ?? 0;
    final d = now.add(Duration(days: weeks * 7));
    return 'due:${DateFormat('yyyy-MM-dd').format(d)}';
  });

  // Replace {due:+Nm}
  result = result.replaceAllMapped(RegExp(r'\{due:\+(\d+)m\}'), (match) {
    final months = int.tryParse(match.group(1)!) ?? 0;
    final d = DateTime(now.year, now.month + months, now.day);
    return 'due:${DateFormat('yyyy-MM-dd').format(d)}';
  });

  // Replace {time:HH:MM}
  result = result.replaceAllMapped(RegExp(r'\{time:(\d{1,2}:\d{2})\}'), (match) {
    return 'time:${match.group(1)!.padLeft(5, '0')}';
  });

  // Variable overrides {var:Name}
  if (varOverrides != null) {
    varOverrides.forEach((key, val) {
      result = result.replaceAll('{var:$key}', val);
    });
  }

  return result;
}

Task instantiateTaskFromTemplate(Template template, [Map<String, String>? varOverrides]) {
  final resolvedRaw = resolveTemplateTokens(template.rawTemplate, varOverrides);
  final parsed = parseRawToStructured(resolvedRaw);

  final taskId = 't${DateTime.now().millisecondsSinceEpoch}';

  final subtasks = template.subtasks.map((st) {
    final resolvedSt = resolveTemplateTokens(st.title, varOverrides);
    return Subtask(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}-${st.position}',
      taskId: taskId,
      title: resolvedSt,
      raw: resolvedSt,
      completed: false,
    );
  }).toList();

  final projects = Set<String>.from([...template.projects, ...parsed.projects]).toList();
  final contexts = Set<String>.from([...template.contexts, ...parsed.contexts]).toList();

  return Task(
    id: taskId,
    title: parsed.title,
    raw: resolvedRaw,
    status: parsed.completed ? 'completed' : 'open',
    completed: parsed.completed,
    priority: parsed.priority,
    creationDate: parsed.creationDate,
    dueDate: parsed.dueDate,
    dueTime: parsed.dueTime,
    recurrence: parsed.recurrence,
    description: template.description,
    projects: projects,
    contexts: contexts,
    subtasks: subtasks,
    comments: [],
  );
}
