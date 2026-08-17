import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SortField { creationDate, dueDate, title, priority }
enum SortOrder { asc, desc }
enum StatusFilter { all, open, completed }
enum PriorityFilter { all, A, B, C, none }

class TaskListToolbar extends StatelessWidget {
  final SortField sortField;
  final SortOrder sortOrder;
  final StatusFilter statusFilter;
  final PriorityFilter priorityFilter;
  final String periodFilter;
  final List<String> periodOptions;
  final Function(SortField) onSortFieldChanged;
  final VoidCallback onToggleSortOrder;
  final Function(StatusFilter) onStatusFilterChanged;
  final Function(PriorityFilter) onPriorityFilterChanged;
  final Function(String) onPeriodFilterChanged;
  final bool isLight;
  final bool showIcons;

  const TaskListToolbar({
    super.key,
    required this.sortField,
    required this.sortOrder,
    required this.statusFilter,
    required this.priorityFilter,
    required this.periodFilter,
    required this.periodOptions,
    required this.onSortFieldChanged,
    required this.onToggleSortOrder,
    required this.onStatusFilterChanged,
    required this.onPriorityFilterChanged,
    required this.onPeriodFilterChanged,
    required this.isLight,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              showIcons ? '🔃 Sort: ' : 'Sort: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            DropdownButton<SortField>(
              value: sortField,
              isDense: true,
              dropdownColor: headerBg,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: isLight ? Colors.black : Colors.white,
              ),
              onChanged: (val) {
                if (val != null) onSortFieldChanged(val);
              },
              items: [
                DropdownMenuItem(value: SortField.creationDate, child: Text(showIcons ? '🕒 Created' : 'Creation Date')),
                DropdownMenuItem(value: SortField.dueDate, child: Text(showIcons ? '📅 Due Date' : 'Due Date')),
                DropdownMenuItem(value: SortField.title, child: Text(showIcons ? '🔤 Title' : 'Title')),
                DropdownMenuItem(value: SortField.priority, child: Text(showIcons ? '⚡ Priority' : 'Priority')),
              ],
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onToggleSortOrder,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(border: Border.all(color: border)),
                child: Text(
                  sortOrder == SortOrder.asc ? '[ASC ↑]' : '[DESC ↓]',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              showIcons ? '🔍 Status: ' : 'Filter: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Row(
              children: [
                _filterBtn('Open', StatusFilter.open, statusFilter == StatusFilter.open, () => onStatusFilterChanged(StatusFilter.open), border, showIcons ? '⭕ ' : null),
                _filterBtn('Done', StatusFilter.completed, statusFilter == StatusFilter.completed, () => onStatusFilterChanged(StatusFilter.completed), border, showIcons ? '✅ ' : null),
                _filterBtn('All', StatusFilter.all, statusFilter == StatusFilter.all, () => onStatusFilterChanged(StatusFilter.all), border, showIcons ? '📋 ' : null),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              showIcons ? '🚩 Pri: ' : 'Pri: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Row(
              children: [
                _priBtn('All', PriorityFilter.all, border, null),
                _priBtn('A', PriorityFilter.A, border, showIcons ? '🔴 ' : null),
                _priBtn('B', PriorityFilter.B, border, showIcons ? '🟡 ' : null),
                _priBtn('C', PriorityFilter.C, border, showIcons ? '🔵 ' : null),
                _priBtn('-', PriorityFilter.none, border, null),
              ],
            ),
            if (periodOptions.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                showIcons ? '📅 Date: ' : 'Date: ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              DropdownButton<String>(
                value: periodFilter,
                isDense: true,
                dropdownColor: headerBg,
                underline: const SizedBox.shrink(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: isLight ? Colors.black : Colors.white,
                ),
                onChanged: (val) {
                  if (val != null) onPeriodFilterChanged(val);
                },
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Dates')),
                  ...periodOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterBtn(String label, StatusFilter filter, bool active, VoidCallback onTap, Color border, [String? iconPrefix]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
          border: Border.all(color: border),
        ),
        child: Text(
          iconPrefix != null ? '$iconPrefix$label' : label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? (isLight ? Colors.black : Colors.white) : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _priBtn(String label, PriorityFilter pri, Color border, [String? iconPrefix]) {
    final active = priorityFilter == pri;
    return InkWell(
      onTap: () => onPriorityFilterChanged(pri),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
          border: Border.all(color: border),
        ),
        child: Text(
          iconPrefix != null ? '$iconPrefix$label' : label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? (isLight ? Colors.black : Colors.white) : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
