import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';

class InspectorHeader extends StatelessWidget {
  final Task task;
  final VoidCallback onClose;
  final Function(Task task) onSaveAsTemplate;
  final bool isLight;

  const InspectorHeader({
    super.key,
    required this.task,
    required this.onClose,
    required this.onSaveAsTemplate,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey[200] : const Color(0xFF18181B),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'INSPECTOR',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => onSaveAsTemplate(task),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: border)),
              child: Text(
                '[Save Template]',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: border)),
              child: Text('[← Back]', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
