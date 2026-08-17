import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import 'task_list/task_list_toolbar.dart';
import 'task_list/task_list_header.dart';
import 'task_list/task_list_item.dart';

export 'task_list/task_list_toolbar.dart';
export 'task_list/task_list_header.dart';
export 'task_list/task_list_item.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final String? selectedTaskId;
  final Function(Task) onSelectTask;
  final Function(String) onToggleTask;
  final Function(Task) onDeleteTask;
  final bool isLight;
  final bool showIcons;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.selectedTaskId,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.isLight,
    this.showIcons = false,
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

    return Container(
      color: bg,
      child: Column(
        children: [
          TaskListToolbar(
            sortField: _sortField,
            sortOrder: _sortOrder,
            statusFilter: _statusFilter,
            priorityFilter: _priorityFilter,
            periodFilter: _periodFilter,
            periodOptions: periodOptions,
            onSortFieldChanged: (f) => setState(() => _sortField = f),
            onToggleSortOrder: () => setState(() => _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc),
            onStatusFilterChanged: (s) => setState(() => _statusFilter = s),
            onPriorityFilterChanged: (p) => setState(() => _priorityFilter = p),
            onPeriodFilterChanged: (p) => setState(() => _periodFilter = p),
            isLight: widget.isLight,
            showIcons: widget.showIcons,
          ),
          TaskListHeader(
            isLight: widget.isLight,
            showIcons: widget.showIcons,
          ),
          Expanded(
            child: processed.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.showIcons
                            ? '✨ No tasks matching current filter or search.'
                            : 'No tasks matching current filter or search.',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: processed.length,
                    itemBuilder: (context, index) {
                      final task = processed[index];
                      return TaskListItem(
                        task: task,
                        isSelected: widget.selectedTaskId == task.id,
                        onSelectTask: widget.onSelectTask,
                        onToggleTask: widget.onToggleTask,
                        onDeleteTask: widget.onDeleteTask,
                        isLight: widget.isLight,
                        showIcons: widget.showIcons,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
