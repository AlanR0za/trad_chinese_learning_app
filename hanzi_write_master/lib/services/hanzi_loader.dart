import 'dart:convert';
import 'package:flutter/services.dart';

/// HanziLoader: carga datos convertidos de Make Me a Hanzi desde assets.
///
/// - Espera `assets/hanzi/graphics.json` y `assets/hanzi/dict.json`.
/// - `getCharacterStrokeData(char)` devuelve una lista de trazos,
///   donde cada trazo es una lista de puntos (ej: [[x,y],[x,y],...])
class HanziLoader {
  Map<String, dynamic> _graphics = {};
  Map<String, dynamic> _dict = {};
  Map<String, dynamic> _medians = {};

  /// Carga los JSON desde el bundle de Flutter. Se cachea en memoria.
  Future<void> loadFromAssetBundle([AssetBundle? bundle]) async {
    final loader = bundle ?? rootBundle;
    // Avoid reloading everything if already present
    if (_graphics.isNotEmpty && _dict.isNotEmpty && _medians.isNotEmpty) return;
    if (_graphics.isEmpty || _dict.isEmpty) {
      try {
        final g = await loader.loadString('assets/hanzi/graphics.json');
        final d = await loader.loadString('assets/hanzi/dict.json');
        _graphics = json.decode(g) as Map<String, dynamic>;
        _dict = json.decode(d) as Map<String, dynamic>;
      } catch (_) {
        _graphics = {};
        _dict = {};
      }
    }

    // Try to load medians file permissively
    try {
      final m = await loader.loadString('assets/hanzi/medians_graphics.json');
      try {
        final decoded = json.decode(m);
        if (decoded is Map<String, dynamic>) {
          _medians = decoded;
        } else if (decoded is List) {
          for (var item in decoded) {
            if (item is Map && item.containsKey('character') && item.containsKey('medians')) {
              _medians[item['character'].toString()] = item['medians'];
            }
          }
        }
      } catch (_) {
        // fallback to line-delimited JSON
        for (var line in LineSplitter.split(m)) {
          final t = line.trim();
          if (t.isEmpty) continue;
          try {
            final obj = json.decode(t);
            if (obj is Map) {
              if (obj.containsKey('character') && obj.containsKey('medians')) {
                _medians[obj['character'].toString()] = obj['medians'];
                continue;
              }
              if (obj.keys.length == 1) {
                final key = obj.keys.first.toString();
                final val = obj[key];
                if (val is Map && val.containsKey('medians')) {
                  _medians[key] = val['medians'];
                  continue;
                }
                if (val is List) {
                  _medians[key] = val;
                  continue;
                }
              }
            }
          } catch (_) {
            // ignore malformed line
          }
        }
      }
    } catch (_) {
      _medians = {};
    }
  }

  /// Obtiene datos de trazos para un carácter.
  /// Devuelve `List<List<List<double>>>` -> lista de trazos, cada trazo lista de puntos [x,y].
  List<List<List<double>>> getCharacterStrokeData(String ch) {
    if (_graphics.containsKey(ch)) {
      final raw = _graphics[ch];
      try {
        return _toDoubleStrokes(raw);
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Obtiene la mediana (skeleton) de un carácter si está disponible.
  /// Devuelve lista de trazos con pares [x,y] o vacío.
  List<List<List<double>>> getCharacterMedianStrokeData(String ch) {
    if (_medians.containsKey(ch)) {
      final raw = _medians[ch];
      try {
        if (raw is List) return _toDoubleStrokes(raw);
        if (raw is Map && raw.containsKey('medians')) {
          final r = raw['medians'];
          if (r is List) return _toDoubleStrokes(r);
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  List<List<List<double>>> _toDoubleStrokes(dynamic raw) {
    final out = <List<List<double>>>[];
    if (raw is! List) return out;
    for (var t in raw) {
      if (t is! List) continue;
      final stroke = <List<double>>[];
      for (var p in t) {
        if (p is List && p.length >= 2) {
          final a = (p[0] as num).toDouble();
          final b = (p[1] as num).toDouble();
          stroke.add([a, b]);
        }
      }
      out.add(stroke);
    }
    return out;
  }

  /// Ejemplo: devuelve una lista de caracteres disponibles (hasta n)
  List<String> sampleCharacters(int n) {
    final keys = _graphics.keys.toList();
    if (keys.isEmpty) return ['中', '人', '大'];
    return keys.take(n).toList();
  }

  /// Buscador básico por pinyin usando dict.json
  List<String> getPinyin(String ch) {
    if (!_dict.containsKey(ch)) return <String>[];
    try {
      final v = _dict[ch]['pinyin'];
      if (v == null) return <String>[];
      if (v is String) {
        return v.split(RegExp(r'[;,\s]+')).where((s) => s.isNotEmpty).toList();
      }
      if (v is List) return v.map((e) => e.toString()).toList();
    } catch (_) {}
    return <String>[];
  }

  /// Devuelve la entrada cruda de `dict.json` para un carácter, o null si no existe.
  Map<String, dynamic>? getCharacterDictEntry(String ch) {
    if (!_dict.containsKey(ch)) return null;
    final raw = _dict[ch];
    if (raw is Map<String, dynamic>) return raw;
    try {
      return Map<String, dynamic>.from(raw as Map);
    } catch (_) {
      return null;
    }
  }
}
