import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class SidebarWidget extends StatelessWidget {
  final List<Task> tasks;
  final String activeFilter;
  final Function(String) onFilterClick;
  final bool isLight;

  const SidebarWidget({
    super.key,
    required this.tasks,
    required this.activeFilter,
    required this.onFilterClick,
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

    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

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
            Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                selected: activeFilter.isEmpty,
                selectedTileColor: isLight ? Colors.grey[300] : Colors.grey[800],
                title: Text(
                  '[ALL TASKS]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
                onTap: () => onFilterClick(''),
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
