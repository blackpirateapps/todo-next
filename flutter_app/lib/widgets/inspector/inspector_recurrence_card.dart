import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';
import '../../theme/app_theme.dart';

class InspectorRecurrenceCard extends StatelessWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final Function(String taskId) onSkipRecurrence;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorRecurrenceCard({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.onSkipRecurrence,
    required this.isLight,
    this.currentTheme,
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
    final theme = AppTheme.getDefinition(currentTheme ?? (isLight ? AppThemeId.light : AppThemeId.mocha));
    final recStr = task.recurrence ?? '';
    final isStrict = recStr.contains('strict:') || recStr.contains('+');
    final cleanCurrentRec = recStr.replaceAll('strict:', '').replaceAll('+', '').replaceAll('rec:', '').trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.due.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.due.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'RECURRENCE (rec:)',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: theme.due,
                  ),
                ),
              ),
              if (task.recurrence != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: _clearRecurrence,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '[Remove]',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.priA,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _presetChip('Daily', '1d', cleanCurrentRec == '1d', theme),
              _presetChip('Weekdays', 'weekday', cleanCurrentRec == 'weekday', theme),
              _presetChip('Weekly', '1w', cleanCurrentRec == '1w', theme),
              _presetChip('Monthly', '1m', cleanCurrentRec == '1m', theme),
            ],
          ),
          if (task.recurrence != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: _toggleStrictRecurrence,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isStrict ? theme.due.withValues(alpha: 0.25) : theme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isStrict ? theme.due : theme.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isStrict ? '⚡ Strict Mode' : '🔄 Relative Mode',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: isStrict ? theme.due : theme.subtext,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onSkipRecurrence(task.id),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.priB.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.priB.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Text(
                      '[Skip Cycle]',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: theme.priB,
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

  Widget _presetChip(String label, String rule, bool isActive, ThemeDefinition theme) {
    return InkWell(
      onTap: () => _setRecurrence(rule),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? theme.due.withValues(alpha: 0.22) : theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? theme.due : theme.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.due : theme.subtext,
          ),
        ),
      ),
    );
  }
}
