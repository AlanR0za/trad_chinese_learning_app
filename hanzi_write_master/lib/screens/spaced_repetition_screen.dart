import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hanzi_loader.dart';
import '../services/settings_service.dart';
import '../services/srs_card_service.dart';
import '../models/srs_card.dart';

class SpacedRepetitionScreen extends StatefulWidget {
  const SpacedRepetitionScreen({super.key});

  @override
  State<SpacedRepetitionScreen> createState() => _SpacedRepetitionScreenState();
}

class _SpacedRepetitionScreenState extends State<SpacedRepetitionScreen> {
  final HanziLoader _loader = HanziLoader();
  late List<SRSCard> _allCards;
  late List<SRSCard> _todayCards;
  int _currentCardIndex = 0;
  bool _showDefinition = false;
  bool _loading = true;
  int _dailyLimit = 20;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCards());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initCards() async {
    try {
      _dailyLimit = await SettingsService.getDailyLimit();
      await _loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
      final sample = _loader.sampleCharacters(200);
      
      // Load cards from storage, or initialize if first time
      _allCards = await SRSCardService.initializeOrLoadCards(sample);
      
      _filterTodayCards();
      setState(() => _loading = false);
      _focusNode.requestFocus();
    } catch (e) {
      print('Error loading cards: $e');
      setState(() => _loading = false);
    }
  }

  void _filterTodayCards() {
    final now = DateTime.now();
    _todayCards = _allCards
        .where((card) => card.nextReview.isBefore(now) ||
            (card.nextReview.day == now.day &&
                card.nextReview.month == now.month &&
                card.nextReview.year == now.year))
        .toList();

    // Limit to daily limit
    if (_todayCards.length > _dailyLimit) {
      _todayCards = _todayCards.take(_dailyLimit).toList();
    }

    if (_todayCards.isEmpty) {
      _todayCards = _allCards.take(_dailyLimit).toList();
    }
  }

  void _respondToCard(int quality) {
    if (_currentCardIndex >= _todayCards.length) return;

    final currentCard = _todayCards[_currentCardIndex];
    currentCard.updateCard(quality);
    
    // Save progress immediately
    SRSCardService.saveCards(_allCards);

    // If answered incorrectly (Again or Hard), requeue to back of list
    if (quality < 3) {
      // Remove from current position and add to back
      _todayCards.removeAt(_currentCardIndex);
      _todayCards.add(currentCard);
      // Stay at same index (which now has the next card)
      setState(() {
        _showDefinition = false;
      });
    } else {
      // Correct answer - move to next card
      if (_currentCardIndex < _todayCards.length - 1) {
        setState(() {
          _currentCardIndex++;
          _showDefinition = false;
        });
      } else {
        _showCompletionDialog();
        return;
      }
    }

    _focusNode.requestFocus();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: Text('You reviewed ${_todayCards.length} cards today!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Space to show/hide definition
      if (event.logicalKey == LogicalKeyboardKey.space) {
        setState(() => _showDefinition = !_showDefinition);
        return;
      }

      // Only allow number keys if definition is shown
      if (!_showDefinition) return;

      // Number keys for responses
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        _respondToCard(0); // Again
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        _respondToCard(1); // Hard
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        _respondToCard(3); // Good
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        _respondToCard(5); // Easy
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Spaced Repetition')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_todayCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Spaced Repetition')),
        body: const Center(
          child: Text('No cards to review today!'),
        ),
      );
    }

    final currentCard = _todayCards[_currentCardIndex];
    final pinyinList = _loader.getPinyin(currentCard.character);
    final dictEntry = _loader.getCharacterDictEntry(currentCard.character);
    final definition = dictEntry?['definition']?.toString() ?? 'No definition available';

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Spaced Repetition'),
              Text(
                '${_currentCardIndex + 1} / ${_todayCards.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentCardIndex + 1) / _todayCards.length,
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showDefinition = !_showDefinition),
                  child: Card(
                    elevation: 8,
                    margin: const EdgeInsets.all(32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.1),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentCard.character,
                            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            pinyinList.join(', '),
                            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 24),
                          AnimatedOpacity(
                            opacity: _showDefinition ? 1.0 : 0.3,
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                Text(
                                  _showDefinition ? definition : 'Press SPACE to reveal',
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Repetitions: ${currentCard.repetitions} | Lapses: ${currentCard.lapses}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _showDefinition 
                        ? 'How well did you know this character? (1-4 or click)'
                        : 'Press SPACE to reveal the answer',
                    style: TextStyle(
                      fontSize: 14,
                      color: _showDefinition ? null : Colors.grey[600],
                      fontWeight: _showDefinition ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ResponseButton(
                        label: 'Again (1)\n(0)',
                        color: Colors.red,
                        enabled: _showDefinition,
                        onPressed: () => _respondToCard(0),
                      ),
                      _ResponseButton(
                        label: 'Hard (2)\n(1)',
                        color: Colors.orange,
                        enabled: _showDefinition,
                        onPressed: () => _respondToCard(1),
                      ),
                      _ResponseButton(
                        label: 'Good (3)\n(3)',
                        color: Colors.blue,
                        enabled: _showDefinition,
                        onPressed: () => _respondToCard(3),
                      ),
                      _ResponseButton(
                        label: 'Easy (4)\n(5)',
                        color: Colors.green,
                        enabled: _showDefinition,
                        onPressed: () => _respondToCard(5),
                      ),
                    ],
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

class _ResponseButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool enabled;

  const _ResponseButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        disabledBackgroundColor: Colors.grey[400],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}
