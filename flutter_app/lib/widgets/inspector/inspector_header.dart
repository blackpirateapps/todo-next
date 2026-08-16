import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class InspectorHeader extends StatefulWidget {
  final Task task;
  final VoidCallback onClose;
  final Function(Task task) onSaveAsTemplate;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorHeader({
    super.key,
    required this.task,
    required this.onClose,
    required this.onSaveAsTemplate,
    required this.isLight,
    this.currentTheme,
  });

  @override
  State<InspectorHeader> createState() => _InspectorHeaderState();
}

class _InspectorHeaderState extends State<InspectorHeader> {
  bool _isSaving = false;

  void _handleSave() {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    widget.onSaveAsTemplate(widget.task);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getDefinition(widget.currentTheme ?? (widget.isLight ? AppThemeId.light : AppThemeId.mocha));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.card,
        border: Border(bottom: BorderSide(color: theme.border, width: 1)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'INSPECTOR',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.subtext,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isSaving ? null : _handleSave,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isSaving
                    ? theme.context.withValues(alpha: 0.15)
                    : theme.accent.withValues(alpha: 0.1),
                border: Border.all(
                  color: _isSaving ? theme.context : theme.accent.withValues(alpha: 0.4),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isSaving ? '[Saved ✓]' : '[Save Template]',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isSaving ? theme.context : theme.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.surface.withValues(alpha: 0.6),
                border: Border.all(color: theme.border, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '[← Back]',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.subtext,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
