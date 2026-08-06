import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/recurrence_rule.dart';
import 'todo_parser.dart';

RecurrenceRule? parseRecurrenceRule(String? rawTag) {
  if (rawTag == null || rawTag.trim().isEmpty) return null;

  String clean = rawTag.trim();
  if (clean.toLowerCase().startsWith('rec:')) {
    clean = clean.substring(4);
  }

  RecurrenceMode mode = RecurrenceMode.completion;
  if (clean.toLowerCase().startsWith('strict:')) {
    mode = RecurrenceMode.strict;
    clean = clean.substring(7);
  } else if (clean.startsWith('+')) {
    mode = RecurrenceMode.strict;
    clean = clean.substring(1);
  }

  final lower = clean.toLowerCase();

  if (lower == 'weekday') {
    return RecurrenceRule(raw: rawTag, interval: 1, unit: RecurrenceUnit.weekday, mode: mode);
  }

  if (lower == 'mwf') {
    return RecurrenceRule(raw: rawTag, interval: 1, unit: RecurrenceUnit.mwf, mode: mode);
  }

  final match = RegExp(r'^(\d+)([dwmy])$').firstMatch(lower);
  if (match == null) return null;

  final interval = int.tryParse(match.group(1)!) ?? 1;
  final unitChar = match.group(2)!;

  RecurrenceUnit unit = RecurrenceUnit.d;
  if (unitChar == 'w') unit = RecurrenceUnit.w;
  if (unitChar == 'm') unit = RecurrenceUnit.m;
  if (unitChar == 'y') unit = RecurrenceUnit.y;

  return RecurrenceRule(raw: rawTag, interval: interval, unit: unit, mode: mode);
}

String calculateNextDueDate(
  String? currentDueDate,
  String completionDate,
  RecurrenceRule rule,
) {
  final refDateStr = (rule.mode == RecurrenceMode.strict && currentDueDate != null && currentDueDate.isNotEmpty)
      ? currentDueDate
      : completionDate;

  final parts = refDateStr.split('-').map((e) => int.tryParse(e) ?? 1).toList();
  DateTime baseDate = DateTime(parts[0], parts[1], parts.length > 2 ? parts[2] : 1);
  DateTime nextDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

  switch (rule.unit) {
    case RecurrenceUnit.d:
      nextDate = nextDate.add(Duration(days: rule.interval));
      break;

    case RecurrenceUnit.w:
      nextDate = nextDate.add(Duration(days: rule.interval * 7));
      break;

    case RecurrenceUnit.m:
      final origDay = nextDate.day;
      nextDate = DateTime(nextDate.year, nextDate.month + rule.interval, origDay);
      if (nextDate.day != origDay) {
        // Month overflow handling
        nextDate = DateTime(nextDate.year, nextDate.month, 0);
      }
      break;

    case RecurrenceUnit.y:
      nextDate = DateTime(nextDate.year + rule.interval, nextDate.month, nextDate.day);
      break;

    case RecurrenceUnit.weekday:
      do {
        nextDate = nextDate.add(const Duration(days: 1));
      } while (nextDate.weekday == DateTime.saturday || nextDate.weekday == DateTime.sunday);
      break;

    case RecurrenceUnit.mwf:
      do {
        nextDate = nextDate.add(const Duration(days: 1));
      } while (![DateTime.monday, DateTime.wednesday, DateTime.friday].contains(nextDate.weekday));
      break;
  }

  // Ensure strict mode doesn't produce past dates relative to completionDate
  if (rule.mode == RecurrenceMode.strict && completionDate.isNotEmpty) {
    final compParts = completionDate.split('-').map((e) => int.tryParse(e) ?? 1).toList();
    final compDateObj = DateTime(compParts[0], compParts[1], compParts.length > 2 ? compParts[2] : 1);
    while (nextDate.isBefore(compDateObj) || nextDate.isAtSameMomentAs(compDateObj)) {
      switch (rule.unit) {
        case RecurrenceUnit.d:
          nextDate = nextDate.add(Duration(days: rule.interval));
          break;
        case RecurrenceUnit.w:
          nextDate = nextDate.add(Duration(days: rule.interval * 7));
          break;
        case RecurrenceUnit.m:
          nextDate = DateTime(nextDate.year, nextDate.month + rule.interval, nextDate.day);
          break;
        case RecurrenceUnit.y:
          nextDate = DateTime(nextDate.year + rule.interval, nextDate.month, nextDate.day);
          break;
        default:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
      }
    }
  }

  return DateFormat('yyyy-MM-dd').format(nextDate);
}

Task? spawnNextRecurrenceInstance(Task completedTask, String completionDate) {
  final recStr = completedTask.recurrence ?? parseRawToStructured(completedTask.raw).recurrence;
  if (recStr == null || recStr.isEmpty) return null;

  final rule = parseRecurrenceRule(recStr);
  if (rule == null) return null;

  final nextDueDate = calculateNextDueDate(completedTask.dueDate, completionDate, rule);

  final resetSubtasks = completedTask.subtasks.map((st) {
    return Subtask(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}-${st.id}',
      taskId: null,
      title: st.title,
      raw: st.raw,
      completed: false,
    );
  }).toList();

  final newRaw = buildRawFromStructured(
    title: completedTask.title,
    priority: completedTask.priority,
    creationDate: completionDate,
    dueDate: nextDueDate,
    dueTime: completedTask.dueTime,
    recurrence: recStr,
    completed: false,
    projects: completedTask.projects,
    contexts: completedTask.contexts,
  );

  return Task(
    id: 't${DateTime.now().millisecondsSinceEpoch}',
    title: completedTask.title,
    raw: newRaw,
    status: 'open',
    completed: false,
    priority: completedTask.priority,
    creationDate: completionDate,
    dueDate: nextDueDate,
    dueTime: completedTask.dueTime,
    description: completedTask.description,
    recurrence: recStr,
    parentRecurringId: completedTask.id,
    projects: List.from(completedTask.projects),
    contexts: List.from(completedTask.contexts),
    subtasks: resetSubtasks,
    comments: [],
  );
}

Task skipRecurrenceOccurrence(Task task) {
  final recStr = task.recurrence ?? parseRawToStructured(task.raw).recurrence;
  if (recStr == null || recStr.isEmpty) return task;

  final rule = parseRecurrenceRule(recStr);
  if (rule == null) return task;

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final nextDueDate = calculateNextDueDate(task.dueDate ?? today, today, rule);

  final newRaw = buildRawFromStructured(
    title: task.title,
    priority: task.priority,
    creationDate: task.creationDate,
    dueDate: nextDueDate,
    dueTime: task.dueTime,
    recurrence: recStr,
    completed: false,
    projects: task.projects,
    contexts: task.contexts,
  );

  return task.copyWith(
    raw: newRaw,
    dueDate: nextDueDate,
  );
}

List<String> getUpcomingRecurrenceDates(Task task, [int maxCount = 5]) {
  if (task.recurrence == null || task.recurrence!.isEmpty || task.completed) return [];
  final rule = parseRecurrenceRule(task.recurrence);
  if (rule == null) return [];

  final List<String> results = [];
  String currentDue = task.dueDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  for (int i = 0; i < maxCount; i++) {
    final nextDue = calculateNextDueDate(currentDue, currentDue, rule);
    results.add(nextDue);
    currentDue = nextDue;
  }

  return results;
}
