import 'package:flutter_test/flutter_test.dart';
import 'package:hanzi_write_master/services/stroke_engine.dart';
import 'package:flutter/painting.dart';

void main() {
  test('StrokeEngine returns high score for identical strokes', () {
    final engine = StrokeEngine();
    final user = [
      for (var i = 0; i < 20; i++) Offset(i.toDouble(), i.toDouble())
    ];
    final target = [
      [for (var i = 0; i < 20; i++) [i.toDouble(), i.toDouble()]]
    ];

    final score = engine.compare(user, target);
    expect(score, greaterThan(80));
  });

    test('comparePerStroke returns high scores for matching multiple strokes', () {
      final engine = StrokeEngine();
      final userStrokes = [
        [for (var i = 0; i < 10; i++) Offset(i.toDouble(), i.toDouble())],
        [for (var i = 0; i < 10; i++) Offset(i.toDouble(), 10 + i.toDouble())],
      ];
      final target = [
        [for (var i = 0; i < 10; i++) [i.toDouble(), i.toDouble()]],
        [for (var i = 0; i < 10; i++) [i.toDouble(), 10 + i.toDouble()]],
      ];

      final res = engine.comparePerStroke(userStrokes, target);
      final per = (res['perStroke'] as List).cast<double>();
      final avg = res['average'] as double;
      expect(per.length, equals(2));
      expect(per[0], greaterThan(70));
      expect(per[1], greaterThan(70));
      expect(avg, greaterThan(70));
    });
}
