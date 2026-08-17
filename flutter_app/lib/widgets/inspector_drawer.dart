import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
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
  final bool showIcons;

  const InspectorDrawerWidget({
    super.key,
    required this.task,
    required this.onClose,
    required this.onUpdateTask,
    required this.onSaveAsTemplate,
    required this.onSkipRecurrence,
    required this.isLight,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 400 ? 340.0 : (screenWidth * 0.92);

    if (task == null) {
      return Container(
        width: drawerWidth,
        color: isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B),
        child: Center(
          child: Text(
            'Select a task to view details',
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      );
    }

    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          InspectorHeader(
            task: task!,
            onClose: onClose,
            onSaveAsTemplate: onSaveAsTemplate,
            isLight: isLight,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                InspectorTitleSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorMetadataSection(task: task!),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorRecurrenceCard(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  onSkipRecurrence: onSkipRecurrence,
                  isLight: isLight,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorTagsSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorDescriptionSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorSubtasksSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                InspectorCommentsSection(
                  task: task!,
                  onUpdateTask: onUpdateTask,
                  isLight: isLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
