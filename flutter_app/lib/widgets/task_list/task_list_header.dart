import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskListHeader extends StatelessWidget {
  final bool isLight;
  final bool showIcons;

  const TaskListHeader({
    super.key,
    required this.isLight,
    this.showIcons = false,
  });

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
            child: showIcons
                ? Icon(Icons.check_box_outlined, size: 14, color: Colors.grey[500])
                : Text(
                    'St',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
                  ),
          ),
          SizedBox(
            width: 32,
            child: showIcons
                ? Icon(Icons.flag_outlined, size: 14, color: Colors.grey[500])
                : Text(
                    'Pr',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
                  ),
          ),
          Expanded(
            child: Row(
              children: [
                if (showIcons) ...[
                  Icon(Icons.description_outlined, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                ],
                Text(
                  'Task',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: showIcons
                ? Icon(Icons.delete_outline, size: 14, color: Colors.grey[500])
                : Text(
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
