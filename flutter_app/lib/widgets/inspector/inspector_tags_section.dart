import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';
import '../../utils/todo_parser.dart';

class InspectorTagsSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;

  const InspectorTagsSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PROJECTS
        Text(
          'PROJECTS (+PROJ)',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: widget.task.projects
              .map((p) => Chip(
                    label: Text(p, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan)),
                    backgroundColor: widget.isLight ? Colors.cyan[50] : Colors.cyan[950],
                    padding: EdgeInsets.zero,
                  ))
              .toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newProjectController,
                style: GoogleFonts.jetBrainsMono(fontSize: 11),
                decoration: const InputDecoration(hintText: '+ add project...', isDense: true),
              ),
            ),
            IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _addProject),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // CONTEXTS
        Text(
          'CONTEXTS (@CTX)',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: widget.task.contexts
              .map((c) => Chip(
                    label: Text(c, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.green)),
                    backgroundColor: widget.isLight ? Colors.green[50] : Colors.green[950],
                    padding: EdgeInsets.zero,
                  ))
              .toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newContextController,
                style: GoogleFonts.jetBrainsMono(fontSize: 11),
                decoration: const InputDecoration(hintText: '@ add context...', isDense: true),
              ),
            ),
            IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _addContext),
          ],
        ),
      ],
    );
  }
}
