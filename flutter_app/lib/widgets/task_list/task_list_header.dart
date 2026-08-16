import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskListHeader extends StatelessWidget {
  final bool isLight;

  const TaskListHeader({super.key, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey[200] : const Color(0xFF18181B),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'St',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              'Pr',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              'Task',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              'Del',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
