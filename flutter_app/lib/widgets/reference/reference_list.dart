import 'package:flutter/material.dart';
import '../../models/reference.dart';
import '../../theme/app_theme.dart';
import 'reference_item.dart';

enum ReferenceSortOrder { updated, created, alphabetical }

class ReferenceListWidget extends StatefulWidget {
  final List<Reference> references;
  final String? selectedReferenceId;
  final bool isLight;
  final Function(Reference reference) onSelectReference;
  final Function(Reference reference) onDeleteReference;
  final VoidCallback onOpenNewReference;
  final String activeFilter;
  final bool showIcons;

  const ReferenceListWidget({
    super.key,
    required this.references,
    this.selectedReferenceId,
    required this.isLight,
    required this.onSelectReference,
    required this.onDeleteReference,
    required this.onOpenNewReference,
    this.activeFilter = '',
    this.showIcons = false,
  });

  @override
  State<ReferenceListWidget> createState() => _ReferenceListWidgetState();
}

class _ReferenceListWidgetState extends State<ReferenceListWidget> {
  String _tabFilter = 'all'; // 'all' | 'recent' | 'archived'
  String _selectedTag = '';
  ReferenceSortOrder _sortOrder = ReferenceSortOrder.updated;

  List<Reference> _getProcessedReferences() {
    List<Reference> list = List.from(widget.references);

    // 1. Tab Filter
    if (_tabFilter == 'archived') {
      list = list.where((r) => r.archived).toList();
    } else if (_tabFilter == 'recent') {
      list = list.where((r) => !r.archived).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      list = list.take(15).toList();
    } else {
      list = list.where((r) => !r.archived).toList();
    }

    // 2. Tag Filter
    if (_selectedTag.isNotEmpty) {
      list = list.where((r) => r.tags.contains(_selectedTag)).toList();
    }

    // 3. Parent Active Filter (from sidebar or search)
    if (widget.activeFilter.isNotEmpty) {
      final q = widget.activeFilter.toLowerCase();
      if (widget.activeFilter.startsWith('+') || widget.activeFilter.startsWith('@')) {
        list = list.where((r) => r.tags.contains(widget.activeFilter)).toList();
      } else if (widget.activeFilter == 'archived') {
        list = list.where((r) => r.archived).toList();
      } else {
        list = list.where((r) =>
          r.title.toLowerCase().contains(q) ||
          r.content.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q))
        ).toList();
      }
    }

    // 4. Sorting
    switch (_sortOrder) {
      case ReferenceSortOrder.updated:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ReferenceSortOrder.created:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReferenceSortOrder.alphabetical:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return list;
  }

  Set<String> _getAllTags() {
    final Set<String> tags = {};
    for (final ref in widget.references) {
      tags.addAll(ref.tags);
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _getProcessedReferences();
    final allTags = _getAllTags().toList()..sort();

    return Container(
      color: widget.isLight ? Colors.white : Colors.black,
      child: Column(
        children: [
          // Toolbar: Header, Tabs, Sort
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isLight ? Colors.grey[100] : const Color(0xFF111113),
              border: Border(bottom: BorderSide(color: widget.isLight ? Colors.grey[300]! : Colors.grey[800]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.showIcons ? '🗂️ [ REFERENCES ]' : '[ REFERENCES ]',
                      style: AppTheme.monoStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.isLight ? Colors.cyan[800] : Colors.cyan[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.isLight ? Colors.grey[400]! : Colors.grey[700]!),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('all', widget.showIcons ? '📂 All' : 'All'),
                          _buildTabButton('recent', widget.showIcons ? '⚡ Recent' : 'Recent'),
                          _buildTabButton('archived', widget.showIcons ? '📦 Archived' : 'Archived'),
                        ],
                      ),
                    ),
                  ],
                ),

                // Sort Dropdown & New Button
                Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<ReferenceSortOrder>(
                        value: _sortOrder,
                        isDense: true,
                        dropdownColor: widget.isLight ? Colors.white : Colors.grey[900],
                        style: AppTheme.monoStyle(fontSize: 10, color: widget.isLight ? Colors.black : Colors.white),
                        items: [
                          DropdownMenuItem(value: ReferenceSortOrder.updated, child: Text(widget.showIcons ? '🕒 Updated' : 'Updated')),
                          DropdownMenuItem(value: ReferenceSortOrder.created, child: Text(widget.showIcons ? '📅 Created' : 'Created')),
                          DropdownMenuItem(value: ReferenceSortOrder.alphabetical, child: Text(widget.showIcons ? '🔤 A-Z' : 'A-Z')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sortOrder = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: widget.onOpenNewReference,
                      child: Text(
                        widget.showIcons ? '➕ NEW' : '+ NEW',
                        style: AppTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tag Filter Bar
          if (allTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isLight ? Colors.grey[50] : const Color(0xFF09090B),
                border: Border(bottom: BorderSide(color: widget.isLight ? Colors.grey[200]! : Colors.grey[800]!)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      widget.showIcons ? '🏷️ Tags: ' : 'Tags: ',
                      style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                    InkWell(
                      onTap: () => setState(() => _selectedTag = ''),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _selectedTag.isEmpty
                              ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                              : Colors.transparent,
                          border: Border.all(color: widget.isLight ? Colors.grey[300]! : Colors.grey[700]!),
                        ),
                        child: Text(
                          'All',
                          style: AppTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ...allTags.map((tag) {
                      final isSelected = _selectedTag == tag;
                      final isProj = tag.startsWith('+');
                      return InkWell(
                        onTap: () => setState(() => _selectedTag = isSelected ? '' : tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isProj
                                    ? (widget.isLight ? Colors.cyan[200] : Colors.cyan[900])
                                    : (widget.isLight ? Colors.green[200] : Colors.green[900]))
                                : Colors.transparent,
                            border: Border.all(
                              color: isProj
                                  ? (widget.isLight ? Colors.cyan[300]! : Colors.cyan[800]!)
                                  : (widget.isLight ? Colors.green[300]! : Colors.green[800]!),
                            ),
                          ),
                          child: Text(
                            widget.showIcons ? (isProj ? '🎯 $tag' : '📍 $tag') : tag,
                            style: AppTheme.monoStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // List Body
          Expanded(
            child: displayed.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: displayed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final ref = displayed[index];
                      return ReferenceItemWidget(
                        reference: ref,
                        isSelected: widget.selectedReferenceId == ref.id,
                        isLight: widget.isLight,
                        onSelect: () => widget.onSelectReference(ref),
                        onDelete: () => widget.onDeleteReference(ref),
                        showIcons: widget.showIcons,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String key, String label) {
    final isActive = _tabFilter == key;
    return InkWell(
      onTap: () => setState(() => _tabFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: isActive
            ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
            : Colors.transparent,
        child: Text(
          label,
          style: AppTheme.monoStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? (widget.isLight ? Colors.black : Colors.white)
                : (widget.isLight ? Colors.grey[700] : Colors.grey[400]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_tabFilter == 'archived') {
      return Center(
        child: Text(
          widget.showIcons ? '📦 No archived references.' : 'No archived references.',
          style: AppTheme.monoStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      );
    }

    if (_selectedTag.isNotEmpty || widget.activeFilter.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No references match active filter.',
              style: AppTheme.monoStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() => _selectedTag = '');
              },
              child: Text('Clear Filters', style: AppTheme.monoStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.showIcons ? '🗂️ [ REFERENCE ]' : '[ REFERENCE ]',
              style: AppTheme.monoStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.isLight ? Colors.cyan[800] : Colors.cyan[400],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nothing here yet.',
              style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'References are for information you want to keep or remember, without checkboxes or completion states.\n\nExamples: Phone numbers, addresses, Wi-Fi info, URLs, snippets.',
              textAlign: TextAlign.center,
              style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[700],
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: widget.onOpenNewReference,
              child: Text(
                widget.showIcons ? '➕ NEW REFERENCE' : '+ NEW REFERENCE',
                style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
