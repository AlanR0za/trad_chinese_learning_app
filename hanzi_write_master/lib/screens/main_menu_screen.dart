import 'package:flutter/material.dart';
import 'character_list_screen.dart';
import 'spaced_repetition_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const MainMenuScreen({
    required this.onToggleTheme,
    required this.isDark,
    super.key,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HanziWriteMaster'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to HanziWriteMaster',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _MenuButton(
              label: 'Handwriting Practice',
              icon: Icons.edit,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterListScreen(
                      onToggleTheme: widget.onToggleTheme,
                      isDark: widget.isDark,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _MenuButton(
              label: 'Vocabulary Builder',
              icon: Icons.language,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpacedRepetitionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _MenuButton(
              label: 'Character Quiz',
              icon: Icons.quiz,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
