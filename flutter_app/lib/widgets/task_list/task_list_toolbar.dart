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
              'Sort: ',
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
              items: const [
                DropdownMenuItem(value: SortField.creationDate, child: Text('Creation Date')),
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
              'Filter: ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            DropdownButton<StatusFilter>(
              value: statusFilter,
              isDense: true,
              dropdownColor: headerBg,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: isLight ? Colors.black : Colors.white,
              ),
              onChanged: (val) {
                if (val != null) onStatusFilterChanged(val);
              },
              items: const [
                DropdownMenuItem(value: StatusFilter.all, child: Text('Status: All')),
                DropdownMenuItem(value: StatusFilter.open, child: Text('Open')),
                DropdownMenuItem(value: StatusFilter.completed, child: Text('Completed')),
              ],
            ),
            const SizedBox(width: 4),
            DropdownButton<PriorityFilter>(
              value: priorityFilter,
              isDense: true,
              dropdownColor: headerBg,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: isLight ? Colors.black : Colors.white,
              ),
              onChanged: (val) {
                if (val != null) onPriorityFilterChanged(val);
              },
              items: const [
                DropdownMenuItem(value: PriorityFilter.all, child: Text('Pri: All')),
                DropdownMenuItem(value: PriorityFilter.A, child: Text('(A)')),
                DropdownMenuItem(value: PriorityFilter.B, child: Text('(B)')),
                DropdownMenuItem(value: PriorityFilter.C, child: Text('(C)')),
                DropdownMenuItem(value: PriorityFilter.none, child: Text('None')),
              ],
            ),
            const SizedBox(width: 4),
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
                const DropdownMenuItem(value: 'all', child: Text('Period: All')),
                ...periodOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
