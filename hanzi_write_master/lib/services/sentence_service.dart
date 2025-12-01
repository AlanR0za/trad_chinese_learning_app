import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sentence_exercise.dart';

class SentenceService {
  static final SentenceService _instance = SentenceService._internal();

  factory SentenceService() {
    return _instance;
  }

  SentenceService._internal();

  List<SentenceExercise> _sentences = [];
  bool _loaded = false;

  /// Load sentences from JSON asset
  Future<void> loadSentences([AssetBundle? bundle]) async {
    if (_loaded) return;

    try {
      final loader = bundle ?? rootBundle;
      final jsonString = await loader.loadString('assets/sentences.json');
      final jsonList = jsonDecode(jsonString) as List;
      _sentences = jsonList.map((item) => SentenceExercise.fromJson(item)).toList();
      _loaded = true;
    } catch (e) {
      print('Error loading sentences: $e');
      _loaded = true;
    }
  }

  /// Get all sentences
  List<SentenceExercise> getAllSentences() {
    return _sentences;
  }

  /// Get a random set of sentences for a session
  List<SentenceExercise> getRandomSessionSentences(int count) {
    if (_sentences.isEmpty) return [];
    
    final shuffled = List<SentenceExercise>.from(_sentences);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  /// Get sentence by ID
  SentenceExercise? getSentenceById(int id) {
    try {
      return _sentences.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
