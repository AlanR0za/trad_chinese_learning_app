import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();
  String? _selectedVoiceName;

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Preferred defaults for Mandarin
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.38);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      if (!kIsWeb) await _tts.awaitSpeakCompletion(true);

      // Try to pick a device-provided Chinese voice if available
      try {
        final voices = await _getVoicesSafe();
        // voices: list of maps or list of strings depending on platform/version
        String? pickName;
        String? pickLocale;
        for (var v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? v['voice'] ?? v['name'])?.toString() ?? '';
            final name = (v['name'] ?? v['voice'])?.toString() ?? '';
            if (locale.startsWith('zh') || name.toLowerCase().contains('zh') || name.toLowerCase().contains('zh_cn') || name.toLowerCase().contains('xiaoyan') || name.toLowerCase().contains('liang')) {
              pickName = name;
              pickLocale = locale;
              break;
            }
          } else if (v is String) {
            final s = v.toLowerCase();
            if (s.startsWith('zh') || s.contains('zh')) {
              pickName = v;
              break;
            }
          }
        }
        if (pickName != null) {
          await setVoice({'name': pickName, 'locale': pickLocale ?? 'zh-CN'});
        }
      } catch (e) {
        debugPrint('AudioService voice selection failed: $e');
      }
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  // Safe wrapper: some flutter_tts versions expose getVoices() as a Future<List<dynamic>>
  Future<List<dynamic>> _getVoicesSafe() async {
    try {
      final v = await _tts.getVoices;
      if (v is List) return v;
      return <dynamic>[];
    } catch (_) {
      try {
        final langs = await _tts.getLanguages; // fallback
        if (langs is List) return langs;
        return <dynamic>[];
      } catch (_) {
        return <dynamic>[];
      }
    }
  }

  Future<List<dynamic>> getAvailableVoices() async => await _getVoicesSafe();

  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _tts.setVoice(voice);
      _selectedVoiceName = voice['name'];
    } catch (e) {
      debugPrint('AudioService setVoice error: $e');
    }
  }

  Future<void> setLanguage(String locale) async {
    try {
      await _tts.setLanguage(locale);
    } catch (e) {
      debugPrint('AudioService setLanguage error: $e');
    }
  }

  Future<void> setRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('AudioService setRate error: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      debugPrint('AudioService setPitch error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AudioService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('AudioService stop error: $e');
    }
  }

  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
  }
}
