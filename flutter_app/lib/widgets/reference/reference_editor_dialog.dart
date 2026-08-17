import 'package:flutter/material.dart';
import '../../models/reference.dart';
import '../../theme/app_theme.dart';
import '../../utils/reference_utils.dart';

class ReferenceEditorDialog extends StatefulWidget {
  final Reference? reference;
  final String? initialTitle;
  final String? initialContent;
  final bool isLight;
  final Function(String title, String content, List<String> tags) onSave;

  const ReferenceEditorDialog({
    super.key,
    this.reference,
    this.initialTitle,
    this.initialContent,
    required this.isLight,
    required this.onSave,
  });

  @override
  State<ReferenceEditorDialog> createState() => _ReferenceEditorDialogState();
}

class _ReferenceEditorDialogState extends State<ReferenceEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reference?.title ?? widget.initialTitle ?? '',
    );
    _contentController = TextEditingController(
      text: widget.reference?.content ?? widget.initialContent ?? '',
    );
    _tagInputController = TextEditingController();

    if (widget.reference != null) {
      _tags = List.from(widget.reference!.tags);
    } else if (widget.initialContent != null) {
      _tags = ReferenceUtils.extractTagsFromText('${widget.initialTitle ?? ''} ${widget.initialContent ?? ''}');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final raw = _tagInputController.text.trim();
    if (raw.isEmpty) return;
    final formatted = raw.startsWith('@') || raw.startsWith('+') ? raw : '@$raw';
    if (!_tags.contains(formatted)) {
      setState(() {
        _tags.add(formatted);
      });
    }
    _tagInputController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_tagInputController.text.trim().isNotEmpty) {
      final raw = _tagInputController.text.trim();
      final formatted = raw.startsWith('@') || raw.startsWith('+') ? raw : '@$raw';
      if (!_tags.contains(formatted)) {
        _tags.add(formatted);
      }
    }

    widget.onSave(
      title,
      _contentController.text.trim(),
      _tags,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reference != null;
    final primaryColor = Colors.cyan[700]!;

    return Dialog(
      backgroundColor: widget.isLight ? Colors.white : const Color(0xFF111113),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: widget.isLight ? Colors.grey[400]! : Colors.grey[800]!),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? '[ EDIT REFERENCE ]' : '[ NEW REFERENCE ]',
                      style: AppTheme.monoStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.isLight ? Colors.cyan[800] : Colors.cyan[400],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(
                  color: widget.isLight ? Colors.grey[300] : Colors.grey[800],
                  height: 20,
                ),

                // Title field
                Text(
                  'TITLE *',
                  style: AppTheme.monoStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isLight ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: AppTheme.monoStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'e.g. John (Lead), Home Wi-Fi, Dentist Clinic...',
                    hintStyle: AppTheme.monoStyle(fontSize: 12, color: Colors.grey[500]),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: widget.isLight ? Colors.grey[300]! : Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Content field
                Text(
                  'CONTENT (Arbitrary text, numbers, address, URLs, snippets)',
                  style: AppTheme.monoStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isLight ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  style: AppTheme.monoStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210\nSSID: Fiber_5G, Password: ...\n14 Carter Road, Bandra West',
                    hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500]),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: widget.isLight ? Colors.grey[300]! : Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tags field
                Text(
                  'TAGS (@people, @home, +work)',
                  style: AppTheme.monoStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isLight ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagInputController,
                        style: AppTheme.monoStyle(fontSize: 12),
                        onSubmitted: (_) => _addTag(),
                        decoration: InputDecoration(
                          hintText: 'Type tag and tap Add Tag',
                          hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500]),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: widget.isLight ? Colors.grey[300]! : Colors.grey[700]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onPressed: _addTag,
                      child: Text('+ Add', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      final isProject = tag.startsWith('+');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isProject
                              ? (widget.isLight ? Colors.cyan[50] : const Color(0xFF083344).withValues(alpha: 0.4))
                              : (widget.isLight ? Colors.green[50] : const Color(0xFF052E16).withValues(alpha: 0.4)),
                          border: Border.all(
                            color: isProject
                                ? (widget.isLight ? Colors.cyan[300]! : Colors.cyan[800]!)
                                : (widget.isLight ? Colors.green[300]! : Colors.green[800]!),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: AppTheme.monoStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isProject
                                    ? (widget.isLight ? Colors.cyan[900] : Colors.cyan[300])
                                    : (widget.isLight ? Colors.green[900] : Colors.green[300]),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _removeTag(tag),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: widget.isLight ? Colors.grey[700] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                Divider(color: widget.isLight ? Colors.grey[300] : Colors.grey[800], height: 1),
                const SizedBox(height: 12),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: AppTheme.monoStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        isEditing ? 'Save Changes' : 'Create Reference',
                        style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
