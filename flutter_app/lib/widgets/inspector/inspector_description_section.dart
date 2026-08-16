import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task.dart';

class InspectorDescriptionSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;

  const InspectorDescriptionSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
  });

  @override
  State<InspectorDescriptionSection> createState() => _InspectorDescriptionSectionState();
}

class _InspectorDescriptionSectionState extends State<InspectorDescriptionSection> {
  bool _isEditingDescription = false;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.task.description);
  }

  @override
  void didUpdateWidget(covariant InspectorDescriptionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || oldWidget.task.description != widget.task.description) {
      _descController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditingDescription) {
      widget.onUpdateTask(widget.task.id, {'description': _descController.text.trim()});
    }
    setState(() => _isEditingDescription = !_isEditingDescription);
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'DESCRIPTION',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: _toggleEdit,
              child: Text(
                _isEditingDescription ? '[Save]' : '[Edit]',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.cyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_isEditingDescription)
          TextField(
            controller: _descController,
            maxLines: 4,
            style: GoogleFonts.jetBrainsMono(fontSize: 12),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(color: border)),
            ),
          )
        else
          Text(
            widget.task.description.isEmpty ? 'No description set.' : widget.task.description,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: widget.task.description.isEmpty ? Colors.grey[600] : null,
            ),
          ),
      ],
    );
  }
}
