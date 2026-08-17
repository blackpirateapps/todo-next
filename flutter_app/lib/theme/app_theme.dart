import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeId { dark, light, mocha, gruvboxDark, paperInk }

class ThemeDefinition {
  final AppThemeId id;
  final String key;
  final String name;
  final String badgeEmoji;
  final bool isLight;
  final String description;
  final Color bg;
  final Color card;
  final Color border;
  final Color text;
  final Color subtext;
  final Color accent;
  final Color priA;
  final Color priB;
  final Color priC;
  final Color project;
  final Color context;
  final Color due;
  final Color dueBg;

  const ThemeDefinition({
    required this.id,
    required this.key,
    required this.name,
    required this.badgeEmoji,
    required this.isLight,
    required this.description,
    required this.bg,
    required this.card,
    required this.border,
    required this.text,
    required this.subtext,
    required this.accent,
    required this.priA,
    required this.priB,
    required this.priC,
    required this.project,
    required this.context,
    required this.due,
    required this.dueBg,
  });
}

class AppTheme {
  static const List<ThemeDefinition> availableThemes = [
    ThemeDefinition(
      id: AppThemeId.dark,
      key: 'dark',
      name: 'Pitch Black',
      badgeEmoji: '🌙',
      isLight: false,
      description: 'High contrast retro pitch black (#000000) terminal canvas with cyan accents.',
      bg: Color(0xFF000000),
      card: Color(0xFF09090B),
      border: Color(0xFF27272A),
      text: Color(0xFFE4E4E7),
      subtext: Color(0xFFA1A1AA),
      accent: Color(0xFF06B6D4),
      priA: Color(0xFFEF4444),
      priB: Color(0xFFF59E0B),
      priC: Color(0xFF60A5FA),
      project: Color(0xFF22D3EE),
      context: Color(0xFF4ADE80),
      due: Color(0xFFC084FC),
      dueBg: Color(0x26C084FC),
    ),
    ThemeDefinition(
      id: AppThemeId.light,
      key: 'light',
      name: 'Clean White',
      badgeEmoji: '☀️',
      isLight: true,
      description: 'Crisp minimal white (#FFFFFF) canvas tailored for daytime legibility and clean paper aesthetics.',
      bg: Color(0xFFFFFFFF),
      card: Color(0xFFF4F4F5),
      border: Color(0xFFE4E4E7),
      text: Color(0xFF18181B),
      subtext: Color(0xFF71717A),
      accent: Color(0xFF0891B2),
      priA: Color(0xFFDC2626),
      priB: Color(0xFFD97706),
      priC: Color(0xFF2563EB),
      project: Color(0xFF0891B2),
      context: Color(0xFF16A34A),
      due: Color(0xFF9333EA),
      dueBg: Color(0xFFF3E8FF),
    ),
    ThemeDefinition(
      id: AppThemeId.mocha,
      key: 'mocha',
      name: 'Catppuccin Mocha',
      badgeEmoji: '🐱',
      isLight: false,
      description: 'Soothing pastel dark palette with soft mauve, sapphire, and sky accents.',
      bg: Color(0xFF1E1E2E),
      card: Color(0xFF181825),
      border: Color(0xFF313244),
      text: Color(0xFFCDD6F4),
      subtext: Color(0xFFA6ADC8),
      accent: Color(0xFF89DCEB),
      priA: Color(0xFFF38BA8),
      priB: Color(0xFFFAB387),
      priC: Color(0xFF89B4FA),
      project: Color(0xFF74C7EC),
      context: Color(0xFFA6E3A1),
      due: Color(0xFFCBA6F7),
      dueBg: Color(0x26CBA6F7),
    ),
    ThemeDefinition(
      id: AppThemeId.gruvboxDark,
      key: 'gruvbox-dark',
      name: 'Gruvbox Dark',
      badgeEmoji: '🌰',
      isLight: false,
      description: 'Warm retro groove palette with aqua, olive green, and earthy warm tones.',
      bg: Color(0xFF1D2021),
      card: Color(0xFF282828),
      border: Color(0xFF3C3836),
      text: Color(0xFFEBDBB2),
      subtext: Color(0xFFA89984),
      accent: Color(0xFF8EC07C),
      priA: Color(0xFFFB4934),
      priB: Color(0xFFFE8019),
      priC: Color(0xFFFABD2F),
      project: Color(0xFF83A598),
      context: Color(0xFFB8BB26),
      due: Color(0xFFD3869B),
      dueBg: Color(0x26D3869B),
    ),
    ThemeDefinition(
      id: AppThemeId.paperInk,
      key: 'paper-ink',
      name: 'Paper & Ink',
      badgeEmoji: '📜',
      isLight: true,
      description: 'Warm linen paper background with rich typewriter ink typography.',
      bg: Color(0xFFFBF8F2),
      card: Color(0xFFF2ECE0),
      border: Color(0xFFD5CAB6),
      text: Color(0xFF2C2621),
      subtext: Color(0xFF6B5D52),
      accent: Color(0xFF0E7490),
      priA: Color(0xFFB91C1C),
      priB: Color(0xFFB45309),
      priC: Color(0xFF1D4ED8),
      project: Color(0xFF0284C7),
      context: Color(0xFF15803D),
      due: Color(0xFF7E22CE),
      dueBg: Color(0x1A7E22CE),
    ),
  ];

  static ThemeDefinition getDefinition(AppThemeId id) {
    return availableThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => availableThemes[0],
    );
  }

  static AppThemeId fromKey(String? key) {
    if (key == null) return AppThemeId.dark;
    final lower = key.trim().toLowerCase();
    if (lower == 'light' || lower == 'white') return AppThemeId.light;
    if (lower == 'mocha' || lower == 'catppuccin' || lower == 'catppuccin-mocha') return AppThemeId.mocha;
    if (lower == 'gruvbox' || lower == 'gruvbox-dark' || lower == 'gruvbox_dark') return AppThemeId.gruvboxDark;
    if (lower == 'paper' || lower == 'sepia' || lower == 'paper-ink' || lower == 'paper_ink') return AppThemeId.paperInk;
    return AppThemeId.dark;
  }

  static String toKey(AppThemeId id) {
    return getDefinition(id).key;
  }

  static bool isLightTheme(AppThemeId id) {
    return getDefinition(id).isLight;
  }

  // Backward compatible static properties
  static Color get darkBg => getDefinition(AppThemeId.dark).bg;
  static Color get darkCard => getDefinition(AppThemeId.dark).card;
  static Color get darkBorder => getDefinition(AppThemeId.dark).border;
  static Color get darkText => getDefinition(AppThemeId.dark).text;
  static Color get darkSubtext => getDefinition(AppThemeId.dark).subtext;

  static Color get lightBg => getDefinition(AppThemeId.light).bg;
  static Color get lightCard => getDefinition(AppThemeId.light).card;
  static Color get lightBorder => getDefinition(AppThemeId.light).border;
  static Color get lightText => getDefinition(AppThemeId.light).text;
  static Color get lightSubtext => getDefinition(AppThemeId.light).subtext;

  static const Color priA = Color(0xFFEF4444);
  static const Color priB = Color(0xFFF59E0B);
  static const Color priC = Color(0xFF60A5FA);
  static const Color projectCyan = Color(0xFF06B6D4);
  static const Color contextGreen = Color(0xFF10B981);
  static const Color duePurple = Color(0xFFA855F7);
  static const Color recPurple = Color(0xFF9333EA);

  static TextStyle monoStyle({
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextDecoration? decoration,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontFamily: 'monospace',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        fontStyle: fontStyle,
      );
    }
    try {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        fontStyle: fontStyle,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'monospace',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        fontStyle: fontStyle,
      );
    }
  }

  static ThemeData getThemeData(AppThemeId id) {
    final def = getDefinition(id);
    final brightness = def.isLight ? Brightness.light : Brightness.dark;

    TextTheme textTheme;
    try {
      final base = def.isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
      textTheme = GoogleFonts.jetBrainsMonoTextTheme(base).apply(
        bodyColor: def.text,
        displayColor: def.text,
      );
    } catch (_) {
      final base = def.isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
      textTheme = base.apply(
        bodyColor: def.text,
        displayColor: def.text,
      );
    }

    return ThemeData(
      brightness: brightness,
      fontFamily: 'monospace',
      fontFamilyFallback: const ['monospace', 'Courier', 'Roboto Mono'],
      scaffoldBackgroundColor: def.bg,
      cardColor: def.card,
      dividerColor: def.border,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: def.accent,
        onPrimary: def.isLight ? Colors.white : Colors.black,
        secondary: def.context,
        onSecondary: Colors.white,
        error: def.priA,
        onError: Colors.white,
        surface: def.card,
        onSurface: def.text,
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData darkTheme() => getThemeData(AppThemeId.dark);
  static ThemeData lightTheme() => getThemeData(AppThemeId.light);
}
