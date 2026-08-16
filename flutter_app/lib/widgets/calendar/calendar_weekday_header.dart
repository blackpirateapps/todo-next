import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/date_utils.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  final bool isLight;

  const CalendarWeekdayHeader({super.key, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey[200] : const Color(0xFF18181B),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: weekdayNames
            .map((d) => Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
