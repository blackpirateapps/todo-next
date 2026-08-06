import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLightMode = false;

  void _toggleTheme() {
    setState(() {
      _isLightMode = !_isLightMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Next',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isLightMode ? ThemeMode.light : ThemeMode.dark,
      home: HomeScreen(
        isLight: _isLightMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
