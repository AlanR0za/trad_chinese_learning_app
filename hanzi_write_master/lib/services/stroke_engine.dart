import 'dart:math';
import 'dart:ui';
import 'package:flutter/painting.dart';

/// StrokeEngine
/// Implementa un motor para comparar trazos: simplificación, resampling,
/// normalización y comparación basada en Hausdorff con heurísticas.
class StrokeEngine {
  final int resamplePoints = 64;
  final double correctThreshold = 0.70;

  List<Offset> _toOffsets(List<List<double>> points) => points.map((p) => Offset(p[0], p[1])).toList();

  List<Offset> simplify(List<Offset> pts, double tol) {
    if (pts.isEmpty) return pts;
    final out = <Offset>[pts.first];
    for (var p in pts.skip(1)) {
      if ((p - out.last).distance > tol) out.add(p);
    }
    return out;
  }

  List<Offset> resample(List<Offset> pts, int n) {
    if (pts.length < 2) return pts;
    double length(List<Offset> ps) {
      double l = 0;
      for (var i = 0; i < ps.length - 1; i++) l += (ps[i + 1] - ps[i]).distance;
      return l;
    }

    final I = length(pts) / (n - 1);
    final newPts = <Offset>[pts.first];
    double D = 0.0;

    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final d = (b - a).distance;
      if ((D + d) >= I) {
        final t = (I - D) / d;
        final nx = a.dx + t * (b.dx - a.dx);
        final ny = a.dy + t * (b.dy - a.dy);
        final newPoint = Offset(nx, ny);
        newPts.add(newPoint);
        pts.insert(i + 1, newPoint);
        D = 0.0;
      } else {
        D += d;
      }
    }

    while (newPts.length < n) newPts.add(pts.last);
    return newPts;
  }

  List<Offset> normalize(List<Offset> pts) {
    if (pts.isEmpty) return pts;
    double minX = pts.first.dx, maxX = pts.first.dx, minY = pts.first.dy, maxY = pts.first.dy;
    for (var p in pts) {
      minX = min(minX, p.dx);
      maxX = max(maxX, p.dx);
      minY = min(minY, p.dy);
      maxY = max(maxY, p.dy);
    }
    final w = maxX - minX;
    final h = maxY - minY;
    final s = (w > h) ? w : h;
    if (s == 0) return pts.map((p) => const Offset(0.5, 0.5)).toList();
    return pts.map((p) => Offset((p.dx - minX) / s, (p.dy - minY) / s)).toList();
  }

  double hausdorff(List<Offset> a, List<Offset> b) {
    double directed(List<Offset> A, List<Offset> B) {
      double maxd = 0;
      for (var p in A) {
        double mind = double.infinity;
        for (var q in B) mind = min(mind, (p - q).distance);
        maxd = max(maxd, mind);
      }
      return maxd;
    }
    final d1 = directed(a, b);
    final d2 = directed(b, a);
    return max(d1, d2);
  }

  double _scoreToSimilarity(double score) => (score / 100.0).clamp(0.0, 1.0);

  List<Offset> _targetToOffsets(List<List<List<double>>> target) {
    final merged = <Offset>[];
    for (var stroke in target) {
      final pts = _toOffsets(stroke);
      merged.addAll(pts);
      if (pts.isNotEmpty) merged.add(pts.last);
    }
    return merged;
  }

  double _compareOffsets(List<Offset> userPoints, List<Offset> targOffsets) {
    final sUser = simplify(userPoints, 2.1);
    final sTarget = simplify(targOffsets, 1.05);
    final rUser = resample(sUser, resamplePoints);
    final rTarget = resample(sTarget, resamplePoints);
    final nUser = normalize(rUser);
    final nTarget = normalize(rTarget);

    List<Offset> shrinkTarget(List<Offset> pts, double factor) {
      if (pts.isEmpty) return pts;
      double cx = 0, cy = 0;
      for (var p in pts) {
        cx += p.dx;
        cy += p.dy;
      }
      cx /= pts.length;
      cy /= pts.length;
      final center = Offset(cx, cy);
      return pts.map((p) => Offset(center.dx + factor * (p.dx - center.dx), center.dy + factor * (p.dy - center.dy))).toList();
    }

    final shrunk = normalize(resample(simplify(shrinkTarget(targOffsets, 0.5), 1.05), resamplePoints));
    final revTarget = nTarget.reversed.toList();
    final revShrunk = shrunk.reversed.toList();

    final hCandidates = <double>[hausdorff(nUser, nTarget), hausdorff(nUser, shrunk), hausdorff(nUser, revTarget), hausdorff(nUser, revShrunk)];
    final h = hCandidates.reduce((a, b) => a < b ? a : b);
    final maxD = sqrt(2);
    final ratio = (h / maxD).clamp(0.0, 1.0);
    final score = ((1.0 - ratio) * 100.0);
    return score;
  }

  double compare(List<Offset> userPoints, List<List<List<double>>> target) {
    final sUser = simplify(userPoints, 2.0);
    final targOffsets = _targetToOffsets(target);
    final sTarget = simplify(targOffsets, 1.0);
    final rUser = resample(sUser, resamplePoints);
    final rTarget = resample(sTarget, resamplePoints);
    final nUser = normalize(rUser);
    final nTarget = normalize(rTarget);
    final h = hausdorff(nUser, nTarget);
    final maxD = sqrt(2);
    final ratio = (h / maxD).clamp(0.0, 1.0);
    final score = ((1.0 - ratio) * 100.0);
    return score;
  }

  double compareNormalized(List<Offset> userPoints, List<List<List<double>>> target) {
    final raw = compare(userPoints, target);
    return _scoreToSimilarity(raw);
  }

  Map<String, dynamic> comparePerStroke(List<List<Offset>> userStrokes, List<List<List<double>>> target) {
    final results = <double>[];
    final targetOffsetsPerStroke = target.map((s) => _toOffsets(s)).toList();
    final n = max(userStrokes.length, targetOffsetsPerStroke.length);
    for (var i = 0; i < n; i++) {
      final user = i < userStrokes.length ? userStrokes[i] : <Offset>[];
      final targ = i < targetOffsetsPerStroke.length ? targetOffsetsPerStroke[i] : <Offset>[];
      if (user.isEmpty || targ.isEmpty) {
        results.add(0.0);
        continue;
      }
      final rawScore = _compareOffsets(user, targ);
      results.add(rawScore);
    }

    final avg = results.isEmpty ? 0.0 : results.reduce((a, b) => a + b) / results.length;
    final perSim = results.map((r) => _scoreToSimilarity(r)).toList();
    final perOk = perSim.map((s) => s >= correctThreshold).toList();
    final avgSim = perSim.isEmpty ? 0.0 : perSim.reduce((a, b) => a + b) / perSim.length;
    return {
      'perStrokeRaw': results,
      'perStrokeSim': perSim,
      'perStrokeOk': perOk,
      'averageRaw': avg,
      'averageSim': avgSim
    };
  }
}
