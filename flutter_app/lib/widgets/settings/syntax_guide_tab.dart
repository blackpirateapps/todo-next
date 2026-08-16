import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SyntaxGuideTab extends StatelessWidget {
  final bool isLight;

  const SyntaxGuideTab({super.key, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _syntaxSection(
          '1. Priority',
          '(A) High Priority, (B) Medium, (C) Low (e.g. (A) Fix urgent server crash)',
        ),
        _syntaxSection(
          '2. Projects & Contexts',
          '+project (e.g. +backend, +mobile), @context (e.g. @dev, @home)',
        ),
        _syntaxSection(
          '3. Due Dates & Times',
          'due:YYYY-MM-DD (e.g. due:2026-08-15) and time:HH:MM (e.g. time:14:30)',
        ),
        _syntaxSection(
          '4. Task Templates & Dynamic Tokens',
          'Use {today}, {due:+3d}, {due:+1w}, {time:HH:MM} inside templates.',
        ),
        _syntaxSection(
          '5. Recurring Tasks Syntax (rec:)',
          '• Relative Recurrence: rec:1d, rec:3d, rec:1w, rec:2w, rec:1m, rec:1y, rec:weekday, rec:mwf\n'
          '• Strict Recurrence: rec:strict:1w or rec:+1w (calculates next due relative to previous due date)\n'
          '• Auto-Spawning: Completing a recurring task automatically logs history and spawns the next occurrence.\n'
          '• Recurrence Commands:\n'
          '  :rec 1w       -> Set recurrence on selected task\n'
          '  :skip         -> Skip occurrence to next cycle\n'
          '  :recurring    -> Filter tasks by active recurrence',
        ),
        _syntaxSection(
          '6. Terminal Commands',
          ':add (A) Title +project @context due:YYYY-MM-DD -> Add task\n'
          ':settings               -> Open Settings Modal\n'
          ':theme                  -> Open Theme Switcher\n'
          ':theme <mocha|gruvbox|paper|dark|light> -> Direct theme change\n'
          ':template               -> Open Templates Manager\n'
          ':use <template-name>    -> Instantiate template by name\n'
          ':template save <name>   -> Save task as template',
        ),
      ],
    );
  }

  Widget _syntaxSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLight ? Colors.grey[100] : const Color(0xFF141417),
              border: Border.all(color: isLight ? Colors.grey[300]! : Colors.grey[800]!),
            ),
            child: Text(
              content,
              style: AppTheme.monoStyle(fontSize: 11, color: isLight ? Colors.grey[800] : Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }
}
