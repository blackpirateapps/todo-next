import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_utils.dart';
import '../utils/recurrence_engine.dart';
import 'calendar/calendar_header.dart';
import 'calendar/calendar_weekday_header.dart';
import 'calendar/calendar_day_cell.dart';

export 'calendar/calendar_header.dart';
export 'calendar/calendar_weekday_header.dart';
export 'calendar/calendar_day_cell.dart';

class CalendarViewWidget extends StatefulWidget {
  final List<Task> tasks;
  final String? selectedTaskId;
  final Function(Task) onSelectTask;
  final Function(String) onToggleTask;
  final Function(String taskId, String targetDate, String? targetTime) onMoveTask;
  final Function(String dateISO, String? timeStr) onCreateTaskAtDate;
  final bool isLight;

  const CalendarViewWidget({
    super.key,
    required this.tasks,
    this.selectedTaskId,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onMoveTask,
    required this.onCreateTaskAtDate,
    required this.isLight,
  });

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  String _viewMode = 'month'; // 'month' | 'week'
  String _dateField = 'due'; // 'due' | 'creation'
  DateTime _currentDate = DateTime.now();

  void _handlePrev() {
    setState(() {
      if (_viewMode == 'month') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - 7);
      }
    });
  }

  void _handleNext() {
    setState(() {
      if (_viewMode == 'month') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day + 7);
      }
    });
  }

  void _handleToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  Map<String, List<Task>> _getTasksByDate() {
    final Map<String, List<Task>> map = {};
    for (final task in widget.tasks) {
      final targetDate = _dateField == 'due' ? task.dueDate : task.creationDate;
      if (targetDate != null && targetDate.isNotEmpty) {
        map.putIfAbsent(targetDate, () => []).add(task);
      }
    }
    return map;
  }

  Map<String, List<Task>> _getProjectedRecurringByDate() {
    final Map<String, List<Task>> map = {};
    if (_dateField != 'due') return map;

    for (final t in widget.tasks) {
      if (t.recurrence != null && t.recurrence!.isNotEmpty && !t.completed) {
        final upcoming = getUpcomingRecurrenceDates(t, 5);
        for (final dISO in upcoming) {
          map.putIfAbsent(dISO, () => []).add(t);
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _viewMode == 'month'
        ? getMonthDays(_currentDate.year, _currentDate.month - 1)
        : getWeekDays(_currentDate);

    final tasksByDate = _getTasksByDate();
    final projectedByDate = _getProjectedRecurringByDate();

    final bg = widget.isLight ? Colors.white : Colors.black;

    return Container(
      color: bg,
      child: Column(
        children: [
          CalendarHeader(
            currentDate: _currentDate,
            dateField: _dateField,
            viewMode: _viewMode,
            onPrev: _handlePrev,
            onNext: _handleNext,
            onToday: _handleToday,
            onSelectDateField: (val) => setState(() => _dateField = val),
            onSelectViewMode: (val) => setState(() => _viewMode = val),
            isLight: widget.isLight,
          ),
          CalendarWeekdayHeader(isLight: widget.isLight),
          Expanded(
            child: GridView.builder(
              itemCount: calendarDays.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: _viewMode == 'month' ? 0.75 : 0.5,
              ),
              itemBuilder: (context, index) {
                final dayDate = calendarDays[index];
                final dayISO = formatDateISO(dayDate);
                final dayTasks = tasksByDate[dayISO] ?? [];
                final projectedTasks = projectedByDate[dayISO] ?? [];

                return CalendarDayCell(
                  dayDate: dayDate,
                  currentDate: _currentDate,
                  dayTasks: dayTasks,
                  projectedTasks: projectedTasks,
                  selectedTaskId: widget.selectedTaskId,
                  onSelectTask: widget.onSelectTask,
                  onToggleTask: widget.onToggleTask,
                  onMoveTask: widget.onMoveTask,
                  onCreateTaskAtDate: widget.onCreateTaskAtDate,
                  isLight: widget.isLight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
