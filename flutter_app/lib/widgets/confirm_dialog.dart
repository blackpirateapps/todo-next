import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final bool isLight;

  const ConfirmDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? Colors.white : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[400])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
