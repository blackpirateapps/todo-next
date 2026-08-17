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
            Row(
              children: [
                if (showIcons) ...[
                  Icon(Icons.swap_vert, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                ],
                Text(
                  'Sort: ',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ],
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
              items: const [
                DropdownMenuItem(value: SortField.creationDate, child: Text('Created')),
                DropdownMenuItem(value: SortField.dueDate, child: Text('Due Date')),
                DropdownMenuItem(value: SortField.title, child: Text('Title')),
                DropdownMenuItem(value: SortField.priority, child: Text('Priority')),
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
              'Status: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Row(
              children: [
                _filterBtn('Open', StatusFilter.open, statusFilter == StatusFilter.open, () => onStatusFilterChanged(StatusFilter.open), border, showIcons ? Icons.radio_button_unchecked : null, Colors.amber[400]),
                _filterBtn('Done', StatusFilter.completed, statusFilter == StatusFilter.completed, () => onStatusFilterChanged(StatusFilter.completed), border, showIcons ? Icons.check_circle_outline : null, Colors.green[400]),
                _filterBtn('All', StatusFilter.all, statusFilter == StatusFilter.all, () => onStatusFilterChanged(StatusFilter.all), border, showIcons ? Icons.format_list_bulleted : null, Colors.cyan[400]),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              'Pri: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            Row(
              children: [
                _priBtn('All', PriorityFilter.all, border, null, null),
                _priBtn('A', PriorityFilter.A, border, showIcons ? Icons.flag : null, Colors.red[500]),
                _priBtn('B', PriorityFilter.B, border, showIcons ? Icons.flag : null, Colors.amber[500]),
                _priBtn('C', PriorityFilter.C, border, showIcons ? Icons.flag : null, Colors.blue[500]),
                _priBtn('-', PriorityFilter.none, border, null, null),
              ],
            ),
            if (periodOptions.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                'Date: ',
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

  Widget _filterBtn(String label, StatusFilter filter, bool active, VoidCallback onTap, Color border, [IconData? icon, Color? iconColor]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: iconColor),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? (isLight ? Colors.black : Colors.white) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priBtn(String label, PriorityFilter pri, Color border, [IconData? icon, Color? iconColor]) {
    final active = priorityFilter == pri;
    return InkWell(
      onTap: () => onPriorityFilterChanged(pri),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? (isLight ? Colors.grey[300] : Colors.grey[800]) : Colors.transparent,
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: iconColor),
              const SizedBox(width: 2),
            ],
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? (isLight ? Colors.black : Colors.white) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
