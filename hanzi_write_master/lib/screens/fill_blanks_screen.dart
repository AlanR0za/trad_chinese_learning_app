import 'package:flutter/material.dart';
import '../services/sentence_service.dart';
import '../models/sentence_exercise.dart';

class FillBlanksScreen extends StatefulWidget {
  const FillBlanksScreen({super.key});

  @override
  State<FillBlanksScreen> createState() => _FillBlanksScreenState();
}

class _FillBlanksScreenState extends State<FillBlanksScreen> {
  final SentenceService _sentenceService = SentenceService();
  late List<SentenceExercise> _sessionSentences;
  late List<SentencePuzzle> _puzzles;
  int _currentIndex = 0;
  bool _loading = true;
  bool _showResult = false;
  late SentencePuzzle _currentPuzzle;
  int? _selectedBlankPosition; // For multi-blank selection

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    await _sentenceService.loadSentences(DefaultAssetBundle.of(context));
    _sessionSentences = _sentenceService.getRandomSessionSentences(5);
    _puzzles = _sessionSentences.map((s) => s.createPuzzle()).toList();
    
    setState(() {
      _currentPuzzle = _puzzles[0];
      _loading = false;
    });
  }

  void _toggleBlankSelection(int position) {
    setState(() {
      if (_selectedBlankPosition == position) {
        _selectedBlankPosition = null;
      } else {
        _selectedBlankPosition = position;
      }
    });
  }

  void _addWordToNextBlank(String word) {
    // If a blank is selected, fill it
    if (_selectedBlankPosition != null) {
      final selectedPos = _selectedBlankPosition!;
      setState(() {
        _currentPuzzle.userAnswers[selectedPos] = word;
        _selectedBlankPosition = null; // Clear selection after filling
      });
      return;
    }

    // Otherwise, fill the first empty blank from left to right
    final sortedPositions = _currentPuzzle.blanks.keys.toList()..sort();
    for (final pos in sortedPositions) {
      if (!_currentPuzzle.userAnswers.containsKey(pos)) {
        setState(() {
          _currentPuzzle.userAnswers[pos] = word;
        });
        return;
      }
    }
  }

  void _checkAnswer() {
    if (_currentPuzzle.userAnswers.length != _currentPuzzle.blanks.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all blanks')),
      );
      return;
    }

    setState(() => _showResult = true);

    if (_currentPuzzle.isCorrect()) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _moveToNext();
      });
    }
  }

  void _moveToNext() {
    if (_currentIndex < _puzzles.length - 1) {
      setState(() {
        _currentIndex++;
        _currentPuzzle = _puzzles[_currentIndex];
        _showResult = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _requeue() {
    setState(() {
      _showResult = false;
      _currentPuzzle.userAnswers.clear();
    });
  }

  void _showCompletionDialog() {
    final correct = _puzzles.where((p) => p.isCorrect()).length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text('You got $correct/${_puzzles.length} correct!'),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sentence Practice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sentence Practice'),
            Text(
              '${_currentIndex + 1}/${_puzzles.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _puzzles.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // English translation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentPuzzle.exercise.english,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sentence with blanks
                    _SentenceDisplay(
                      puzzle: _currentPuzzle,
                      selectedBlank: _selectedBlankPosition,
                      onBlankTap: _toggleBlankSelection,
                    ),
                    const SizedBox(height: 32),

                    // Answer pool
                    if (!_showResult)
                      _AnswerPool(
                        words: _currentPuzzle.answerPool,
                        usedWords: _currentPuzzle.userAnswers.values.toList(),
                        onWordTap: _addWordToNextBlank,
                      ),

                    // Result feedback
                    if (_showResult) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _currentPuzzle.isCorrect()
                              ? Colors.green[50]
                              : Colors.red[50],
                          border: Border.all(
                            color: _currentPuzzle.isCorrect()
                                ? Colors.green
                                : Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentPuzzle.isCorrect()
                                  ? '✓ Correct!'
                                  : '✗ Incorrect',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _currentPuzzle.isCorrect()
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!_currentPuzzle.isCorrect()) ...[
                              Text(
                                'Correct answer:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentPuzzle.getCorrectSentence(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_currentPuzzle.isCorrect())
                        ElevatedButton(
                          onPressed: _requeue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Try Again'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Check Answer Button
          if (!_showResult)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Check Answer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SentenceDisplay extends StatelessWidget {
  final SentencePuzzle puzzle;
  final int? selectedBlank;
  final Function(int) onBlankTap;

  const _SentenceDisplay({
    required this.puzzle,
    required this.selectedBlank,
    required this.onBlankTap,
  });

  @override
  Widget build(BuildContext context) {
    final words = puzzle.exercise.words;
    final blanks = puzzle.blanks;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < words.length; i++)
          if (blanks.containsKey(i))
            GestureDetector(
              onTap: () => onBlankTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedBlank == i
                        ? Colors.green
                        : puzzle.userAnswers.containsKey(i)
                            ? Colors.blue
                            : Colors.grey,
                    width: selectedBlank == i ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: selectedBlank == i
                      ? Colors.green[50]
                      : puzzle.userAnswers.containsKey(i)
                          ? Colors.blue[50]
                          : Colors.transparent,
                ),
                child: Text(
                  puzzle.userAnswers[i] ?? '_____',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: selectedBlank == i
                        ? Colors.green
                        : puzzle.userAnswers.containsKey(i)
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
              ),
            )
          else
            Text(
              words[i],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      ],
    );
  }
}

class _AnswerPool extends StatelessWidget {
  final List<String> words;
  final List<String> usedWords;
  final Function(String) onWordTap;

  const _AnswerPool({
    required this.words,
    required this.usedWords,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose the correct words:',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final word in words)
              GestureDetector(
                onTap: usedWords.contains(word)
                    ? null
                    : () => onWordTap(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: usedWords.contains(word)
                        ? Colors.grey[300]
                        : Colors.blue[100],
                    border: Border.all(
                      color: usedWords.contains(word)
                          ? Colors.grey
                          : Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: usedWords.contains(word)
                          ? Colors.grey[600]
                          : Colors.blue[800],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
