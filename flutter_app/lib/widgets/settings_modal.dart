import 'package:flutter/material.dart';
import '../models/template.dart';
import '../theme/app_theme.dart';
import 'formatted_text.dart';
import 'confirm_dialog.dart';

class SettingsModalWidget extends StatefulWidget {
  final List<Template> templates;
  final Function(String templateId) onInstantiateTemplate;
  final Function(Template template) onCreateTemplate;
  final Function(String templateId, Map<String, dynamic> updates)? onUpdateTemplate;
  final Function(String templateId) onDeleteTemplate;
  final AppThemeId currentTheme;
  final Function(AppThemeId theme) onSelectTheme;
  final bool isLight;
  final String? userEmail;
  final String syncStatus;
  final VoidCallback? onForceSync;
  final VoidCallback? onLogout;
  final int initialTabIndex;

  const SettingsModalWidget({
    super.key,
    required this.templates,
    required this.onInstantiateTemplate,
    required this.onCreateTemplate,
    this.onUpdateTemplate,
    required this.onDeleteTemplate,
    required this.currentTheme,
    required this.onSelectTheme,
    required this.isLight,
    this.userEmail,
    this.syncStatus = 'synced',
    this.onForceSync,
    this.onLogout,
    this.initialTabIndex = 0,
  });

  @override
  State<SettingsModalWidget> createState() => _SettingsModalWidgetState();
}

class _SettingsModalWidgetState extends State<SettingsModalWidget> {
  late int _activeTabIndex;
  String _templateSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  void _showNewTemplateDialog() {
    final nameCtrl = TextEditingController();
    final rawCtrl = TextEditingController(text: '(A) Task title +project @context due:{today}');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isLight ? Colors.white : const Color(0xFF18181B),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          '[Create New Template]',
          style: AppTheme.monoStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template Name:', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                style: AppTheme.monoStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'e.g. Weekly Review',
                  hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text('Raw Template String (with tokens):', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: rawCtrl,
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
              Text('Description (optional):', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: descCtrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('[Cancel]', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final raw = rawCtrl.text.trim();
              if (name.isNotEmpty && raw.isNotEmpty) {
                final newTemplate = Template(
                  id: 'tmpl-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  rawTemplate: raw,
                  description: descCtrl.text.trim(),
                  createdAt: DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                  projects: [],
                  contexts: [],
                  subtasks: [],
                );
                widget.onCreateTemplate(newTemplate);
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[800],
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text('[Save Template]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditTemplateDialog(Template tmpl) {
    final nameCtrl = TextEditingController(text: tmpl.name);
    final rawCtrl = TextEditingController(text: tmpl.rawTemplate);
    final descCtrl = TextEditingController(text: tmpl.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isLight ? Colors.white : const Color(0xFF18181B),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          '[Edit Template: ${tmpl.name}]',
          style: AppTheme.monoStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template Name:', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                style: AppTheme.monoStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text('Raw Template String:', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: rawCtrl,
                style: AppTheme.monoStyle(fontSize: 12),
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Text('Description:', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: descCtrl,
                style: AppTheme.monoStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('[Cancel]', style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final raw = rawCtrl.text.trim();
              if (name.isNotEmpty && raw.isNotEmpty && widget.onUpdateTemplate != null) {
                widget.onUpdateTemplate!(tmpl.id, {
                  'name': name,
                  'rawTemplate': raw,
                  'description': descCtrl.text.trim(),
                  'updatedAt': DateTime.now().toIso8601String(),
                });
                Navigator.of(ctx).pop();
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[800],
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text('[Update Template]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Text(
          'VISUAL INTERFACE THEMES',
          style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ...AppTheme.availableThemes.map((theme) {
          final isActive = widget.currentTheme == theme.id;
          return InkWell(
            onTap: () => widget.onSelectTheme(theme.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.card,
                border: Border.all(
                  color: isActive ? theme.accent : theme.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${theme.badgeEmoji} ${theme.name}',
                        style: AppTheme.monoStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.accent,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.bg,
                            border: Border.all(color: theme.accent),
                          ),
                          child: Text(
                            '[ Active ]',
                            style: AppTheme.monoStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.accent,
                            ),
                          ),
                        )
                      else
                        Text(
                          theme.isLight ? 'Light' : 'Dark',
                          style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.description,
                    style: AppTheme.monoStyle(fontSize: 11, color: theme.text.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Palette: ', style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 4),
                      _colorChip(theme.bg, 'Background'),
                      const SizedBox(width: 4),
                      _colorChip(theme.card, 'Surface'),
                      const SizedBox(width: 4),
                      _colorChip(theme.accent, 'Accent'),
                      const SizedBox(width: 4),
                      _colorChip(theme.text, 'Text'),
                      const SizedBox(width: 4),
                      _colorChip(theme.border, 'Border'),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.grey[100] : const Color(0xFF18181B),
            border: Border.all(color: widget.isLight ? Colors.grey[300]! : Colors.grey[800]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM & ACCOUNT DIAGNOSTICS',
                style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _diagRow('User Account:', widget.userEmail ?? 'Guest / Local', Colors.green),
              _diagRow('Sync Status:', widget.syncStatus.toUpperCase(), Colors.amber),
              _diagRow('Database:', 'Turso DB / SQLite', null),
              _diagRow('Format:', 'todo.txt utf-8', null),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (widget.onForceSync != null)
                    OutlinedButton(
                      onPressed: widget.onForceSync,
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text('[ Force Database Sync ]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  if (widget.onLogout != null)
                    OutlinedButton(
                      onPressed: widget.onLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[900]!),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text('[ Logout Session ]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[400])),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _diagRow(String label, String value, Color? valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.monoStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: valColor ?? (widget.isLight ? Colors.black87 : Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorChip(Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final filtered = widget.templates.where((t) {
      if (_templateSearchQuery.isEmpty) return true;
      return t.name.toLowerCase().contains(_templateSearchQuery.toLowerCase()) ||
          t.rawTemplate.toLowerCase().contains(_templateSearchQuery.toLowerCase());
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
                onChanged: (val) => setState(() => _templateSearchQuery = val),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _showNewTemplateDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[800],
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              child: Text('[+ New Template]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                onTap: () => _showEditTemplateDialog(tmpl),
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
                                child: Text('[Use]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            Text('${tmpl.subtasks.length} subtasks configured', style: AppTheme.monoStyle(fontSize: 10, color: Colors.purple[300])),
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

  Widget _buildSyntaxTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _syntaxSection('1. Priority', '(A) High Priority, (B) Medium, (C) Low (e.g. (A) Fix urgent server crash)'),
        _syntaxSection('2. Projects & Contexts', '+project (e.g. +backend, +mobile), @context (e.g. @dev, @home)'),
        _syntaxSection('3. Due Dates & Times', 'due:YYYY-MM-DD (e.g. due:2026-08-15) and time:HH:MM (e.g. time:14:30)'),
        _syntaxSection('4. Task Templates & Dynamic Tokens', 'Use {today}, {due:+3d}, {due:+1w}, {time:HH:MM} inside templates.'),
        _syntaxSection(
          '5. Recurring Tasks Syntax (rec:)',
          '• Relative Recurrence: rec:1d, rec:3d, rec:1w, rec:2w, rec:1m, rec:1y, rec:weekday, rec:mwf\n'
          '• Strict Recurrence: rec:strict:1w or rec:+1w (calculates next due relative to previous due date)\n'
          '• Auto-Spawning: Completing a recurring task automatically logs history and spawns the next occurrence.\n'
          '• Recurrence Commands:\n'
          '  :rec 1w       -> Set recurrence on selected task\n'
          '  :skip         -> Skip occurrence to next cycle\n'
          '  :recurring    -> Filter tasks by active recurrence',
        ),
        _syntaxSection(
          '6. Terminal Commands',
          ':add (A) Title +project @context due:YYYY-MM-DD -> Add task\n'
          ':settings               -> Open Settings Modal\n'
          ':theme                  -> Open Theme Switcher\n'
          ':theme <mocha|gruvbox|paper|dark|light> -> Direct theme change\n'
          ':template               -> Open Templates Manager\n'
          ':use <template-name>    -> Instantiate template by name\n'
          ':template save <name>   -> Save task as template',
        ),
      ],
    );
  }

  Widget _syntaxSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isLight ? Colors.grey[100] : const Color(0xFF141417),
              border: Border.all(color: widget.isLight ? Colors.grey[300]! : Colors.grey[800]!),
            ),
            child: Text(
              content,
              style: AppTheme.monoStyle(fontSize: 11, color: widget.isLight ? Colors.grey[800] : Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isLight ? Colors.white : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 580.0 : (screenWidth * 0.94);
    final dialogHeight = MediaQuery.of(context).size.height * 0.85;

    final tabs = [
      {'title': '[ Themes ]', 'icon': Icons.palette_outlined},
      {'title': '[ Templates ]', 'icon': Icons.auto_awesome_mosaic_outlined},
      {'title': '[ Syntax Guide ]', 'icon': Icons.help_outline},
    ];

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Tab Switcher Bar
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (idx) {
                        final isActive = _activeTabIndex == idx;
                        return InkWell(
                          onTap: () => setState(() => _activeTabIndex = idx),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                                  : Colors.transparent,
                              border: Border.all(color: isActive ? Colors.cyan : border),
                            ),
                            child: Text(
                              tabs[idx]['title'] as String,
                              style: AppTheme.monoStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.cyan : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: border),
            const SizedBox(height: 8),

            // Tab Content
            Expanded(
              child: _activeTabIndex == 0
                  ? _buildThemeTab()
                  : _activeTabIndex == 1
                      ? _buildTemplatesTab()
                      : _buildSyntaxTab(),
            ),
          ],
        ),
      ),
    );
  }
}
