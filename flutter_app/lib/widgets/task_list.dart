import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import 'formatted_text.dart';
import 'subtask_progress_bar.dart';

enum SortField { creationDate, dueDate, title, priority }
enum SortOrder { asc, desc }
enum StatusFilter { all, open, completed }
enum PriorityFilter { all, A, B, C, none }

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final String? selectedTaskId;
  final Function(Task) onSelectTask;
  final Function(String) onToggleTask;
  final Function(Task) onDeleteTask;
  final bool isLight;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.selectedTaskId,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.isLight,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  SortField _sortField = SortField.creationDate;
  SortOrder _sortOrder = SortOrder.desc;
  StatusFilter _statusFilter = StatusFilter.open;
  PriorityFilter _priorityFilter = PriorityFilter.all;
  String _periodFilter = 'all';

  List<String> _getPeriodOptions() {
    final Set<String> set = {};
    for (final t in widget.tasks) {
      if (t.creationDate.length >= 7) set.add(t.creationDate.substring(0, 7));
      if (t.dueDate != null && t.dueDate!.length >= 7) set.add(t.dueDate!.substring(0, 7));
    }
    return set.toList()..sort((a, b) => b.compareTo(a));
  }

  List<Task> _getProcessedTasks() {
    List<Task> result = List.from(widget.tasks);

    if (_statusFilter == StatusFilter.open) {
      result = result.where((t) => !t.completed).toList();
    } else if (_statusFilter == StatusFilter.completed) {
      result = result.where((t) => t.completed).toList();
    }

    if (_priorityFilter == PriorityFilter.none) {
      result = result.where((t) => t.priority == null || t.priority!.isEmpty).toList();
    } else if (_priorityFilter != PriorityFilter.all) {
      final priStr = _priorityFilter.name;
      result = result.where((t) => t.priority == priStr).toList();
    }

    if (_periodFilter != 'all') {
      result = result.where((t) =>
        t.creationDate.startsWith(_periodFilter) || (t.dueDate != null && t.dueDate!.startsWith(_periodFilter))
      ).toList();
    }

    result.sort((a, b) {
      int cmp = 0;
      if (_sortField == SortField.creationDate) {
        cmp = a.creationDate.compareTo(b.creationDate);
      } else if (_sortField == SortField.dueDate) {
        final da = a.dueDate ?? '9999-99-99';
        final db = b.dueDate ?? '9999-99-99';
        cmp = da.compareTo(db);
      } else if (_sortField == SortField.title) {
        cmp = a.title.compareTo(b.title);
      } else if (_sortField == SortField.priority) {
        final pa = a.priority ?? 'Z';
        final pb = b.priority ?? 'Z';
        cmp = pa.compareTo(pb);
      }
      return _sortOrder == SortOrder.asc ? cmp : -cmp;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final processed = _getProcessedTasks();
    final periodOptions = _getPeriodOptions();

    final bg = widget.isLight ? Colors.white : Colors.black;
    final headerBg = widget.isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      color: bg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Sort: ', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  DropdownButton<SortField>(
                    value: _sortField,
                    isDense: true,
                    dropdownColor: headerBg,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: widget.isLight ? Colors.black : Colors.white),
                    onChanged: (val) => setState(() => _sortField = val!),
                    items: const [
                      DropdownMenuItem(value: SortField.creationDate, child: Text('Creation Date')),
                      DropdownMenuItem(value: SortField.dueDate, child: Text('Due Date')),
                      DropdownMenuItem(value: SortField.title, child: Text('Title')),
                      DropdownMenuItem(value: SortField.priority, child: Text('Priority')),
                    ],
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => setState(() => _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(border: Border.all(color: border)),
                      child: Text(
                        _sortOrder == SortOrder.asc ? '[ASC ↑]' : '[DESC ↓]',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Text('Filter: ', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  DropdownButton<StatusFilter>(
                    value: _statusFilter,
                    isDense: true,
                    dropdownColor: headerBg,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: widget.isLight ? Colors.black : Colors.white),
                    onChanged: (val) => setState(() => _statusFilter = val!),
                    items: const [
                      DropdownMenuItem(value: StatusFilter.all, child: Text('Status: All')),
                      DropdownMenuItem(value: StatusFilter.open, child: Text('Open')),
                      DropdownMenuItem(value: StatusFilter.completed, child: Text('Completed')),
                    ],
                  ),
                  const SizedBox(width: 4),
                  DropdownButton<PriorityFilter>(
                    value: _priorityFilter,
                    isDense: true,
                    dropdownColor: headerBg,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: widget.isLight ? Colors.black : Colors.white),
                    onChanged: (val) => setState(() => _priorityFilter = val!),
                    items: const [
                      DropdownMenuItem(value: PriorityFilter.all, child: Text('Pri: All')),
                      DropdownMenuItem(value: PriorityFilter.A, child: Text('(A)')),
                      DropdownMenuItem(value: PriorityFilter.B, child: Text('(B)')),
                      DropdownMenuItem(value: PriorityFilter.C, child: Text('(C)')),
                      DropdownMenuItem(value: PriorityFilter.none, child: Text('None')),
                    ],
                  ),
                  const SizedBox(width: 4),
                  DropdownButton<String>(
                    value: _periodFilter,
                    isDense: true,
                    dropdownColor: headerBg,
                    underline: const SizedBox.shrink(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: widget.isLight ? Colors.black : Colors.white),
                    onChanged: (val) => setState(() => _periodFilter = val!),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('Period: All')),
                      ...periodOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isLight ? Colors.grey[200] : const Color(0xFF18181B),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('St', textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]))),
                SizedBox(width: 32, child: Text('Pr', textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]))),
                Expanded(child: Text('Task', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]))),
                SizedBox(width: 44, child: Text('Del', textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]))),
              ],
            ),
          ),

          Expanded(
            child: processed.isEmpty
                ? Center(
                    child: Text(
                      'No tasks matched query or filters.',
                      style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: processed.length,
                    itemBuilder: (context, index) {
                      final task = processed[index];
                      final isSelected = widget.selectedTaskId == task.id;

                      final rowBg = isSelected
                          ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                          : Colors.transparent;

                      return InkWell(
                        onTap: () => widget.onSelectTask(task),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: rowBg,
                            border: Border(bottom: BorderSide(color: border)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 40,
                                child: InkWell(
                                  onTap: () => widget.onToggleTask(task.id),
                                  child: Text(
                                    task.completed ? '[x]' : '[ ]',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isLight ? Colors.grey[700] : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 32,
                                child: Text(
                                  task.priority ?? '-',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ),

                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    FormattedText(text: task.raw, isCompleted: task.completed, isLight: widget.isLight),
                                    if (task.recurrence != null && task.recurrence!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: (task.recurrence!.contains('strict:') || task.recurrence!.contains('+'))
                                              ? (widget.isLight ? Colors.purple[100] : Colors.purple[950])
                                              : (widget.isLight ? Colors.cyan[100] : Colors.cyan[950]),
                                          border: Border.all(
                                            color: (task.recurrence!.contains('strict:') || task.recurrence!.contains('+'))
                                                ? (widget.isLight ? Colors.purple[300]! : Colors.purple[800]!)
                                                : (widget.isLight ? Colors.cyan[300]! : Colors.cyan[800]!),
                                          ),
                                        ),
                                        child: Text(
                                          '${(task.recurrence!.contains('strict:') || task.recurrence!.contains('+')) ? '⚡' : '🔄'} ${task.recurrence!.startsWith('rec:') ? task.recurrence : 'rec:${task.recurrence}'}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: (task.recurrence!.contains('strict:') || task.recurrence!.contains('+'))
                                                ? (widget.isLight ? Colors.purple[900] : Colors.purple[300])
                                                : (widget.isLight ? Colors.cyan[900] : Colors.cyan[300]),
                                          ),
                                        ),
                                      ),
                                    if (task.subtasks.isNotEmpty)
                                      SubtaskProgressBar(subtasks: task.subtasks, isLight: widget.isLight, compact: true, showText: true),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: 44,
                                child: InkWell(
                                  onTap: () => widget.onDeleteTask(task),
                                  child: Text(
                                    '[del]',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
