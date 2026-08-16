import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../subtask_progress_bar.dart';

class InspectorSubtasksSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;

  const InspectorSubtasksSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
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
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 8),
            SubtaskProgressBar(subtasks: widget.task.subtasks, isLight: widget.isLight, compact: false),
          ],
        ),
        const SizedBox(height: 6),
        ...widget.task.subtasks.map(
          (st) => Row(
            children: [
              Checkbox(
                value: st.completed,
                onChanged: (val) => _toggleSubtask(st.id),
              ),
              Expanded(
                child: Text(
                  st.title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    decoration: st.completed ? TextDecoration.lineThrough : null,
                    color: st.completed ? Colors.grey[600] : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSubtaskController,
                style: GoogleFonts.jetBrainsMono(fontSize: 11),
                decoration: const InputDecoration(hintText: '+ add subtask...', isDense: true),
              ),
            ),
            IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _addSubtask),
          ],
        ),
      ],
    );
  }
}
