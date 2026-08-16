import 'package:flutter/material.dart';
import '../../models/template.dart';
import '../../theme/app_theme.dart';

class TemplateFormDialog extends StatefulWidget {
  final Template? template;
  final bool isLight;
  final Function(Template template)? onCreate;
  final Function(String templateId, Map<String, dynamic> updates)? onUpdate;

  const TemplateFormDialog({
    super.key,
    this.template,
    required this.isLight,
    this.onCreate,
    this.onUpdate,
  });

  @override
  State<TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<TemplateFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rawCtrl;
  late final TextEditingController _descCtrl;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.template?.name ?? '');
    _rawCtrl = TextEditingController(
      text: widget.template?.rawTemplate ?? '(A) Task title +project @context due:{today}',
    );
    _descCtrl = TextEditingController(text: widget.template?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rawCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final raw = _rawCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (name.isEmpty || raw.isEmpty) return;

    if (_isEditing) {
      if (widget.onUpdate != null) {
        widget.onUpdate!(widget.template!.id, {
          'name': name,
          'rawTemplate': raw,
          'description': desc,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } else {
      if (widget.onCreate != null) {
        final newTemplate = Template(
          id: 'tmpl-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          rawTemplate: raw,
          description: desc,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          projects: [],
          contexts: [],
          subtasks: [],
        );
        widget.onCreate!(newTemplate);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? '[Edit Template: ${widget.template!.name}]'
        : '[Create New Template]';
    final actionText = _isEditing ? '[Update Template]' : '[Save Template]';

    return AlertDialog(
      backgroundColor: widget.isLight ? Colors.white : const Color(0xFF18181B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text(
        title,
        style: AppTheme.monoStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Template Name:', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(
              controller: _nameCtrl,
              style: AppTheme.monoStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'e.g. Weekly Review',
                hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isEditing ? 'Raw Template String:' : 'Raw Template String (with tokens):',
              style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _rawCtrl,
              style: AppTheme.monoStyle(fontSize: 12),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '(A) Review +weekly @desk due:{today}',
                hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isEditing ? 'Description:' : 'Description (optional):',
              style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _descCtrl,
              style: AppTheme.monoStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Notes or instructions...',
                hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('[Cancel]', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[800],
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(
            actionText,
            style: AppTheme.monoStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
