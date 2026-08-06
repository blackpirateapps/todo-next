import 'package:intl/intl.dart';

class ParsedTaskMeta {
  final String title;
  final String? priority;
  final String creationDate;
  final String? completionDate;
  final String? dueDate;
  final String? dueTime;
  final String? recurrence;
  final bool completed;
  final List<String> projects;
  final List<String> contexts;

  ParsedTaskMeta({
    required this.title,
    this.priority,
    required this.creationDate,
    this.completionDate,
    this.dueDate,
    this.dueTime,
    this.recurrence,
    required this.completed,
    required this.projects,
    required this.contexts,
  });
}

ParsedTaskMeta parseRawToStructured(String raw, [String? fallbackCreation]) {
  final words = raw.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) {
    final today = fallbackCreation ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    return ParsedTaskMeta(
      title: '',
      creationDate: today,
      completed: false,
      projects: [],
      contexts: [],
    );
  }

  bool completed = false;
  String? priority;
  String creationDate = fallbackCreation ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? completionDate;
  String? dueDate;
  String? dueTime;
  String? recurrence;
  final List<String> projects = [];
  final List<String> contexts = [];
  final List<String> titleWords = [];

  int idx = 0;
  final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  // Check completed prefix: x YYYY-MM-DD YYYY-MM-DD ... or x ...
  if (words[0] == 'x') {
    completed = true;
    idx++;
    if (idx < words.length && dateRegex.hasMatch(words[idx])) {
      completionDate = words[idx];
      idx++;
      if (idx < words.length && dateRegex.hasMatch(words[idx])) {
        creationDate = words[idx];
        idx++;
      }
    }
  }

  // Check priority: (A)
  if (idx < words.length && RegExp(r'^\([A-Z]\)$').hasMatch(words[idx])) {
    priority = words[idx][1];
    idx++;
  }

  // Check creation date if not completed: YYYY-MM-DD
  if (!completed && idx < words.length && dateRegex.hasMatch(words[idx])) {
    creationDate = words[idx];
    idx++;
  }

  // Process remaining tokens
  for (; idx < words.length; idx++) {
    final word = words[idx];

    if (word.startsWith('+') && word.length > 1) {
      if (!projects.contains(word)) projects.add(word);
    } else if (word.startsWith('@') && word.length > 1) {
      if (!contexts.contains(word)) contexts.add(word);
    } else if (RegExp(r'\bdue:(\d{4}-\d{2}-\d{2})(?:T(\d{1,2}:\d{2}))?\b', caseSensitive: false).hasMatch(word)) {
      final match = RegExp(r'\bdue:(\d{4}-\d{2}-\d{2})(?:T(\d{1,2}:\d{2}))?\b', caseSensitive: false).firstMatch(word);
      if (match != null) {
        dueDate = match.group(1);
        if (match.group(2) != null) dueTime = match.group(2)!.padLeft(5, '0');
      }
    } else if (RegExp(r'\btime:(\d{1,2}:\d{2})\b', caseSensitive: false).hasMatch(word)) {
      final match = RegExp(r'\btime:(\d{1,2}:\d{2})\b', caseSensitive: false).firstMatch(word);
      if (match != null) dueTime = match.group(1)!.padLeft(5, '0');
    } else if (RegExp(r'\brec:(?:strict:|\+)?(?:\d+[dwmy]|weekday|mwf)\b', caseSensitive: false).hasMatch(word)) {
      final match = RegExp(r'\brec:((?:strict:|\+)?(?:\d+[dwmy]|weekday|mwf))\b', caseSensitive: false).firstMatch(word);
      if (match != null) recurrence = match.group(1);
    } else {
      titleWords.add(word);
    }
  }

  final title = titleWords.isNotEmpty ? titleWords.join(' ') : raw;

  return ParsedTaskMeta(
    title: title,
    priority: priority,
    creationDate: creationDate,
    completionDate: completionDate,
    dueDate: dueDate,
    dueTime: dueTime,
    recurrence: recurrence,
    completed: completed,
    projects: projects,
    contexts: contexts,
  );
}

String buildRawFromStructured({
  required String title,
  String? priority,
  required String creationDate,
  String? completionDate,
  String? dueDate,
  String? dueTime,
  String? recurrence,
  required bool completed,
  List<String>? projects,
  List<String>? contexts,
}) {
  final List<String> parts = [];

  if (completed) {
    parts.add('x');
    if (completionDate != null && completionDate.isNotEmpty) parts.add(completionDate);
    parts.add(creationDate);
  }

  if (priority != null && priority.isNotEmpty) {
    parts.add('($priority)');
  }

  if (!completed && creationDate.isNotEmpty) {
    parts.add(creationDate);
  }

  if (title.isNotEmpty) {
    parts.add(title);
  }

  if (projects != null) {
    for (final p in projects) {
      if (!parts.contains(p)) parts.add(p);
    }
  }

  if (contexts != null) {
    for (final c in contexts) {
      if (!parts.contains(c)) parts.add(c);
    }
  }

  if (dueDate != null && dueDate.isNotEmpty) {
    parts.add('due:$dueDate');
  }

  if (dueTime != null && dueTime.isNotEmpty) {
    parts.add('time:$dueTime');
  }

  if (recurrence != null && recurrence.isNotEmpty) {
    final recStr = recurrence.startsWith('rec:') ? recurrence : 'rec:$recurrence';
    parts.add(recStr);
  }

  return parts.join(' ');
}

String updateRawDates(
  String raw, {
  String? newCreationDate,
  String? newDueDate,
  bool clearDueDate = false,
  String? newTime,
  bool clearTime = false,
}) {
  final parsed = parseRawToStructured(raw, newCreationDate);
  return buildRawFromStructured(
    title: parsed.title,
    priority: parsed.priority,
    completed: parsed.completed,
    completionDate: parsed.completionDate,
    creationDate: newCreationDate ?? parsed.creationDate,
    dueDate: clearDueDate ? null : (newDueDate ?? parsed.dueDate),
    dueTime: clearTime ? null : (newTime ?? parsed.dueTime),
    recurrence: parsed.recurrence,
    projects: parsed.projects,
    contexts: parsed.contexts,
  );
}
