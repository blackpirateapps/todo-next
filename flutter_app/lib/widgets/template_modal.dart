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

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: 550,
        height: 480,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('[Task Templates Gallery]', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 8),
            Text('Quickly instantiate recurring workflows with dynamic date tokens:', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text('{today}, {due:+3d}, {due:+1w}, {due:+1m}, {time:HH:MM}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.purple[300], fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final tmpl = templates[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(color: border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(tmpl.name, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                              onPressed: () {
                                onInstantiateTemplate(tmpl.id);
                                Navigator.of(context).pop();
                              },
                              child: Text('Instantiate', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white)),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 16, color: Colors.grey),
                              onPressed: () => onDeleteTemplate(tmpl.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(tmpl.rawTemplate, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[400])),
                        if (tmpl.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(tmpl.description, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500])),
                        ],
                        if (tmpl.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Subtasks (${tmpl.subtasks.length}): ${tmpl.subtasks.map((s) => s.title).join(', ')}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey[500])),
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
