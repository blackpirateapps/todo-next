import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../models/reference.dart';

class SidebarWidget extends StatelessWidget {
  final List<Task> tasks;
  final List<Reference> references;
  final String activeFilter;
  final String activeView;
  final Function(String) onFilterClick;
  final Function(String)? onChangeView;
  final bool isLight;

  const SidebarWidget({
    super.key,
    required this.tasks,
    this.references = const [],
    required this.activeFilter,
    this.activeView = 'list',
    required this.onFilterClick,
    this.onChangeView,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> projectsSet = {};
    final Set<String> contextsSet = {};

    for (final t in tasks) {
      projectsSet.addAll(t.projects);
      contextsSet.addAll(t.contexts);
    }

    final projectsList = projectsSet.toList()..sort();
    final contextsList = contextsSet.toList()..sort();

    final Set<String> refTagsSet = {};
    for (final r in references) {
      refTagsSet.addAll(r.tags);
    }
    final refTagsList = refTagsSet.toList()..sort();

    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    final openTasksCount = tasks.where((t) => !t.completed).length;
    final activeRefsCount = references.where((r) => !r.archived).length;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WORKSPACES SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'WORKSPACES',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // Tasks Workspace
            InkWell(
              onTap: () => onChangeView?.call('list'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: activeView == 'list'
                    ? (isLight ? Colors.grey[300] : Colors.grey[800])
                    : Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✓ Tasks',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: activeView == 'list' ? FontWeight.bold : FontWeight.w500,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      '$openTasksCount',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: isLight ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calendar Workspace
            InkWell(
              onTap: () => onChangeView?.call('calendar'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: activeView == 'calendar'
                    ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                    : Colors.transparent,
                child: Text(
                  '📅 Calendar',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: activeView == 'calendar' ? FontWeight.bold : FontWeight.w500,
                    color: activeView == 'calendar'
                        ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                        : (isLight ? Colors.black : Colors.white),
                  ),
                ),
              ),
            ),

            // References Workspace
            InkWell(
              onTap: () => onChangeView?.call('references'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: activeView == 'references'
                    ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                    : Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '▸ References',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: activeView == 'references' ? FontWeight.bold : FontWeight.w600,
                        color: activeView == 'references'
                            ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                            : (isLight ? Colors.cyan[800] : Colors.cyan[400]),
                      ),
                    ),
                    Text(
                      '$activeRefsCount',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: isLight ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 16),

            // Main Filter Button
            Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                selected: activeFilter.isEmpty,
                selectedTileColor: isLight ? Colors.grey[300] : Colors.grey[800],
                title: Text(
                  activeView == 'references' ? '[ALL ACTIVE REFS]' : '[ALL TASKS]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
                onTap: () => onFilterClick(''),
              ),
            ),

            if (activeView == 'references') ...[
              Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  selected: activeFilter == 'archived',
                  selectedTileColor: isLight ? Colors.amber[100] : Colors.amber[950],
                  title: Text(
                    '[ARCHIVED REFS]',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.amber[900] : Colors.amber[300],
                    ),
                  ),
                  onTap: () => onFilterClick('archived'),
                ),
              ),
            ],

            const Divider(height: 1),

            // Dynamic Tags / Categories List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (activeView == 'references') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        'REFERENCE TAGS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...refTagsList.map((tag) => InkWell(
                          onTap: () => onFilterClick(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            color: activeFilter == tag
                                ? (tag.startsWith('+')
                                    ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                                    : (isLight ? Colors.green[100] : Colors.green[950]))
                                : Colors.transparent,
                            child: Text(
                              tag,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: activeFilter == tag
                                    ? (tag.startsWith('+')
                                        ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                                        : (isLight ? Colors.green[900] : Colors.green[300]))
                                    : (tag.startsWith('+')
                                        ? (isLight ? Colors.cyan[800] : Colors.cyan[400])
                                        : (isLight ? Colors.green[800] : Colors.green[400])),
                              ),
                            ),
                          ),
                        )),
                    if (refTagsList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'No tags yet',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        'PROJECTS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...projectsList.map((p) => InkWell(
                          onTap: () => onFilterClick(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            color: activeFilter == p
                                ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                                : Colors.transparent,
                            child: Text(
                              p,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: activeFilter == p
                                    ? (isLight ? Colors.cyan[900] : Colors.cyan[300])
                                    : (isLight ? Colors.cyan[800] : Colors.cyan[400]),
                              ),
                            ),
                          ),
                        )),
                    if (projectsList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'No projects',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        'CONTEXTS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    ...contextsList.map((c) => InkWell(
                          onTap: () => onFilterClick(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            color: activeFilter == c
                                ? (isLight ? Colors.green[100] : Colors.green[950])
                                : Colors.transparent,
                            child: Text(
                              c,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: activeFilter == c
                                    ? (isLight ? Colors.green[900] : Colors.green[300])
                                    : (isLight ? Colors.green[800] : Colors.green[400]),
                              ),
                            ),
                          ),
                        )),
                    if (contextsList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'No contexts',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
