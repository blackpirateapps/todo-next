import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';
import '../../theme/app_theme.dart';
import '../formatted_text.dart';

class InspectorTitleSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorTitleSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
    this.currentTheme,
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
    final theme = AppTheme.getDefinition(widget.currentTheme ?? (widget.isLight ? AppThemeId.light : AppThemeId.mocha));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TASK NAME',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.subtext,
              ),
            ),
            InkWell(
              onTap: () {
                if (_isEditingTitle) {
                  _saveRawText();
                } else {
                  setState(() => _isEditingTitle = true);
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.accent.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  _isEditingTitle ? '[Save]' : '[Edit]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditingTitle) ...[
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border, width: 1),
            ),
            child: TextField(
              controller: _titleController,
              maxLines: 3,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: theme.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Edit raw task string...',
                hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _saveRawText,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: theme.isLight ? Colors.white : const Color(0xFF11111B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'Update Task Raw',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FormattedText(
              text: widget.task.raw,
              isCompleted: widget.task.completed,
              isLight: widget.isLight,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
