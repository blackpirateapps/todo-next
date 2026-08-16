import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../../theme/app_theme.dart';
import '../subtask_progress_bar.dart';

class InspectorSubtasksSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorSubtasksSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
    this.currentTheme,
  });

  @override
  State<InspectorSubtasksSection> createState() => _InspectorSubtasksSectionState();
}

class _InspectorSubtasksSectionState extends State<InspectorSubtasksSection> {
  late final TextEditingController _newSubtaskController;

  @override
  void initState() {
    super.initState();
    _newSubtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final title = _newSubtaskController.text.trim();
    if (title.isEmpty) return;

    final newSubtask = Subtask(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task.id,
      title: title,
      raw: title,
      completed: false,
    );

    final updated = [...widget.task.subtasks, newSubtask];
    widget.onUpdateTask(widget.task.id, {
      'subtasks': updated.map((s) => s.toJson()).toList(),
    });

    _newSubtaskController.clear();
  }

  void _toggleSubtask(String subtaskId) {
    final updated = widget.task.subtasks.map((st) {
      if (st.id == subtaskId) return st.copyWith(completed: !st.completed);
      return st;
    }).toList();

    widget.onUpdateTask(widget.task.id, {
      'subtasks': updated.map((s) => s.toJson()).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getDefinition(widget.currentTheme ?? (widget.isLight ? AppThemeId.light : AppThemeId.mocha));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SUBTASKS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.subtext,
              ),
            ),
            const SizedBox(width: 8),
            SubtaskProgressBar(subtasks: widget.task.subtasks, isLight: widget.isLight, compact: false),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.task.subtasks.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border.withValues(alpha: 0.5), width: 1),
            ),
            child: Column(
              children: widget.task.subtasks.asMap().entries.map((entry) {
                final idx = entry.key;
                final st = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleSubtask(st.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              st.completed ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              size: 18,
                              color: st.completed ? theme.context : theme.subtext,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                st.title,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  decoration: st.completed ? TextDecoration.lineThrough : null,
                                  color: st.completed ? theme.subtext.withValues(alpha: 0.6) : theme.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (idx < widget.task.subtasks.length - 1)
                      Divider(height: 1, color: theme.border.withValues(alpha: 0.3)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.border, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSubtaskController,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.text),
                  decoration: InputDecoration(
                    hintText: '+ add subtask...',
                    hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 16, color: theme.accent),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
                onPressed: _addSubtask,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
