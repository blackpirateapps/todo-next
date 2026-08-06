import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBarWidget extends StatelessWidget {
  final int filteredCount;
  final int totalCount;
  final String activeFilter;
  final bool isLight;
  final VoidCallback onToggleTheme;

  const StatusBarWidget({
    super.key,
    required this.filteredCount,
    required this.totalCount,
    required this.activeFilter,
    required this.isLight,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: Colors.blue[900],
            child: Text('NORMAL', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Text('$filteredCount/$totalCount items', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey[400])),
          if (activeFilter.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text('[$activeFilter]', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.cyan, fontWeight: FontWeight.bold)),
          ],

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: Colors.green[900],
            child: Text('[Synced ✓]', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 8),

          InkWell(
            onTap: onToggleTheme,
            child: Text(isLight ? '[Dark]' : '[Light]', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),

          Text('todo.txt utf-8', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
