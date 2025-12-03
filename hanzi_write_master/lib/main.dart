import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    // Palette based on provided artwork:
    // Light mode: warm cream background + orange primary and deep red accents
    const lightBackground = Color(0xFFFAF1E9); // soft cream
    const primaryOrange = Color(0xFFEA5A2B); // vibrant orange from logo
    const primaryDeep = Color(0xFFB63F27); // deeper red-orange for contrast
    const textDeep = Color(0xFF6A2E25); // deep red for headings

    final lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryOrange,
      onPrimary: Colors.white,
      secondary: primaryDeep,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: lightBackground,
      onBackground: textDeep,
      surface: Colors.white,
      onSurface: textDeep,
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryOrange,
      textTheme: ThemeData.light().textTheme.apply(bodyColor: textDeep, displayColor: textDeep),
    ).copyWith(
      appBarTheme: AppBarTheme(backgroundColor: primaryOrange, foregroundColor: lightScheme.onPrimary, elevation: 2),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryDeep, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
      iconTheme: const IconThemeData(color: primaryDeep),
    );

    // Dark mode: largely black & white with a small orange accent
    final darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: primaryOrange,
      onSecondary: Colors.white,
      error: Colors.red.shade400,
      onError: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      // Softer dark background (dark gray instead of pure black)
      scaffoldBackgroundColor: const Color(0xFF0F1113),
      primaryColor: Colors.white,
      textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    ).copyWith(
      appBarTheme: AppBarTheme(backgroundColor: const Color(0xFF111214), foregroundColor: Colors.white, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );

    return MaterialApp(
      title: 'Chineasy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainMenuScreen(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}
