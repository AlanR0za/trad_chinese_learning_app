import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/srs_card.dart';

class SRSCardService {
  static const String _cardsKey = 'srs_cards';

  /// Save all cards to persistent storage
  static Future<void> saveCards(List<SRSCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = cards.map((card) => jsonEncode(card.toJson())).toList();
      await prefs.setStringList(_cardsKey, jsonList);
    } catch (e) {
      print('Error saving cards: $e');
    }
  }

  /// Load all cards from persistent storage
  static Future<List<SRSCard>> loadCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_cardsKey) ?? [];
      return jsonList
          .map((json) => SRSCard.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading cards: $e');
      return [];
    }
  }

  /// Initialize cards if they don't exist yet
  static Future<List<SRSCard>> initializeOrLoadCards(List<String> allCharacters) async {
    try {
      final savedCards = await loadCards();
      if (savedCards.isNotEmpty) {
        return savedCards;
      }

      // First time - create cards for all characters
      final newCards = allCharacters.map((ch) => SRSCard(character: ch)).toList();
      await saveCards(newCards);
      return newCards;
    } catch (e) {
      print('Error initializing cards: $e');
      return allCharacters.map((ch) => SRSCard(character: ch)).toList();
    }
  }

  /// Clear all saved card progress
  static Future<void> clearAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cardsKey);
    } catch (e) {
      print('Error clearing progress: $e');
    }
  }

  /// Get statistics about current progress
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final cards = await loadCards();
      final totalCards = cards.length;
      final learnedCards = cards.where((c) => c.repetitions > 0).length;
      final failedCards = cards.where((c) => c.lapses > 0).length;

      return {
        'totalCards': totalCards,
        'learnedCards': learnedCards,
        'failedCards': failedCards,
        'successRate': totalCards > 0 ? (learnedCards / totalCards * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {
        'totalCards': 0,
        'learnedCards': 0,
        'failedCards': 0,
        'successRate': '0.0',
      };
    }
  }
}
