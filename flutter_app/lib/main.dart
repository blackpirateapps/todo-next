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

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeKey = prefs.getString('todo_next_theme');
      if (themeKey != null) {
        setState(() {
          _currentTheme = AppTheme.fromKey(themeKey);
        });
      }
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

  void _cycleTheme() {
    final values = AppThemeId.values;
    final nextIndex = (values.indexOf(_currentTheme) + 1) % values.length;
    _setTheme(values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.getThemeData(_currentTheme);
    final isLight = AppTheme.isLightTheme(_currentTheme);

    return MaterialApp(
      title: 'Todo Next',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: HomeScreen(
        currentTheme: _currentTheme,
        onSelectTheme: _setTheme,
        onToggleTheme: _cycleTheme,
        isLight: isLight,
      ),
    );
  }
}

