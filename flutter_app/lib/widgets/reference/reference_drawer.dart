import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/reference.dart';
import '../../theme/app_theme.dart';
import '../../utils/reference_utils.dart';

class ReferenceDrawerWidget extends StatefulWidget {
  final Reference? reference;
  final bool isCreating;
  final String? initialTitle;
  final String? initialContent;
  final bool isLight;
  final VoidCallback onClose;
  final Function(Reference ref)? onEdit;
  final Function(String title, String content, List<String> tags)? onSaveNew;
  final Function(String id, Map<String, dynamic> updates)? onSaveEdit;
  final VoidCallback? onCancelCreate;
  final Function(String id, bool archive) onArchive;
  final Function(Reference ref) onDelete;
  final bool showIcons;

  const ReferenceDrawerWidget({
    super.key,
    required this.reference,
    this.isCreating = false,
    this.initialTitle,
    this.initialContent,
    required this.isLight,
    required this.onClose,
    this.onEdit,
    this.onSaveNew,
    this.onSaveEdit,
    this.onCancelCreate,
    required this.onArchive,
    required this.onDelete,
    this.showIcons = false,
  });

  @override
  State<ReferenceDrawerWidget> createState() => _ReferenceDrawerWidgetState();
}

class _ReferenceDrawerWidgetState extends State<ReferenceDrawerWidget> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? widget.reference?.title ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? widget.reference?.content ?? '');
    _tagController = TextEditingController();
    _tags = widget.reference != null ? List<String>.from(widget.reference!.tags) : [];
  }

  @override
  void didUpdateWidget(covariant ReferenceDrawerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference || oldWidget.isCreating != widget.isCreating) {
      _titleController.text = widget.initialTitle ?? widget.reference?.title ?? '';
      _contentController.text = widget.initialContent ?? widget.reference?.content ?? '';
      _tags = widget.reference != null ? List<String>.from(widget.reference!.tags) : [];
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchAction(BuildContext context, String urlStr) async {
    try {
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: urlStr));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied "$urlStr" to clipboard', style: AppTheme.monoStyle(fontSize: 11)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: urlStr));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied "$urlStr" to clipboard', style: AppTheme.monoStyle(fontSize: 11)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _addTag() {
    final text = _tagController.text.trim();
    if (text.isNotEmpty) {
      final formatted = (text.startsWith('+') || text.startsWith('@')) ? text : '#$text';
      if (!_tags.contains(formatted)) {
        setState(() {
          _tags.add(formatted);
          _tagController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.isLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 400 ? 340.0 : (screenWidth * 0.92);

    // 1. EMPTY STATE
    if (widget.reference == null && !widget.isCreating) {
      return Container(
        width: drawerWidth,
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFF9F9FB) : const Color(0xFF09090B),
          border: Border(left: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
        ),
        child: Center(
          child: Text(
            '[ NO REFERENCE SELECTED ]',
            style: AppTheme.monoStyle(fontSize: 11, color: isLight ? Colors.grey[500] : Colors.grey[600]),
          ),
        ),
      );
    }

    // 2. INLINE CREATION OR EDITING FORM IN DRAWER
    if (widget.isCreating || _isEditing) {
      final isNew = widget.isCreating;
      final liveSmartActions = ReferenceUtils.detectSmartActions(_contentController.text);

      return Container(
        width: drawerWidth,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF09090B),
          border: Border(left: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLight ? Colors.grey[100] : const Color(0xFF111113),
                border: Border(bottom: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isNew
                          ? (isLight ? Colors.green[100] : const Color(0xFF052E16).withValues(alpha: 0.5))
                          : (isLight ? Colors.cyan[100] : const Color(0xFF083344).withValues(alpha: 0.5)),
                      border: Border.all(
                        color: isNew
                            ? (isLight ? Colors.green[400]! : Colors.green[800]!)
                            : (isLight ? Colors.cyan[400]! : Colors.cyan[800]!),
                      ),
                    ),
                    child: Text(
                      isNew ? '➕ NEW REFERENCE' : '✏️ EDIT REFERENCE',
                      style: AppTheme.monoStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNew
                            ? (isLight ? Colors.green[900] : Colors.green[300])
                            : (isLight ? Colors.cyan[900] : Colors.cyan[300]),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (isNew) {
                        if (widget.onCancelCreate != null) widget.onCancelCreate!();
                      } else {
                        setState(() => _isEditing = false);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Form Inputs
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Text(
                    'TITLE',
                    style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleController,
                    style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'e.g. Server IP, Wi-Fi Password',
                      hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500]),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey[700]!)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'CONTENT / DETAILS',
                    style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contentController,
                    maxLines: 6,
                    onChanged: (_) => setState(() {}),
                    style: AppTheme.monoStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Enter phone numbers, links, credentials, addresses, or notes...',
                      hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500]),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey[700]!)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live smart action preview
                  if (liveSmartActions.isNotEmpty) ...[
                    Text(
                      'SMART ACTIONS DETECTED',
                      style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.cyan[400]),
                    ),
                    const SizedBox(height: 4),
                    ...liveSmartActions.map((act) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLight ? Colors.cyan[50] : const Color(0xFF083344).withValues(alpha: 0.3),
                            border: Border.all(color: isLight ? Colors.cyan[200]! : Colors.cyan[800]!),
                          ),
                          child: Row(
                            children: [
                              Text(act.type.name.toUpperCase(), style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.cyan[300])),
                              const SizedBox(width: 6),
                              Expanded(child: Text(act.value, style: AppTheme.monoStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Tags
                  Text(
                    'TAGS',
                    style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _tags.map((t) => Chip(
                          label: Text(t, style: AppTheme.monoStyle(fontSize: 10)),
                          onDeleted: () => setState(() => _tags.remove(t)),
                          deleteIconColor: Colors.red[300],
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        )).toList(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          style: AppTheme.monoStyle(fontSize: 11),
                          decoration: InputDecoration(
                            hintText: '+project or @context',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey[700]!)),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        onPressed: _addTag,
                        child: Text('+ Add', style: AppTheme.monoStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLight ? Colors.grey[50] : const Color(0xFF111113),
                border: Border(top: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      if (isNew) {
                        if (widget.onCancelCreate != null) widget.onCancelCreate!();
                      } else {
                        setState(() => _isEditing = false);
                      }
                    },
                    child: Text('Cancel', style: AppTheme.monoStyle(fontSize: 10)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNew ? Colors.green[700] : Colors.cyan[700],
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;
                      final content = _contentController.text.trim();

                      if (isNew) {
                        if (widget.onSaveNew != null) {
                          widget.onSaveNew!(title, content, _tags);
                        }
                      } else if (widget.reference != null) {
                        if (widget.onSaveEdit != null) {
                          widget.onSaveEdit!(widget.reference!.id, {
                            'title': title,
                            'content': content,
                            'tags': _tags,
                          });
                        }
                        setState(() => _isEditing = false);
                      }
                    },
                    child: Text(
                      isNew ? 'Create Reference' : 'Save Changes',
                      style: AppTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. INLINE VIEW MODE IN DRAWER
    final ref = widget.reference!;
    final smartActions = ReferenceUtils.detectSmartActions(ref.content);

    String formattedCreated = ref.createdAt;
    String formattedUpdated = ref.updatedAt;
    try {
      final cDt = DateTime.parse(ref.createdAt);
      formattedCreated = '${cDt.year}-${cDt.month.toString().padLeft(2, '0')}-${cDt.day.toString().padLeft(2, '0')} ${cDt.hour.toString().padLeft(2, '0')}:${cDt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}
    try {
      final uDt = DateTime.parse(ref.updatedAt);
      formattedUpdated = '${uDt.year}-${uDt.month.toString().padLeft(2, '0')}-${uDt.day.toString().padLeft(2, '0')} ${uDt.hour.toString().padLeft(2, '0')}:${uDt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF09090B),
        border: Border(left: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLight ? Colors.grey[100] : const Color(0xFF111113),
              border: Border(bottom: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.cyan[100] : const Color(0xFF083344).withValues(alpha: 0.5),
                        border: Border.all(color: isLight ? Colors.cyan[400]! : Colors.cyan[800]!),
                      ),
                      child: Text(
                        'REFERENCE',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.cyan[900] : Colors.cyan[300],
                        ),
                      ),
                    ),
                    if (ref.archived) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.amber[100] : const Color(0xFF451A03).withValues(alpha: 0.5),
                          border: Border.all(color: isLight ? Colors.amber[400]! : Colors.amber[800]!),
                        ),
                        child: Text(
                          'ARCHIVED',
                          style: AppTheme.monoStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isLight ? Colors.amber[900] : Colors.amber[300],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Title
                Text(
                  'TITLE',
                  style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? Colors.grey[500] : Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  ref.title,
                  style: AppTheme.monoStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.cyan[900] : Colors.cyan[300],
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTENT',
                      style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? Colors.grey[500] : Colors.grey[500]),
                    ),
                    if (ref.content.isNotEmpty)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: ref.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied content to clipboard', style: AppTheme.monoStyle(fontSize: 11)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Text(
                          '[Copy text]',
                          style: AppTheme.monoStyle(fontSize: 10, color: Colors.cyan[700], fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey[50] : const Color(0xFF111113),
                    border: Border.all(color: isLight ? Colors.grey[200]! : Colors.grey[800]!),
                  ),
                  child: Text(
                    ref.content.isNotEmpty ? ref.content : 'No content provided.',
                    style: AppTheme.monoStyle(
                      fontSize: 12,
                      color: ref.content.isNotEmpty
                          ? (isLight ? Colors.grey[900] : Colors.grey[200])
                          : Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Smart Actions Section
                if (smartActions.isNotEmpty) ...[
                  Text(
                    'SMART ACTIONS DETECTED',
                    style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? Colors.grey[500] : Colors.grey[500]),
                  ),
                  const SizedBox(height: 6),
                  ...smartActions.map((action) {
                    IconData actionIcon = Icons.link;
                    if (action.type == SmartActionType.phone) actionIcon = Icons.phone;
                    if (action.type == SmartActionType.email) actionIcon = Icons.email;
                    if (action.type == SmartActionType.address) actionIcon = Icons.map;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.grey[100] : Colors.grey[900],
                        border: Border.all(color: isLight ? Colors.grey[300]! : Colors.grey[800]!),
                      ),
                      child: Row(
                        children: [
                          Icon(actionIcon, size: 14, color: isLight ? Colors.cyan[800] : Colors.cyan[400]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              action.value,
                              style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: action.value));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied "${action.value}"', style: AppTheme.monoStyle(fontSize: 11)),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.copy, size: 13, color: isLight ? Colors.grey[600] : Colors.grey[400]),
                            ),
                          ),
                          const SizedBox(width: 2),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            onPressed: () => _launchAction(context, action.actionUrl),
                            child: Text(
                              action.type == SmartActionType.phone
                                  ? 'Call'
                                  : action.type == SmartActionType.email
                                      ? 'Email'
                                      : action.type == SmartActionType.address
                                          ? 'Map'
                                          : 'Open',
                              style: AppTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Tags Section
                if (ref.tags.isNotEmpty) ...[
                  Text(
                    'TAGS',
                    style: AppTheme.monoStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLight ? Colors.grey[500] : Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: ref.tags.map((t) {
                      final isProj = t.startsWith('+');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isProj
                              ? (isLight ? Colors.cyan[50] : const Color(0xFF083344).withValues(alpha: 0.4))
                              : (isLight ? Colors.green[50] : const Color(0xFF052E16).withValues(alpha: 0.4)),
                          border: Border.all(
                            color: isProj
                                ? (isLight ? Colors.cyan[300]! : Colors.cyan[800]!)
                                : (isLight ? Colors.green[300]! : Colors.green[800]!),
                          ),
                        ),
                        child: Text(
                          t,
                          style: AppTheme.monoStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isProj
                                ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                                : (isLight ? Colors.green[900] : Colors.green[300]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Metadata Section
                Divider(color: isLight ? Colors.grey[200] : Colors.grey[800], height: 16),
                Text('Created: $formattedCreated', style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text('Updated: $formattedUpdated', style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLight ? Colors.grey[50] : const Color(0xFF111113),
              border: Border(top: BorderSide(color: isLight ? Colors.grey[300]! : Colors.grey[800]!)),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 11),
                  label: Text('Copy', style: AppTheme.monoStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    final formatted = ReferenceUtils.formatReferenceForCopy(ref);
                    Clipboard.setData(ClipboardData(text: formatted));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied reference to clipboard', style: AppTheme.monoStyle(fontSize: 11)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 11),
                  label: Text('Edit', style: AppTheme.monoStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    if (widget.onEdit != null) {
                      widget.onEdit!(ref);
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => widget.onArchive(ref.id, !ref.archived),
                  child: Text(
                    ref.archived ? 'Restore' : 'Archive',
                    style: AppTheme.monoStyle(fontSize: 10),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: isLight ? Colors.red[200]! : Colors.red[900]!),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => widget.onDelete(ref),
                  child: Text('Delete', style: AppTheme.monoStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
