/// Model for a fill-in-the-blanks sentence exercise
class SentenceExercise {
  final int id;
  final String pinyin;
  final String english;
  final String fullSentence; // Complete sentence
  final List<String> words; // All words in the sentence

  SentenceExercise({
    required this.id,
    required this.pinyin,
    required this.english,
    required this.fullSentence,
    required this.words,
  });

  /// Create from JSON
  factory SentenceExercise.fromJson(Map<String, dynamic> json) {
    return SentenceExercise(
      id: json['id'] as int,
      pinyin: json['pinyin'] as String,
      english: json['english'] as String,
      fullSentence: json['sentence'] as String,
      words: List<String>.from(json['words'] as List),
    );
  }

  /// Create a puzzle by removing 1-2 random words and returning blanks with answer key
  SentencePuzzle createPuzzle() {
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Determine number of blanks (1 or 2)
    final numBlanks = (random % 2) + 1;
    
    // Select random positions for blanks
    final positions = <int>[];
    final availableIndices = List<int>.generate(words.length, (i) => i);
    availableIndices.shuffle();
    
    for (int i = 0; i < numBlanks && i < availableIndices.length; i++) {
      positions.add(availableIndices[i]);
    }
    positions.sort();

    // Create blanks and get missing words
    final blanks = <int, String>{};
    final missingWords = <String>[];
    
    for (final pos in positions) {
      blanks[pos] = words[pos];
      missingWords.add(words[pos]);
    }

    // Create pool with 5 words (missing words + 3-4 random from the sentence)
    final pool = List<String>.from(missingWords);
    
    // Add random words from the sentence to reach 5
    final availableWords = <String>[];
    for (int i = 0; i < words.length; i++) {
      if (!positions.contains(i)) {
        availableWords.add(words[i]);
      }
    }
    
    availableWords.shuffle();
    while (pool.length < 5 && availableWords.isNotEmpty) {
      pool.add(availableWords.removeAt(0));
    }
    
    // Shuffle the pool
    pool.shuffle();

    return SentencePuzzle(
      exercise: this,
      blanks: blanks,
      answerPool: pool,
      userAnswers: {},
    );
  }
}

/// A puzzle instance with blanks and answer pool
class SentencePuzzle {
  final SentenceExercise exercise;
  final Map<int, String> blanks; // position -> correct word
  final List<String> answerPool; // 5 words to choose from
  Map<int, String> userAnswers; // position -> user's answer

  SentencePuzzle({
    required this.exercise,
    required this.blanks,
    required this.answerPool,
    required this.userAnswers,
  });

  /// Check if all blanks are filled correctly
  bool isCorrect() {
    for (final pos in blanks.keys) {
      if (userAnswers[pos] != blanks[pos]) {
        return false;
      }
    }
    return userAnswers.length == blanks.length;
  }

  /// Get the sentence with blanks
  String getSentenceWithBlanks() {
    String result = '';
    for (int i = 0; i < exercise.words.length; i++) {
      if (blanks.containsKey(i)) {
        result += '_____  ';
      } else {
        result += exercise.words[i];
      }
    }
    return result;
  }

  /// Get the sentence with user's answers filled in
  String getSentenceWithAnswers() {
    String result = '';
    for (int i = 0; i < exercise.words.length; i++) {
      if (blanks.containsKey(i)) {
        result += userAnswers[i] ?? '_____';
        result += '  ';
      } else {
        result += exercise.words[i];
      }
    }
    return result;
  }

  /// Get the correct completed sentence
  String getCorrectSentence() {
    return exercise.fullSentence;
  }
}
