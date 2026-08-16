import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class InspectorDescriptionSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorDescriptionSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
    this.currentTheme,
  });

  @override
  State<InspectorDescriptionSection> createState() => _InspectorDescriptionSectionState();
}

class _InspectorDescriptionSectionState extends State<InspectorDescriptionSection> {
  bool _isEditingDescription = false;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.task.description);
  }

  @override
  void didUpdateWidget(covariant InspectorDescriptionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || oldWidget.task.description != widget.task.description) {
      _descController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditingDescription) {
      widget.onUpdateTask(widget.task.id, {'description': _descController.text.trim()});
    }
    setState(() => _isEditingDescription = !_isEditingDescription);
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
              'DESCRIPTION',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.subtext,
              ),
            ),
            InkWell(
              onTap: _toggleEdit,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.accent.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  _isEditingDescription ? '[Save]' : '[Edit]',
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
        if (_isEditingDescription)
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border, width: 1),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: theme.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Enter task description...',
                hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border.withValues(alpha: 0.4), width: 1),
            ),
            child: Text(
              widget.task.description.isEmpty ? 'No description set.' : widget.task.description,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                height: 1.4,
                color: widget.task.description.isEmpty ? theme.subtext.withValues(alpha: 0.6) : theme.text,
              ),
            ),
          ),
      ],
    );
  }
}
