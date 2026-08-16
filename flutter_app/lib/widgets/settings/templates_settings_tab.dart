import 'package:flutter/material.dart';
import '../../models/template.dart';
import '../../theme/app_theme.dart';
import '../formatted_text.dart';
import '../confirm_dialog.dart';
import 'template_form_dialog.dart';

class TemplatesSettingsTab extends StatefulWidget {
  final List<Template> templates;
  final Function(String templateId) onInstantiateTemplate;
  final Function(Template template) onCreateTemplate;
  final Function(String templateId, Map<String, dynamic> updates)? onUpdateTemplate;
  final Function(String templateId) onDeleteTemplate;
  final bool isLight;

  const TemplatesSettingsTab({
    super.key,
    required this.templates,
    required this.onInstantiateTemplate,
    required this.onCreateTemplate,
    this.onUpdateTemplate,
    required this.onDeleteTemplate,
    required this.isLight,
  });

  @override
  State<TemplatesSettingsTab> createState() => _TemplatesSettingsTabState();
}

class _TemplatesSettingsTabState extends State<TemplatesSettingsTab> {
  String _searchQuery = '';

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => TemplateFormDialog(
        isLight: widget.isLight,
        onCreate: widget.onCreateTemplate,
      ),
    );
  }

  void _openEditDialog(Template tmpl) {
    showDialog(
      context: context,
      builder: (ctx) => TemplateFormDialog(
        template: tmpl,
        isLight: widget.isLight,
        onUpdate: (id, updates) {
          if (widget.onUpdateTemplate != null) {
            widget.onUpdateTemplate!(id, updates);
            setState(() {});
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.templates.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.rawTemplate.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                style: AppTheme.monoStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _openCreateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[800],
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              child: Text(
                '[+ New Template]',
                style: AppTheme.monoStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No task templates found.',
                    style: AppTheme.monoStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final tmpl = filtered[idx];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.isLight ? Colors.grey[300]! : Colors.grey[800]!),
                        color: widget.isLight ? Colors.grey[50] : const Color(0xFF141417),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tmpl.name,
                                  style: AppTheme.monoStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyan),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => _openEditDialog(tmpl),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('[Edit]', style: AppTheme.monoStyle(fontSize: 11, color: Colors.amber)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (c) => ConfirmDialogWidget(
                                      title: 'Delete Template',
                                      message: 'Are you sure you want to delete "${tmpl.name}"?',
                                      onConfirm: () {
                                        widget.onDeleteTemplate(tmpl.id);
                                        setState(() {});
                                      },
                                      isLight: widget.isLight,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('[Del]', style: AppTheme.monoStyle(fontSize: 11, color: Colors.red)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () {
                                  widget.onInstantiateTemplate(tmpl.id);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[800],
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: Text(
                                  '[Use]',
                                  style: AppTheme.monoStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          FormattedText(text: tmpl.rawTemplate, isLight: widget.isLight, fontSize: 12),
                          if (tmpl.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(tmpl.description, style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                          if (tmpl.subtasks.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${tmpl.subtasks.length} subtasks configured',
                              style: AppTheme.monoStyle(fontSize: 10, color: Colors.purple[300]),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
