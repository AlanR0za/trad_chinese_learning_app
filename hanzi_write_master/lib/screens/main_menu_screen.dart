import 'package:flutter/material.dart';
import 'character_list_screen.dart';
import 'spaced_repetition_screen.dart';
import 'settings_screen.dart';
import 'fill_blanks_screen.dart';

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
        title: const Text('Chineasy'),
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
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Chineasy', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.2,
                children: [
                  _HomeCard(
                    label: 'Handwriting Practice',
                    icon: Icons.edit,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharacterListScreen(
                          onToggleTheme: widget.onToggleTheme,
                          isDark: widget.isDark,
                        ),
                      ),
                    ),
                  ),
                  _HomeCard(
                    label: 'Character Quiz',
                    icon: Icons.language,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SpacedRepetitionScreen())),
                  ),
                  _HomeCard(
                    label: 'Sentence Builder',
                    icon: Icons.quiz,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FillBlanksScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _HomeCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
