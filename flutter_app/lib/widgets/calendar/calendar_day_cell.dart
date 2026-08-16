import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../utils/date_utils.dart';
import '../formatted_text.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime dayDate;
  final DateTime currentDate;
  final List<Task> dayTasks;
  final List<Task> projectedTasks;
  final String? selectedTaskId;
  final Function(Task) onSelectTask;
  final Function(String) onToggleTask;
  final Function(String taskId, String targetDate, String? targetTime) onMoveTask;
  final Function(String dateISO, String? timeStr) onCreateTaskAtDate;
  final bool isLight;

  const CalendarDayCell({
    super.key,
    required this.dayDate,
    required this.currentDate,
    required this.dayTasks,
    required this.projectedTasks,
    this.selectedTaskId,
    required this.onSelectTask,
    required this.onToggleTask,
    required this.onMoveTask,
    required this.onCreateTaskAtDate,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final todayISO = formatDateISO(DateTime.now());
    final dayISO = formatDateISO(dayDate);
    final isToday = dayISO == todayISO;
    final isCurrentMonth = dayDate.month == currentDate.month;
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final timeStr = DateFormat('HH:mm').format(DateTime.now());

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        onMoveTask(details.data, dayISO, timeStr);
      },
      builder: (context, candidateData, rejectedData) {
        return InkWell(
          onTap: () => onCreateTaskAtDate(dayISO, timeStr),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? (isLight ? Colors.cyan[50] : Colors.cyan[950])
                  : (isCurrentMonth
                      ? (isLight ? Colors.white : Colors.black)
                      : (isLight ? const Color(0xFFF9F9FB) : const Color(0xFF09090B))),
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
                        color: isToday ? Colors.green : Colors.transparent,
                      ),
                      child: Text(
                        '${dayDate.day}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.white
                              : (isCurrentMonth
                                  ? (isLight ? Colors.black : Colors.white)
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
                        final isSelected = selectedTaskId == t.id;

                        return LongPressDraggable<String>(
                          data: t.id,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isLight ? Colors.cyan[100] : Colors.cyan[950],
                                border: Border.all(color: Colors.cyan),
                              ),
                              child: Text(
                                t.raw,
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white),
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => onSelectTask(t),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                                    : (isLight ? Colors.grey[100] : Colors.grey[900]),
                                border: Border.all(
                                  color: isSelected
                                      ? (isLight ? Colors.cyan[400]! : Colors.cyan[600]!)
                                      : border,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => onToggleTask(t.id),
                                    child: Text(
                                      t.completed ? '[x]' : '[ ]',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: FormattedText(
                                      text: t.raw,
                                      isCompleted: t.completed,
                                      isLight: isLight,
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
                          onTap: () => onSelectTask(projTask),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.purple[50]?.withAlpha(180)
                                  : Colors.purple[950]?.withAlpha(100),
                              border: Border.all(
                                color: isLight ? Colors.purple[300]! : Colors.purple[800]!,
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
                                      color: isLight ? Colors.purple[900] : Colors.purple[300],
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
  }
}
