import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/date_utils.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentDate;
  final String dateField; // 'due' | 'creation'
  final String viewMode; // 'month' | 'week'
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final Function(String) onSelectDateField;
  final Function(String) onSelectViewMode;
  final bool isLight;

  const CalendarHeader({
    super.key,
    required this.currentDate,
    required this.dateField,
    required this.viewMode,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onSelectDateField,
    required this.onSelectViewMode,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final monthName = monthNames[currentDate.month - 1];
    final year = currentDate.year;

    return Container(
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
                  onTap: onPrev,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: border)),
                    child: Text('[<]', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                  ),
                ),
                InkWell(
                  onTap: onToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: border)),
                    child: Text(
                      'Today',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onNext,
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
                  onTap: () => onSelectDateField('due'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: dateField == 'due'
                        ? (isLight ? Colors.purple[200] : Colors.purple[950])
                        : Colors.transparent,
                    child: Text(
                      'Due Date',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: dateField == 'due' ? FontWeight.bold : FontWeight.normal,
                        color: dateField == 'due'
                            ? (isLight ? Colors.purple[900] : Colors.purple[300])
                            : null,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onSelectDateField('creation'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: dateField == 'creation'
                        ? (isLight ? Colors.blue[200] : Colors.blue[950])
                        : Colors.transparent,
                    child: Text(
                      'Created Date',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: dateField == 'creation' ? FontWeight.bold : FontWeight.normal,
                        color: dateField == 'creation'
                            ? (isLight ? Colors.blue[900] : Colors.blue[300])
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
                  onTap: () => onSelectViewMode('month'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: viewMode == 'month'
                        ? (isLight ? Colors.grey[300] : Colors.grey[800])
                        : Colors.transparent,
                    child: Text(
                      'Month',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onSelectViewMode('week'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: viewMode == 'week'
                        ? (isLight ? Colors.grey[300] : Colors.grey[800])
                        : Colors.transparent,
                    child: Text(
                      'Week',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
