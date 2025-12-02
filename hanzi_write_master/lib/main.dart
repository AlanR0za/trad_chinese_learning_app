import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

void main() {
  runApp(const ChineasyApp());
}

class ChineasyApp extends StatefulWidget {
  const ChineasyApp({super.key});

  @override
  State<ChineasyApp> createState() => _ChineasyAppState();
}

class _ChineasyAppState extends State<ChineasyApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chineasy',
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainMenuScreen(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}
