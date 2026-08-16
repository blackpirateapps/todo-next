import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/comment.dart';

class InspectorCommentsSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;

  const InspectorCommentsSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
  });

  @override
  State<InspectorCommentsSection> createState() => _InspectorCommentsSectionState();
}

class _InspectorCommentsSectionState extends State<InspectorCommentsSection> {
  late final TextEditingController _commentAuthorController;
  late final TextEditingController _commentTextController;

  @override
  void initState() {
    super.initState();
    _commentAuthorController = TextEditingController(text: 'user');
    _commentTextController = TextEditingController();
  }

  @override
  void dispose() {
    _commentAuthorController.dispose();
    _commentTextController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentTextController.text.trim();
    final author = _commentAuthorController.text.trim();
    if (text.isEmpty) return;

    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final newComment = Comment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task.id,
      author: author.isEmpty ? 'user' : author,
      timestamp: nowStr,
      text: text,
    );

    final updated = [...widget.task.comments, newComment];
    widget.onUpdateTask(widget.task.id, {
      'comments': updated.map((c) => c.toJson()).toList(),
    });

    _commentTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMENTS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        ...widget.task.comments.map(
          (c) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(border: Border.all(color: border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${c.author} • ${c.timestamp}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.cyan),
                ),
                const SizedBox(height: 2),
                Text(c.text, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _commentAuthorController,
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
          decoration: const InputDecoration(hintText: '@author', isDense: true),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _commentTextController,
          maxLines: 2,
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
          decoration: const InputDecoration(hintText: 'Write a comment...', isDense: true),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _addComment,
            child: const Text('Comment'),
          ),
        ),
      ],
    );
  }
}
