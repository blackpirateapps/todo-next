import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final bool isLight;
  final double fontSize;

  const FormattedText({
    super.key,
    required this.text,
    this.isCompleted = false,
    required this.isLight,
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final words = text.split(RegExp(r'\s+'));
    final List<TextSpan> spans = [];

    final defaultStyle = GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      color: isCompleted
          ? (isLight ? Colors.grey[400] : Colors.grey[600])
          : (isLight ? AppTheme.lightText : AppTheme.darkText),
      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
    );

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      TextStyle style = defaultStyle;

      if (!isCompleted) {
        if (RegExp(r'^\([A-Z]\)$').hasMatch(word)) {
          final pri = word[1];
          Color color = AppTheme.priC;
          if (pri == 'A') color = AppTheme.priA;
          if (pri == 'B') color = AppTheme.priB;

          style = defaultStyle.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          );
        } else if (word.startsWith('+') && word.length > 1) {
          style = defaultStyle.copyWith(
            color: isLight ? Colors.cyan[800] : Colors.cyan[300],
            fontWeight: FontWeight.w600,
          );
        } else if (word.startsWith('@') && word.length > 1) {
          style = defaultStyle.copyWith(
            color: isLight ? Colors.green[800] : Colors.green[400],
            fontWeight: FontWeight.w600,
          );
        } else if (word.toLowerCase().startsWith('due:')) {
          style = defaultStyle.copyWith(
            color: isLight ? Colors.purple[800] : Colors.purple[300],
            fontWeight: FontWeight.bold,
          );
        } else if (word.toLowerCase().startsWith('time:')) {
          style = defaultStyle.copyWith(
            color: isLight ? Colors.purple[800] : Colors.purple[300],
            fontWeight: FontWeight.bold,
          );
        } else if (word.toLowerCase().startsWith('rec:')) {
          style = defaultStyle.copyWith(
            color: isLight ? Colors.cyan[900] : Colors.cyan[300],
            fontWeight: FontWeight.bold,
          );
        }
      }

      spans.add(TextSpan(text: word, style: style));
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: defaultStyle));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      overflow: TextOverflow.clip,
    );
  }
}
