import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyntaxGuideModalWidget extends StatelessWidget {
  final bool isLight;

  const SyntaxGuideModalWidget({super.key, required this.isLight});

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? Colors.white : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: 550,
        height: 520,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('[todo.txt Syntax & Command Guide]', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _section('1. Priority', '(A) High Priority, (B) Medium, (C) Low'),
                  _section('2. Projects & Contexts', '+project (e.g. +backend), @context (e.g. @dev)'),
                  _section('3. Due Dates & Times', 'due:YYYY-MM-DD (due:2026-08-15) and time:HH:MM (time:14:30)'),
                  _section('4. Task Templates & Tokens', 'Use {today}, {due:+3d}, {due:+1w}, {time:HH:MM} inside templates.'),
                  _section(
                    '5. Recurring Tasks Syntax (rec:)',
                    '• Relative Recurrence: rec:1d, rec:3d, rec:1w, rec:2w, rec:1m, rec:1y, rec:weekday, rec:mwf\n'
                    '• Strict Recurrence: rec:strict:1w or rec:+1w (calculates due dates relative to original due date)\n'
                    '• Auto-Spawning: Completing a recurring task logs history and spawns the next occurrence with uncompleted subtasks.\n'
                    '• Commands:\n'
                    '  :rec 1w  -> set recurrence rule on selected task\n'
                    '  :skip    -> advance due date to next cycle\n'
                    '  :recurring -> filter by active recurring tasks',
                  ),
                  _section(
                    '6. Terminal Commands',
                    ':add (A) Task title +project @context due:YYYY-MM-DD\n'
                    ':template -> open template gallery\n'
                    ':use <name> -> instantiate template\n'
                    ':template save <name> -> save task as template',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan)),
          const SizedBox(height: 2),
          Text(body, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
