import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'inspector/inspector_header.dart';
import 'inspector/inspector_title_section.dart';
import 'inspector/inspector_metadata_section.dart';
import 'inspector/inspector_recurrence_card.dart';
import 'inspector/inspector_tags_section.dart';
import 'inspector/inspector_description_section.dart';
import 'inspector/inspector_subtasks_section.dart';
import 'inspector/inspector_comments_section.dart';

export 'inspector/inspector_header.dart';
export 'inspector/inspector_title_section.dart';
export 'inspector/inspector_metadata_section.dart';
export 'inspector/inspector_recurrence_card.dart';
export 'inspector/inspector_tags_section.dart';
export 'inspector/inspector_description_section.dart';
export 'inspector/inspector_subtasks_section.dart';
export 'inspector/inspector_comments_section.dart';

class InspectorDrawerWidget extends StatelessWidget {
  final Task? task;
  final VoidCallback onClose;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final Function(Task task) onSaveAsTemplate;
  final Function(String taskId) onSkipRecurrence;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorDrawerWidget({
    super.key,
    required this.task,
    required this.onClose,
    required this.onUpdateTask,
    required this.onSaveAsTemplate,
    required this.onSkipRecurrence,
    required this.isLight,
    this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getDefinition(currentTheme ?? (isLight ? AppThemeId.light : AppThemeId.mocha));

    if (task == null) {
      return Container(
        width: 340,
        color: theme.card,
        child: Center(
          child: Text(
            'Select a task to view details',
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: theme.subtext),
          ),
        ),
      );
    }

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: theme.card,
        border: Border(left: BorderSide(color: theme.border, width: 1)),
      ),
      child: Column(
        children: [
          InspectorHeader(
            task: task!,
            onClose: onClose,
            onSaveAsTemplate: onSaveAsTemplate,
            isLight: isLight,
            currentTheme: currentTheme,
          ),
          Expanded(
            child: ListView(
              // Generous bottom padding (96dp) ensures FAB never covers last input / submit button
              padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 96),
              children: [
                InspectorTitleSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorMetadataSection(
                  task: task!,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorRecurrenceCard(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  onSkipRecurrence: onSkipRecurrence,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorTagsSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorDescriptionSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorSubtasksSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.border),
                const SizedBox(height: 14),
                InspectorCommentsSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                  currentTheme: currentTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
