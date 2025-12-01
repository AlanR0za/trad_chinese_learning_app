import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

void main() {
  runApp(const HanziWriteMasterApp());
}

class HanziWriteMasterApp extends StatefulWidget {
  const HanziWriteMasterApp({super.key});

  @override
  State<HanziWriteMasterApp> createState() => _HanziWriteMasterAppState();
}

class _HanziWriteMasterAppState extends State<HanziWriteMasterApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanziWriteMaster',
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainMenuScreen(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}
