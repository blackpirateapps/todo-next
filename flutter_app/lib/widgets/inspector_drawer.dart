import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/comment.dart';
import '../utils/todo_parser.dart';
import 'formatted_text.dart';
import 'subtask_progress_bar.dart';

class InspectorDrawerWidget extends StatefulWidget {
  final Task? task;
  final VoidCallback onClose;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final Function(Task task) onSaveAsTemplate;
  final Function(String taskId) onSkipRecurrence;
  final bool isLight;

  const InspectorDrawerWidget({
    super.key,
    required this.task,
    required this.onClose,
    required this.onUpdateTask,
    required this.onSaveAsTemplate,
    required this.onSkipRecurrence,
    required this.isLight,
  });

  @override
  State<InspectorDrawerWidget> createState() => _InspectorDrawerWidgetState();
}

class _InspectorDrawerWidgetState extends State<InspectorDrawerWidget> {
  bool _isEditingTitle = false;
  bool _isEditingDescription = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _newProjectController;
  late TextEditingController _newContextController;
  late TextEditingController _newSubtaskController;
  late TextEditingController _commentAuthorController;
  late TextEditingController _commentTextController;
  late TextEditingController _recInputController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _newProjectController = TextEditingController();
    _newContextController = TextEditingController();
    _newSubtaskController = TextEditingController();
    _commentAuthorController = TextEditingController(text: 'user');
    _commentTextController = TextEditingController();
    _recInputController = TextEditingController();

    _updateControllers();
  }

  @override
  void didUpdateWidget(covariant InspectorDrawerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task?.id != widget.task?.id || oldWidget.task?.raw != widget.task?.raw) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (widget.task != null) {
      _titleController.text = widget.task!.raw;
      _descController.text = widget.task!.description;
      _recInputController.text = widget.task!.recurrence ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newProjectController.dispose();
    _newContextController.dispose();
    _newSubtaskController.dispose();
    _commentAuthorController.dispose();
    _commentTextController.dispose();
    _recInputController.dispose();
    super.dispose();
  }

  void _saveRawText() {
    if (widget.task == null) return;
    final newRaw = _titleController.text.trim();
    final parsed = parseRawToStructured(newRaw, widget.task!.creationDate);

    widget.onUpdateTask(widget.task!.id, {
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

  void _setRecurrence(String rule) {
    if (widget.task == null) return;
    final cleanRule = rule.toLowerCase().startsWith('rec:') ? rule.substring(4) : rule;

    final newRaw = updateRawDates(widget.task!.raw);
    final parsed = parseRawToStructured(newRaw);

    final rebuiltRaw = buildRawFromStructured(
      title: parsed.title,
      priority: parsed.priority,
      creationDate: parsed.creationDate,
      completionDate: parsed.completionDate,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      recurrence: cleanRule,
      completed: parsed.completed,
      projects: parsed.projects,
      contexts: parsed.contexts,
    );

    widget.onUpdateTask(widget.task!.id, {
      'recurrence': cleanRule,
      'raw': rebuiltRaw,
    });
  }

  void _clearRecurrence() {
    if (widget.task == null) return;
    final parsed = parseRawToStructured(widget.task!.raw);
    final rebuiltRaw = buildRawFromStructured(
      title: parsed.title,
      priority: parsed.priority,
      creationDate: parsed.creationDate,
      completionDate: parsed.completionDate,
      dueDate: parsed.dueDate,
      dueTime: parsed.dueTime,
      recurrence: null,
      completed: parsed.completed,
      projects: parsed.projects,
      contexts: parsed.contexts,
    );

    widget.onUpdateTask(widget.task!.id, {
      'recurrence': null,
      'raw': rebuiltRaw,
    });
  }

  void _toggleStrictRecurrence() {
    if (widget.task == null || widget.task!.recurrence == null) return;
    final current = widget.task!.recurrence!;

    String nextRule;
    if (current.startsWith('strict:') || current.startsWith('+')) {
      nextRule = current.replaceAll('strict:', '').replaceAll('+', '');
    } else {
      nextRule = 'strict:$current';
    }
    _setRecurrence(nextRule);
  }

  void _addProject() {
    if (widget.task == null) return;
    String val = _newProjectController.text.trim();
    if (val.isEmpty) return;
    if (!val.startsWith('+')) val = '+$val';

    final updatedProjects = {...widget.task!.projects, val}.toList();
    final newRaw = buildRawFromStructured(
      title: widget.task!.title,
      priority: widget.task!.priority,
      creationDate: widget.task!.creationDate,
      dueDate: widget.task!.dueDate,
      dueTime: widget.task!.dueTime,
      recurrence: widget.task!.recurrence,
      completed: widget.task!.completed,
      projects: updatedProjects,
      contexts: widget.task!.contexts,
    );

    widget.onUpdateTask(widget.task!.id, {
      'projects': updatedProjects,
      'raw': newRaw,
    });

    _newProjectController.clear();
  }

  void _addContext() {
    if (widget.task == null) return;
    String val = _newContextController.text.trim();
    if (val.isEmpty) return;
    if (!val.startsWith('@')) val = '@$val';

    final updatedContexts = {...widget.task!.contexts, val}.toList();
    final newRaw = buildRawFromStructured(
      title: widget.task!.title,
      priority: widget.task!.priority,
      creationDate: widget.task!.creationDate,
      dueDate: widget.task!.dueDate,
      dueTime: widget.task!.dueTime,
      recurrence: widget.task!.recurrence,
      completed: widget.task!.completed,
      projects: widget.task!.projects,
      contexts: updatedContexts,
    );

    widget.onUpdateTask(widget.task!.id, {
      'contexts': updatedContexts,
      'raw': newRaw,
    });

    _newContextController.clear();
  }

  void _addSubtask() {
    if (widget.task == null) return;
    final title = _newSubtaskController.text.trim();
    if (title.isEmpty) return;

    final newSubtask = Subtask(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task!.id,
      title: title,
      raw: title,
      completed: false,
    );

    final updated = [...widget.task!.subtasks, newSubtask];
    widget.onUpdateTask(widget.task!.id, {
      'subtasks': updated.map((s) => s.toJson()).toList(),
    });

    _newSubtaskController.clear();
  }

  void _toggleSubtask(String subtaskId) {
    if (widget.task == null) return;
    final updated = widget.task!.subtasks.map((st) {
      if (st.id == subtaskId) return st.copyWith(completed: !st.completed);
      return st;
    }).toList();

    widget.onUpdateTask(widget.task!.id, {
      'subtasks': updated.map((s) => s.toJson()).toList(),
    });
  }

  void _addComment() {
    if (widget.task == null) return;
    final text = _commentTextController.text.trim();
    final author = _commentAuthorController.text.trim();
    if (text.isEmpty) return;

    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final newComment = Comment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task!.id,
      author: author.isEmpty ? 'user' : author,
      timestamp: nowStr,
      text: text,
    );

    final updated = [...widget.task!.comments, newComment];
    widget.onUpdateTask(widget.task!.id, {
      'comments': updated.map((c) => c.toJson()).toList(),
    });

    _commentTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task == null) {
      return Container(
        width: 320,
        color: widget.isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B),
        child: Center(
          child: Text('Select a task to view details', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[600])),
        ),
      );
    }

    final task = widget.task!;
    final bg = widget.isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    final recStr = task.recurrence ?? '';
    final isStrict = recStr.contains('strict:') || recStr.contains('+');

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isLight ? Colors.grey[200] : const Color(0xFF18181B),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text('INSPECTOR', overflow: TextOverflow.ellipsis, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => widget.onSaveAsTemplate(task),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: border)),
                    child: Text('[Save Template]', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan)),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: border)),
                    child: Text('[← Back]', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    Text('TASK NAME', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() => _isEditingTitle = !_isEditingTitle),
                      child: Text(_isEditingTitle ? '[Save]' : '[Edit]', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan)),
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
                  FormattedText(text: task.raw, isCompleted: task.completed, isLight: widget.isLight, fontSize: 13),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Text('ID: ${task.id}  Pri: ${task.priority ?? '-'}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text('Created: ${task.creationDate}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text('Due Date: ${task.dueDate ?? 'No due date'} ${task.dueTime ?? ''}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text('Status: ${task.completed ? 'Completed' : 'Open'}', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: task.completed ? Colors.green : Colors.amber)),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isLight ? Colors.purple[50] : Colors.purple[950]?.withAlpha(80),
                    border: Border.all(color: widget.isLight ? Colors.purple[200]! : Colors.purple[800]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('RECURRENCE (rec:)', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple[400])),
                          const Spacer(),
                          if (task.recurrence != null)
                            InkWell(
                              onTap: _clearRecurrence,
                              child: Text('[Remove]', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.red[400])),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          InkWell(
                            onTap: () => _setRecurrence('1d'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: border)),
                              child: Text('Daily', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                            ),
                          ),
                          InkWell(
                            onTap: () => _setRecurrence('weekday'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: border)),
                              child: Text('Weekdays', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                            ),
                          ),
                          InkWell(
                            onTap: () => _setRecurrence('1w'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: border)),
                              child: Text('Weekly', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                            ),
                          ),
                          InkWell(
                            onTap: () => _setRecurrence('1m'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(border: Border.all(color: border)),
                              child: Text('Monthly', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (task.recurrence != null) ...[
                        Row(
                          children: [
                            InkWell(
                              onTap: _toggleStrictRecurrence,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: isStrict ? Colors.purple[700] : Colors.grey[800],
                                child: Text(
                                  isStrict ? '⚡ Strict Mode' : '🔄 Relative Mode',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => widget.onSkipRecurrence(task.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
                                child: Text('[Skip Cycle]', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Text('PROJECTS (+PROJ)', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: task.projects.map((p) => Chip(
                    label: Text(p, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan)),
                    backgroundColor: widget.isLight ? Colors.cyan[50] : Colors.cyan[950],
                    padding: EdgeInsets.zero,
                  )).toList(),
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

                Text('CONTEXTS (@CTX)', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: task.contexts.map((c) => Chip(
                    label: Text(c, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.green)),
                    backgroundColor: widget.isLight ? Colors.green[50] : Colors.green[950],
                    padding: EdgeInsets.zero,
                  )).toList(),
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

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Text('DESCRIPTION', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        if (_isEditingDescription) {
                          widget.onUpdateTask(task.id, {'description': _descController.text.trim()});
                        }
                        setState(() => _isEditingDescription = !_isEditingDescription);
                      },
                      child: Text(_isEditingDescription ? '[Save]' : '[Edit]', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_isEditingDescription)
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                    decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: border))),
                  )
                else
                  Text(
                    task.description.isEmpty ? 'No description set.' : task.description,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: task.description.isEmpty ? Colors.grey[600] : null),
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Text('SUBTASKS', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                    const SizedBox(width: 8),
                    SubtaskProgressBar(subtasks: task.subtasks, isLight: widget.isLight, compact: false),
                  ],
                ),
                const SizedBox(height: 6),
                ...task.subtasks.map((st) => Row(
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
                )),
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

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                Text('COMMENTS', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                const SizedBox(height: 6),
                ...task.comments.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${c.author} • ${c.timestamp}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.cyan)),
                      const SizedBox(height: 2),
                      Text(c.text, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                    ],
                  ),
                )),
                const SizedBox(height: 4),
                TextField(
                  controller: _commentAuthorController,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  decoration: const InputDecoration(hintText: '@author', isDense: true),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _commentTextController,
                  maxLines: 2,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  decoration: const InputDecoration(hintText: 'Write a comment...', isDense: true),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Comment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
