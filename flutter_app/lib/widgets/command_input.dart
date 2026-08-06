import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final VoidCallback onToggleSidebar;
  final VoidCallback onOpenTemplates;
  final VoidCallback onOpenSyntax;
  final Function(String view) onChangeView;
  final String activeView;
  final bool isLight;

  const CommandInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onToggleSidebar,
    required this.onOpenTemplates,
    required this.onOpenSyntax,
    required this.onChangeView,
    required this.activeView,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: onToggleSidebar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),

          Row(
            children: [
              InkWell(
                onTap: () => onChangeView('list'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: activeView == 'list' ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
                  child: Text('[List]', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              InkWell(
                onTap: () => onChangeView('calendar'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: activeView == 'calendar' ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
                  child: Text('[Calendar]', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          InkWell(
            onTap: onOpenTemplates,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(border: Border.all(color: border)),
              child: Text('[Templates]', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan)),
            ),
          ),

          const SizedBox(width: 6),

          InkWell(
            onTap: onOpenSyntax,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(border: Border.all(color: border)),
              child: Text('[?] Syntax', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Row(
              children: [
                Text('>', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Filter... or :add (A) Task... or :use Sprint Release',
                      hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (val) {
                      onSubmit(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
