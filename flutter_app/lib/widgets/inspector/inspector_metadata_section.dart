import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class InspectorMetadataSection extends StatelessWidget {
  final Task task;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorMetadataSection({
    super.key,
    required this.task,
    this.isLight = false,
    this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getDefinition(currentTheme ?? (isLight ? AppThemeId.light : AppThemeId.mocha));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _metaRow(
                  label: 'ID',
                  value: task.id,
                  theme: theme,
                  valColor: theme.subtext,
                ),
              ),
              const SizedBox(width: 8),
              _metaRow(
                label: 'Pri',
                value: task.priority ?? '-',
                theme: theme,
                valColor: task.priority == 'A'
                    ? theme.priA
                    : (task.priority == 'B'
                        ? theme.priB
                        : (task.priority == 'C' ? theme.priC : theme.text)),
                isBold: true,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(height: 1, color: theme.border.withValues(alpha: 0.6)),
          const SizedBox(height: 6),
          _metaRow(
            label: 'Created',
            value: task.creationDate,
            theme: theme,
            valColor: theme.text,
          ),
          const SizedBox(height: 6),
          _metaRow(
            label: 'Due Date',
            value: '${task.dueDate ?? 'No due date'}${task.dueTime != null ? ' ${task.dueTime}' : ''}',
            theme: theme,
            valColor: task.dueDate != null ? theme.due : theme.subtext,
          ),
          const SizedBox(height: 6),
          Divider(height: 1, color: theme.border.withValues(alpha: 0.6)),
          const SizedBox(height: 6),
          _metaRow(
            label: 'Status',
            value: task.completed ? 'Completed ✓' : 'Open ⏳',
            theme: theme,
            valColor: task.completed ? theme.context : theme.priB,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _metaRow({
    required String label,
    required String value,
    required ThemeDefinition theme,
    required Color valColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: theme.subtext,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valColor,
            ),
          ),
        ),
      ],
    );
  }
}
