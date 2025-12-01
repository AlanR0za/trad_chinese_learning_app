/// Card model for spaced repetition system
class SRSCard {
  final String character;
  int interval; // days until next review
  int easeFactor; // difficulty factor (starts at 2.5)
  DateTime nextReview; // when to show this card next
  int repetitions; // number of times reviewed
  int lapses; // number of times failed

  SRSCard({
    required this.character,
    this.interval = 0,
    this.easeFactor = 250, // stored as int (250 = 2.5)
    DateTime? nextReview,
    this.repetitions = 0,
    this.lapses = 0,
  }) : nextReview = nextReview ?? DateTime.now();

  /// Update card based on quality of response (0-5)
  /// 0 = complete blackout
  /// 1 = incorrect, but recognized
  /// 2 = incorrect, serious difficulty
  /// 3 = incorrect, minor difficulty
  /// 4 = correct, serious difficulty
  /// 5 = correct, easy
  void updateCard(int quality) {
    if (quality < 3) {
      // Incorrect response
      lapses++;
      repetitions = 0;
      interval = 1;
    } else {
      // Correct response
      repetitions++;
      if (repetitions == 1) {
        interval = 1;
      } else if (repetitions == 2) {
        interval = 3;
      } else {
        interval = ((interval * easeFactor) / 250).round();
      }
    }

    // Update ease factor
    easeFactor = (easeFactor +
            (250 * (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))))
        .round()
        .clamp(130, 2500); // clamp between 1.3 and 25.0

    nextReview = DateTime.now().add(Duration(days: interval));
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'character': character,
        'interval': interval,
        'easeFactor': easeFactor,
        'nextReview': nextReview.toIso8601String(),
        'repetitions': repetitions,
        'lapses': lapses,
      };

  /// Create from JSON
  factory SRSCard.fromJson(Map<String, dynamic> json) => SRSCard(
        character: json['character'] as String,
        interval: json['interval'] as int? ?? 0,
        easeFactor: json['easeFactor'] as int? ?? 250,
        nextReview: json['nextReview'] != null
            ? DateTime.parse(json['nextReview'] as String)
            : null,
        repetitions: json['repetitions'] as int? ?? 0,
        lapses: json['lapses'] as int? ?? 0,
      );
}
