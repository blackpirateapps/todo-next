import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/comment.dart';
import '../../theme/app_theme.dart';

class InspectorCommentsSection extends StatefulWidget {
  final Task task;
  final Function(String taskId, Map<String, dynamic> updates) onUpdateTask;
  final bool isLight;
  final AppThemeId? currentTheme;

  const InspectorCommentsSection({
    super.key,
    required this.task,
    required this.onUpdateTask,
    required this.isLight,
    this.currentTheme,
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
    final theme = AppTheme.getDefinition(widget.currentTheme ?? (widget.isLight ? AppThemeId.light : AppThemeId.mocha));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMENTS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: theme.subtext,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.task.comments.isNotEmpty) ...[
          ...widget.task.comments.map(
            (c) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${c.author} • ${c.timestamp}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.text,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      height: 1.35,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.border, width: 1),
          ),
          child: TextField(
            controller: _commentAuthorController,
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.text),
            decoration: InputDecoration(
              hintText: '@author',
              hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.border, width: 1),
          ),
          child: TextField(
            controller: _commentTextController,
            maxLines: 2,
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.text),
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.subtext.withValues(alpha: 0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _addComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: theme.isLight ? Colors.white : const Color(0xFF11111B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Add Comment',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
