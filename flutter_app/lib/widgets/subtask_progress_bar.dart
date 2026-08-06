import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subtask.dart';

class SubtaskProgressBar extends StatelessWidget {
  final List<Subtask> subtasks;
  final bool isLight;
  final bool compact;
  final bool showText;

  const SubtaskProgressBar({
    super.key,
    required this.subtasks,
    required this.isLight,
    this.compact = false,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) return const SizedBox.shrink();

    final completedCount = subtasks.where((s) => s.completed).length;
    final totalCount = subtasks.length;
    final double percent = totalCount > 0 ? (completedCount / totalCount) : 0;
    final int percentInt = (percent * 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 40 : 80,
          height: compact ? 6 : 8,
          decoration: BoxDecoration(
            color: isLight ? Colors.grey[300] : Colors.grey[800],
            borderRadius: BorderRadius.zero,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              color: percent == 1.0
                  ? Colors.green
                  : (isLight ? Colors.cyan[700] : Colors.cyan[400]),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 6),
          Text(
            '[$completedCount/$totalCount] $percentInt%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isLight ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ],
    );
  }
}
