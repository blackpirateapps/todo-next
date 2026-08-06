import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBarWidget extends StatelessWidget {
  final int filteredCount;
  final int totalCount;
  final String activeFilter;
  final String syncStatus; // 'synced' | 'syncing' | 'offline'
  final bool isLight;
  final VoidCallback onToggleTheme;
  final VoidCallback onForceSync;

  const StatusBarWidget({
    super.key,
    required this.filteredCount,
    required this.totalCount,
    required this.activeFilter,
    required this.syncStatus,
    required this.isLight,
    required this.onToggleTheme,
    required this.onForceSync,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    String syncText = '[Synced ✓]';
    Color syncBg = Colors.green[900]!;
    if (syncStatus == 'syncing') {
      syncText = '[Syncing...]';
      syncBg = Colors.amber[900]!;
    } else if (syncStatus == 'offline') {
      syncText = '[Offline]';
      syncBg = Colors.grey[800]!;
    }

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

          InkWell(
            onTap: onForceSync,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: syncBg,
              child: Text(syncText, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
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
