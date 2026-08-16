import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final bool isLight;
  final Function(String command) onCommandSubmit;

  const AddTaskDialog({
    super.key,
    required this.isLight,
    required this.onCommandSubmit,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _inputController;
  late final String _todayStr;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submit() {
    final val = _inputController.text.trim();
    if (val.isNotEmpty) {
      final taskCmd = val.startsWith(':add ') ? val : ':add $val';
      widget.onCommandSubmit(taskCmd);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isLight ? Colors.white : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '[CREATE NEW TASK]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Enter task in todo.txt format:',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _inputController,
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '(A) $_todayStr Task description +project @context due:$_todayStr',
                hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600]),
                border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 10),

            // Quick Token Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: Text(
                    '(A)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: bg,
                  side: BorderSide(color: border),
                  onPressed: () {
                    _inputController.text = '(A) ${_inputController.text}';
                  },
                ),
                ActionChip(
                  label: Text(
                    '(B)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: Colors.amber[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: bg,
                  side: BorderSide(color: border),
                  onPressed: () {
                    _inputController.text = '(B) ${_inputController.text}';
                  },
                ),
                ActionChip(
                  label: Text(
                    'due:today',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.purple[300]),
                  ),
                  backgroundColor: bg,
                  side: BorderSide(color: border),
                  onPressed: () {
                    _inputController.text = '${_inputController.text} due:$_todayStr'.trim();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                onPressed: _submit,
                child: Text(
                  'Create Task',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
