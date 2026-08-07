import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/template.dart';

class TemplateModalWidget extends StatelessWidget {
  final List<Template> templates;
  final Function(String templateId) onInstantiateTemplate;
  final Function(Template template) onCreateTemplate;
  final Function(String templateId) onDeleteTemplate;
  final bool isLight;

  const TemplateModalWidget({
    super.key,
    required this.templates,
    required this.onInstantiateTemplate,
    required this.onCreateTemplate,
    required this.onDeleteTemplate,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? Colors.white : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 550.0 : (screenWidth * 0.92);

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: dialogWidth,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '[Task Templates Gallery]',
                    style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 6),
            Text('Quickly instantiate recurring workflows with dynamic date tokens:', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text('{today}, {due:+3d}, {due:+1w}, {due:+1m}, {time:HH:MM}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.purple[300], fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Expanded(
              child: templates.isEmpty
                  ? Center(
                      child: Text(
                        'No templates available.',
                        style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final tmpl = templates[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tmpl.name,
                                      style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan[700],
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      onInstantiateTemplate(tmpl.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Instantiate', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: Colors.grey),
                                    padding: const EdgeInsets.only(left: 6),
                                    constraints: const BoxConstraints(),
                                    onPressed: () => onDeleteTemplate(tmpl.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(tmpl.rawTemplate, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[400])),
                              if (tmpl.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(tmpl.description, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500])),
                              ],
                              if (tmpl.subtasks.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Subtasks (${tmpl.subtasks.length}): ${tmpl.subtasks.map((s) => s.title).join(', ')}',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
