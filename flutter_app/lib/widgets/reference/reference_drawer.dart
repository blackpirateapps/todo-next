import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/reference.dart';
import '../../theme/app_theme.dart';
import '../../utils/reference_utils.dart';

class ReferenceDrawerWidget extends StatelessWidget {
  final Reference? reference;
  final bool isLight;
  final VoidCallback onClose;
  final Function(Reference ref) onEdit;
  final Function(String id, bool archive) onArchive;
  final Function(Reference ref) onDelete;

  const ReferenceDrawerWidget({
    super.key,
    required this.reference,
    required this.isLight,
    required this.onClose,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    if (reference == null) {
      return Container(
        width: 320,
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

    final ref = reference!;
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
      width: 340,
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
                  onPressed: onClose,
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
                  onPressed: () => onEdit(ref),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => onArchive(ref.id, !ref.archived),
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
                  onPressed: () => onDelete(ref),
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
