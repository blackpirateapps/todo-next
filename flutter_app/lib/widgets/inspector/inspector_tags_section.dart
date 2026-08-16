import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';
import '../../theme/app_theme.dart';

class InspectorTagsSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorTagsSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
    this.currentTheme,
  });

  @override
  State<InspectorTagsSection> createState() => _InspectorTagsSectionState();
}

class _InspectorTagsSectionState extends State<InspectorTagsSection> {
  late final TextEditingController _newProjectController;
  late final TextEditingController _newContextController;

  @override
  void initState() {
    super.initState();
    _newProjectController = TextEditingController();
    _newContextController = TextEditingController();
  }

  @override
  void dispose() {
    _newProjectController.dispose();
    _newContextController.dispose();
    super.dispose();
  }

  void _addProject() {
    String val = _newProjectController.text.trim();
    if (val.isEmpty) return;
    if (!val.startsWith('+')) val = '+$val';

    final updatedProjects = {...widget.task.projects, val}.toList();
    final newRaw = buildRawFromStructured(
      title: widget.task.title,
      priority: widget.task.priority,
      creationDate: widget.task.creationDate,
      dueDate: widget.task.dueDate,
      dueTime: widget.task.dueTime,
      recurrence: widget.task.recurrence,
      completed: widget.task.completed,
      projects: updatedProjects,
      contexts: widget.task.contexts,
    );

    widget.onUpdateTask(widget.task.id, {
      'projects': updatedProjects,
      'raw': newRaw,
    });

    _newProjectController.clear();
  }

  void _addContext() {
    String val = _newContextController.text.trim();
    if (val.isEmpty) return;
    if (!val.startsWith('@')) val = '@$val';

    final updatedContexts = {...widget.task.contexts, val}.toList();
    final newRaw = buildRawFromStructured(
      title: widget.task.title,
      priority: widget.task.priority,
      creationDate: widget.task.creationDate,
      dueDate: widget.task.dueDate,
      dueTime: widget.task.dueTime,
      recurrence: widget.task.recurrence,
      completed: widget.task.completed,
      projects: widget.task.projects,
      contexts: updatedContexts,
    );

    widget.onUpdateTask(widget.task.id, {
      'contexts': updatedContexts,
      'raw': newRaw,
    });

    _newContextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getDefinition(widget.currentTheme ?? (widget.isLight ? AppThemeId.light : AppThemeId.mocha));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PROJECTS
        Text(
          'PROJECTS (+PROJ)',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: theme.subtext,
          ),
        ),
        const SizedBox(height: 6),
        if (widget.task.projects.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.task.projects
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.project.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.project.withValues(alpha: 0.35), width: 1),
                      ),
                      child: Text(
                        p,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.project,
                        ),
                      ),
                    ))
                .toList(),
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
                  controller: _newProjectController,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.text),
                  decoration: InputDecoration(
                    hintText: '+ add project...',
                    hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addProject(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 16, color: theme.project),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
                onPressed: _addProject,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        Divider(height: 1, color: theme.border),
        const SizedBox(height: 14),

        // CONTEXTS
        Text(
          'CONTEXTS (@CTX)',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: theme.subtext,
          ),
        ),
        const SizedBox(height: 6),
        if (widget.task.contexts.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.task.contexts
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.context.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.context.withValues(alpha: 0.35), width: 1),
                      ),
                      child: Text(
                        c,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.context,
                        ),
                      ),
                    ))
                .toList(),
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
                  controller: _newContextController,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.text),
                  decoration: InputDecoration(
                    hintText: '@ add context...',
                    hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addContext(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 16, color: theme.context),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(),
                onPressed: _addContext,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
