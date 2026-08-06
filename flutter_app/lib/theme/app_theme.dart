import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF09090B);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkText = Color(0xFFE4E4E7);
  static const Color darkSubtext = Color(0xFFA1A1AA);

  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightText = Color(0xFF18181B);
  static const Color lightSubtext = Color(0xFF71717A);

  // Terminal Accent Colors
  static const Color priA = Color(0xFFEF4444); // Red
  static const Color priB = Color(0xFFF59E0B); // Amber
  static const Color priC = Color(0xFF06B6D4); // Cyan
  static const Color projectCyan = Color(0xFF06B6D4);
  static const Color contextGreen = Color(0xFF10B981);
  static const Color duePurple = Color(0xFFA855F7);
  static const Color recPurple = Color(0xFF9333EA);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        surface: darkBg,
        primary: projectCyan,
        secondary: contextGreen,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        surface: lightBg,
        primary: projectCyan,
        secondary: contextGreen,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),
    );
  }
}
