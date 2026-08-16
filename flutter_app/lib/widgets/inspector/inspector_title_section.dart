import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';
import '../formatted_text.dart';

class InspectorTitleSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;

  const InspectorTitleSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
  });

  @override
  State<InspectorTitleSection> createState() => _InspectorTitleSectionState();
}

class _InspectorTitleSectionState extends State<InspectorTitleSection> {
  bool _isEditingTitle = false;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.raw);
  }

  @override
  void didUpdateWidget(covariant InspectorTitleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || oldWidget.task.raw != widget.task.raw) {
      _titleController.text = widget.task.raw;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveRawText() {
    final newRaw = _titleController.text.trim();
    final parsed = parseRawToStructured(newRaw, widget.task.creationDate);

    widget.onUpdateTask(widget.task.id, {
      'raw': newRaw,
      'title': parsed.title,
      'priority': parsed.priority,
      'creationDate': parsed.creationDate,
      'completionDate': parsed.completionDate,
      'dueDate': parsed.dueDate,
      'dueTime': parsed.dueTime,
      'recurrence': parsed.recurrence,
      'completed': parsed.completed,
      'status': parsed.completed ? 'completed' : 'open',
      'projects': parsed.projects,
      'contexts': parsed.contexts,
    });

    setState(() => _isEditingTitle = false);
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TASK NAME',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => setState(() => _isEditingTitle = !_isEditingTitle),
              child: Text(
                _isEditingTitle ? '[Save]' : '[Edit]',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_isEditingTitle) ...[
          TextField(
            controller: _titleController,
            maxLines: 3,
            style: GoogleFonts.jetBrainsMono(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(color: border)),
              contentPadding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saveRawText,
              child: const Text('Update Task Raw'),
            ),
          ),
        ] else ...[
          FormattedText(
            text: widget.task.raw,
            isCompleted: widget.task.completed,
            isLight: widget.isLight,
            fontSize: 13,
          ),
        ],
      ],
    );
  }
}
