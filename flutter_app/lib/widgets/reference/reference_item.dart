import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/reference.dart';
import '../../theme/app_theme.dart';
import '../../utils/reference_utils.dart';

class ReferenceItemWidget extends StatelessWidget {
  final Reference reference;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final bool showIcons;

  const ReferenceItemWidget({
    super.key,
    required this.reference,
    required this.isSelected,
    required this.isLight,
    required this.onSelect,
    required this.onDelete,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final previewLines = reference.content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .take(2)
        .toList();

    String formattedDate = '';
    try {
      final dt = DateTime.parse(reference.updatedAt);
      formattedDate = '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {}

    final primaryCyan = Colors.cyan[700]!;

    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLight ? Colors.cyan[50] : const Color(0xFF083344).withValues(alpha: 0.3))
              : (isLight ? Colors.white : const Color(0xFF09090B)),
          border: Border.all(
            color: isSelected
                ? primaryCyan
                : (isLight ? Colors.grey[300]! : Colors.grey[800]!),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [REF] Badge
            Container(
              margin: const EdgeInsets.only(top: 2, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: reference.archived
                    ? (isLight ? Colors.amber[100] : const Color(0xFF451A03).withValues(alpha: 0.5))
                    : (isLight ? Colors.cyan[100] : const Color(0xFF083344).withValues(alpha: 0.5)),
                border: Border.all(
                  color: reference.archived
                       ? (isLight ? Colors.amber[400]! : Colors.amber[800]!)
                      : (isLight ? Colors.cyan[400]! : Colors.cyan[800]!),
                ),
              ),
              child: Text(
                showIcons ? (reference.archived ? '📦' : '🗂️') : 'REF',
                style: AppTheme.monoStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: reference.archived
                      ? (isLight ? Colors.amber[900] : Colors.amber[300])
                      : (isLight ? Colors.cyan[900] : Colors.cyan[300]),
                ),
              ),
            ),

            // Title & Content Preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reference.title,
                          style: AppTheme.monoStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isLight ? Colors.grey[900] : Colors.grey[100],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (reference.archived)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            showIcons ? '📦 [archived]' : '[archived]',
                            style: AppTheme.monoStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isLight ? Colors.amber[800] : Colors.amber[400],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (previewLines.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      previewLines.join(' · '),
                      style: AppTheme.monoStyle(
                        fontSize: 11,
                        color: isLight ? Colors.grey[600] : Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (reference.tags.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: reference.tags.map((t) {
                        final isProj = t.startsWith('+');
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                            showIcons ? (isProj ? '🎯 $t' : '📍 $t') : t,
                            style: AppTheme.monoStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isProj
                                  ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                                  : (isLight ? Colors.green[900] : Colors.green[300]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Date & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: AppTheme.monoStyle(
                      fontSize: 10,
                      color: isLight ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final formatted = ReferenceUtils.formatReferenceForCopy(reference);
                        Clipboard.setData(ClipboardData(text: formatted));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied reference to clipboard', style: AppTheme.monoStyle(fontSize: 11)),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy,
                          size: 14,
                          color: isLight ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: isLight ? Colors.red[700] : Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
