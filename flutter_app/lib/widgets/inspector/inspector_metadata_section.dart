import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';

class InspectorMetadataSection extends StatelessWidget {
  final Task task;

  const InspectorMetadataSection({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID: ${task.id}  Pri: ${task.priority ?? '-'}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          'Created: ${task.creationDate}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          'Due Date: ${task.dueDate ?? 'No due date'} ${task.dueTime ?? ''}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          'Status: ${task.completed ? 'Completed' : 'Open'}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: task.completed ? Colors.green : Colors.amber,
          ),
        ),
      ],
    );
  }
}
