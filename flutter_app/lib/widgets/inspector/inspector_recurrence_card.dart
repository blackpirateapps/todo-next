import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';

class InspectorRecurrenceCard extends StatelessWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final Function(String taskId) onSkipRecurrence;
  final bool isLight;

  const InspectorRecurrenceCard({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onSkipRecurrence,
    required this.isLight,
  });

  void _setRecurrence(String rule) {
    final cleanRule = rule.toLowerCase().startsWith('rec:') ? rule.substring(4) : rule;

    final newRaw = updateRawDates(task.raw);
    final parsed = parseRawToStructured(newRaw);

    final rebuiltRaw = buildRawFromStructured(
      title: parsed.title,
      priority: parsed.priority,
      creationDate: parsed.creationDate,
      completionDate: parsed.completionDate,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      recurrence: cleanRule,
      completed: parsed.completed,
      projects: parsed.projects,
      contexts: parsed.contexts,
    );

    onUpdateTask(task.id, {
      'recurrence': cleanRule,
      'raw': rebuiltRaw,
    });
  }

  void _clearRecurrence() {
    final parsed = parseRawToStructured(task.raw);
    final rebuiltRaw = buildRawFromStructured(
      title: parsed.title,
      priority: parsed.priority,
      creationDate: parsed.creationDate,
      completionDate: parsed.completionDate,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      recurrence: null,
      completed: parsed.completed,
      projects: parsed.projects,
      contexts: parsed.contexts,
    );

    onUpdateTask(task.id, {
      'recurrence': null,
      'raw': rebuiltRaw,
    });
  }

  void _toggleStrictRecurrence() {
    if (task.recurrence == null) return;
    final current = task.recurrence!;

    String nextRule;
    if (current.startsWith('strict:') || current.startsWith('+')) {
      nextRule = current.replaceAll('strict:', '').replaceAll('+', '');
    } else {
      nextRule = 'strict:$current';
    }
    _setRecurrence(nextRule);
  }

  @override
  Widget build(BuildContext context) {
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final recStr = task.recurrence ?? '';
    final isStrict = recStr.contains('strict:') || recStr.contains('+');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLight ? Colors.purple[50] : Colors.purple[950]?.withAlpha(80),
        border: Border.all(color: isLight ? Colors.purple[200]! : Colors.purple[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'RECURRENCE (rec:)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[400],
                ),
              ),
              const Spacer(),
              if (task.recurrence != null)
                InkWell(
                  onTap: _clearRecurrence,
                  child: Text(
                    '[Remove]',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.red[400]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _presetChip('Daily', '1d', border),
              _presetChip('Weekdays', 'weekday', border),
              _presetChip('Weekly', '1w', border),
              _presetChip('Monthly', '1m', border),
            ],
          ),
          const SizedBox(height: 8),
          if (task.recurrence != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: _toggleStrictRecurrence,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: isStrict ? Colors.purple[700] : Colors.grey[800],
                    child: Text(
                      isStrict ? '⚡ Strict Mode' : '🔄 Relative Mode',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onSkipRecurrence(task.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
                    child: Text(
                      '[Skip Cycle]',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _presetChip(String label, String rule, Color border) {
    return InkWell(
      onTap: () => _setRecurrence(rule),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(border: Border.all(color: border)),
        child: Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
      ),
    );
  }
}
