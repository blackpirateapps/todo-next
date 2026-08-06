import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/date_utils.dart';
import '../utils/recurrence_engine.dart';
import 'formatted_text.dart';

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
    final todayISO = formatDateISO(DateTime.now());
    final calendarDays = _viewMode == 'month'
        ? getMonthDays(_currentDate.year, _currentDate.month - 1)
        : getWeekDays(_currentDate);

    final tasksByDate = _getTasksByDate();
    final projectedByDate = _getProjectedRecurringByDate();

    final monthName = monthNames[_currentDate.month - 1];
    final year = _currentDate.year;

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
                  Row(
                    children: [
                      InkWell(
                        onTap: _handlePrev,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(border: Border.all(color: border)),
                          child: Text('[<]', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                        ),
                      ),
                      InkWell(
                        onTap: _handleToday,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(border: Border.all(color: border)),
                          child: Text('Today', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      InkWell(
                        onTap: _handleNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(border: Border.all(color: border)),
                          child: Text('[>]', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$monthName $year',
                    style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 16),
                  Text('Date: ', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _dateField = 'due'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: _dateField == 'due'
                              ? (widget.isLight ? Colors.purple[200] : Colors.purple[950])
                              : Colors.transparent,
                          child: Text(
                            'Due Date',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: _dateField == 'due' ? FontWeight.bold : FontWeight.normal,
                              color: _dateField == 'due'
                                  ? (widget.isLight ? Colors.purple[900] : Colors.purple[300])
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _dateField = 'creation'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: _dateField == 'creation'
                              ? (widget.isLight ? Colors.blue[200] : Colors.blue[950])
                              : Colors.transparent,
                          child: Text(
                            'Created Date',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: _dateField == 'creation' ? FontWeight.bold : FontWeight.normal,
                              color: _dateField == 'creation'
                                  ? (widget.isLight ? Colors.blue[900] : Colors.blue[300])
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _viewMode = 'month'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: _viewMode == 'month'
                              ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                              : Colors.transparent,
                          child: Text('Month', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _viewMode = 'week'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: _viewMode == 'week'
                              ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                              : Colors.transparent,
                          child: Text('Week', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: widget.isLight ? Colors.grey[200] : const Color(0xFF18181B),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: weekdayNames.map((d) => Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                ),
              )).toList(),
            ),
          ),

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
                final isToday = dayISO == todayISO;
                final isCurrentMonth = dayDate.month == _currentDate.month;

                final dayTasks = tasksByDate[dayISO] ?? [];
                final projectedTasks = projectedByDate[dayISO] ?? [];

                final timeStr = DateFormat('HH:mm').format(DateTime.now());

                return DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    widget.onMoveTask(details.data, dayISO, timeStr);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return InkWell(
                      onTap: () => widget.onCreateTaskAtDate(dayISO, timeStr),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? (widget.isLight ? Colors.cyan[50] : Colors.cyan[950])
                              : (isCurrentMonth
                                  ? (widget.isLight ? Colors.white : Colors.black)
                                  : (widget.isLight ? const Color(0xFFF9F9FB) : const Color(0xFF09090B))),
                          border: Border.all(color: border, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? Colors.green
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    '${dayDate.day}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? Colors.white
                                          : (isCurrentMonth
                                              ? (widget.isLight ? Colors.black : Colors.white)
                                              : Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Expanded(
                              child: ListView(
                                children: [
                                  ...dayTasks.map((t) {
                                    final isSelected = widget.selectedTaskId == t.id;

                                    return LongPressDraggable<String>(
                                      data: t.id,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: widget.isLight ? Colors.cyan[100] : Colors.cyan[950],
                                            border: Border.all(color: Colors.cyan),
                                          ),
                                          child: Text(
                                            t.raw,
                                            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () => widget.onSelectTask(t),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 2),
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (widget.isLight ? Colors.cyan[100] : Colors.cyan[950])
                                                : (widget.isLight ? Colors.grey[100] : Colors.grey[900]),
                                            border: Border.all(
                                              color: isSelected
                                                  ? (widget.isLight ? Colors.cyan[400]! : Colors.cyan[600]!)
                                                  : border,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () => widget.onToggleTask(t.id),
                                                child: Text(
                                                  t.completed ? '[x]' : '[ ]',
                                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: FormattedText(
                                                  text: t.raw,
                                                  isCompleted: t.completed,
                                                  isLight: widget.isLight,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),

                                  ...projectedTasks.map((projTask) {
                                    if (dayTasks.any((t) => t.id == projTask.id)) {
                                      return const SizedBox.shrink();
                                    }
                                    return InkWell(
                                      onTap: () => widget.onSelectTask(projTask),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 2),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: widget.isLight ? Colors.purple[50]?.withOpacity(0.7) : Colors.purple[950]?.withOpacity(0.4),
                                          border: Border.all(
                                            color: widget.isLight ? Colors.purple[300]! : Colors.purple[800]!,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text('🔄', style: TextStyle(fontSize: 9)),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                projTask.title,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.jetBrainsMono(
                                                  fontSize: 9,
                                                  fontStyle: FontStyle.italic,
                                                  color: widget.isLight ? Colors.purple[900] : Colors.purple[300],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
