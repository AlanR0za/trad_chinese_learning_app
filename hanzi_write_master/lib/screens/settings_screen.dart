import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/srs_card_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _dailyLimit;
  bool _loading = true;
  Map<String, dynamic> _stats = {
    'totalCards': 0,
    'learnedCards': 0,
    'failedCards': 0,
    'successRate': '0.0',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final limit = await SettingsService.getDailyLimit();
    final stats = await SRSCardService.getStats();
    setState(() {
      _dailyLimit = limit;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _saveDailyLimit(int newLimit) async {
    await SettingsService.setDailyLimit(newLimit);
    setState(() => _dailyLimit = newLimit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily limit updated to $newLimit')),
      );
    }
  }

  void _showLimitDialog() {
    final controller = TextEditingController(text: _dailyLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily limit',
            hintText: 'Enter number of cards per day',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                _saveDailyLimit(value);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Progress?'),
        content: const Text(
          'This will reset all your SRS card data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SRSCardService.clearAllProgress();
              final stats = await SRSCardService.getStats();
              setState(() => _stats = stats);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All progress cleared')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // SRS Settings Section
          ListTile(
            title: const Text('Spaced Repetition'),
            subtitle: const Text('Configure SRS settings'),
          ),
          ListTile(
            title: const Text('Daily Card Limit'),
            subtitle: Text('$_dailyLimit cards per day'),
            trailing: const Icon(Icons.edit),
            onTap: _showLimitDialog,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'The daily limit controls how many new cards you can learn in spaced repetition mode per day.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          // Stats Section
          const Divider(),
          ListTile(
            title: const Text('Learning Progress'),
            subtitle: const Text('Your SRS statistics'),
          ),
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Cards: ${_stats['totalCards']}'),
                      Text('Learned: ${_stats['learnedCards']}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Failed: ${_stats['failedCards']}'),
                      Text('Success Rate: ${_stats['successRate']}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Danger Zone
          const Divider(),
          ListTile(
            title: const Text('Danger Zone'),
            subtitle: const Text('Destructive actions'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _showClearConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All SRS Progress'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'This will delete all your learning progress in the spaced repetition system. You can still restart by clearing this.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
