import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../formatted_text.dart';
import '../subtask_progress_bar.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final Function(Task) onSelectTask;
  final Function(String) onToggleTask;
  final Function(Task) onDeleteTask;
  final bool isLight;
  final bool showIcons;

  const TaskListItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.isLight,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final rowBg = isSelected
        ? (isLight ? Colors.grey[300] : Colors.grey[800])
        : Colors.transparent;

    final hasRec = task.recurrence != null && task.recurrence!.isNotEmpty;
    final isStrict = hasRec && (task.recurrence!.contains('strict:') || task.recurrence!.contains('+'));

    final priIcon = task.priority == 'A'
        ? '🔴 A'
        : task.priority == 'B'
        ? '🟡 B'
        : task.priority == 'C'
        ? '🔵 C'
        : task.priority != null && task.priority!.isNotEmpty
        ? '🚩 ${task.priority}'
        : '-';

    return InkWell(
      onTap: () => onSelectTask(task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: rowBg,
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: InkWell(
                onTap: () => onToggleTask(task.id),
                child: Text(
                  showIcons
                      ? (task.completed ? '✅' : '⬜')
                      : (task.completed ? '[x]' : '[ ]'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: showIcons ? 42 : 32,
              child: Text(
                showIcons ? priIcon : (task.priority ?? '-'),
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: showIcons ? 10 : 12,
                  fontWeight: showIcons ? FontWeight.bold : FontWeight.normal,
                  color: Colors.grey[500],
                ),
              ),
            ),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  FormattedText(text: task.raw, isCompleted: task.completed, isLight: isLight),
                  if (hasRec)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isStrict
                            ? (isLight ? Colors.purple[100] : Colors.purple[950])
                            : (isLight ? Colors.cyan[100] : Colors.cyan[950]),
                        border: Border.all(
                          color: isStrict
                              ? (isLight ? Colors.purple[300]! : Colors.purple[800]!)
                              : (isLight ? Colors.cyan[300]! : Colors.cyan[800]!),
                        ),
                      ),
                      child: Text(
                        '${isStrict ? '⚡' : '🔄'} ${task.recurrence!.startsWith('rec:') ? task.recurrence : 'rec:${task.recurrence}'}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isStrict
                              ? (isLight ? Colors.purple[900] : Colors.purple[300])
                              : (isLight ? Colors.cyan[900] : Colors.cyan[300]),
                        ),
                      ),
                    ),
                  if (task.subtasks.isNotEmpty)
                    SubtaskProgressBar(
                      subtasks: task.subtasks,
                      isLight: isLight,
                      compact: true,
                      showText: true,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 44,
              child: InkWell(
                onTap: () => onDeleteTask(task),
                child: Text(
                  showIcons ? '🗑️' : '[del]',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
