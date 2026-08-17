import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const TodoNextApp());
}

class TodoNextApp extends StatefulWidget {
  const TodoNextApp({super.key});

  @override
  State<TodoNextApp> createState() => _TodoNextAppState();
}

class _TodoNextAppState extends State<TodoNextApp> {
  AppThemeId _currentTheme = AppThemeId.dark;
  AppFontSize _currentFontSize = AppFontSize.normal;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeKey = prefs.getString('todo_next_theme');
      final fontSizeKey = prefs.getString('todo_next_font_size');

      setState(() {
        if (themeKey != null) {
          _currentTheme = AppTheme.fromKey(themeKey);
        }
        if (fontSizeKey != null) {
          _currentFontSize = AppTheme.fontSizeFromKey(fontSizeKey);
        }
      });
    } catch (_) {}
  }

  Future<void> _setTheme(AppThemeId theme) async {
    setState(() {
      _currentTheme = theme;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('todo_next_theme', AppTheme.toKey(theme));
    } catch (_) {}
  }

  Future<void> _setFontSize(AppFontSize size) async {
    setState(() {
      _currentFontSize = size;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('todo_next_font_size', AppTheme.fontSizeToKey(size));
    } catch (_) {}
  }

  void _cycleTheme() {
    final values = AppThemeId.values;
    final nextIndex = (values.indexOf(_currentTheme) + 1) % values.length;
    _setTheme(values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.getThemeData(_currentTheme);
    final isLight = AppTheme.isLightTheme(_currentTheme);
    final scaleDef = AppTheme.getFontSizeDefinition(_currentFontSize);

    return MaterialApp(
      title: 'Todo Next',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scaleDef.scaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomeScreen(
        currentTheme: _currentTheme,
        onSelectTheme: _setTheme,
        onToggleTheme: _cycleTheme,
        isLight: isLight,
        currentFontSize: _currentFontSize,
        onSelectFontSize: _setFontSize,
      ),
    );
  }
}
