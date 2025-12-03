import 'dart:async';
import 'package:flutter/material.dart';
import '../services/hanzi_loader.dart';
import '../services/stroke_engine.dart';
import '../services/audio_service.dart';
import 'dart:math';
import 'dart:ui';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  // Lista de trazos completados por el usuario. Cada trazo es una lista de offsets.
  List<List<Offset>> _strokes = [];
  // trazo en curso
  List<Offset> _currentStroke = [];
  String _char = '中';
  double _score = 0.0;
  late final AudioService _audio;
  // Control de animación de trazos objetivo
  bool _animating = false;
  // whether to flip visual/target vertically (keeps visual and matching consistent)
  bool _flipVertical = true;
  bool _showMedian = false;
  // median strokes prepared for overlay (offsets in source coords)
  List<List<Offset>> _medianDisplay = [];
  List<List<Offset>> _targetForMedian = [];
  // dict entry fields to display
  String? _pinyinText;
  String? _definitionText;
  String? _radicalText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) _char = arg;
    // load dict info for this character
    _loadDictInfo();
    _audio = AudioService();
  }

  Future<void> _loadDictInfo() async {
    final loader = HanziLoader();
    await loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
    final entry = loader.getCharacterDictEntry(_char);
    setState(() {
      if (entry == null) {
        _pinyinText = null;
        _definitionText = null;
        _radicalText = null;
      } else {
        final p = entry['pinyin'];
        if (p is List) _pinyinText = p.join(', ');
        else if (p is String) _pinyinText = p;
        else _pinyinText = null;

        final d = entry['definition'];
        _definitionText = (d is String) ? d : null;

        final r = entry['radical'];
        _radicalText = (r is String) ? r : null;
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Use localPosition so coordinates are relative to the GestureDetector area
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _onPanStart(DragStartDetails details) {
    // Use localPosition so coordinates are relative to the GestureDetector area
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  Future<void> _onPanEnd() async {
    // Finalizar trazo actual
    setState(() {
      if (_currentStroke.isNotEmpty) _strokes.add(List.of(_currentStroke));
      _currentStroke = [];
    });

    // Comparar por trazos si tenemos datos objetivo
    final loader = HanziLoader();
    await loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
    // prefer medians (skeleton) if available
    final med = loader.getCharacterMedianStrokeData(_char);
    final rawTarget = (med.isNotEmpty) ? med : loader.getCharacterStrokeData(_char);
    final target = _maybeFlipRawTarget(rawTarget, _flipVertical);

    final engine = StrokeEngine();
    final res = engine.comparePerStroke(_strokes, target);
    // stroke_engine returns normalized similarities in 'perStrokeSim' (0..1)
    _score = (res['averageSim'] as double) * 100.0;
    setState(() {});
  }

  // If flipVertical is true, return a vertically mirrored copy of the raw target data
  // raw: List<stroke> where stroke: List<[x,y]>
  List<List<List<double>>> _maybeFlipRawTarget(List<List<List<double>>> raw, bool flip) {
    if (!flip) return raw;
    // compute global minY and maxY
    double minY = double.infinity, maxY = -double.infinity;
    for (var stroke in raw) {
      for (var p in stroke) {
        final y = p[1];
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
    if (minY == double.infinity) return raw;
    final sum = minY + maxY;
    return raw.map((stroke) => stroke.map((p) => [p[0], sum - p[1]]).toList()).toList();
  }

  void _clearCanvas() {
    setState(() {
      _strokes = [];
      _currentStroke = [];
      _score = 0.0;
    });
  }

  void _next() {
    // For scaffold: go back to select for now
    Navigator.pop(context);
  }

  void _toggleAnimation() {
    setState(() {
      _animating = !_animating;
    });
  }

  Future<void> _updateMedianDisplay() async {
    final loader = HanziLoader();
    await loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
    final medRaw = loader.getCharacterMedianStrokeData(_char);
    final raw = loader.getCharacterStrokeData(_char);
    debugPrint('HanziLoader: medians for $_char -> ${medRaw.length} strokes, raw -> ${raw.length} strokes');
    setState(() {
      _medianDisplay = medRaw.map((s) => s.map((p) => Offset(p[0], p[1])).toList()).toList();
      _targetForMedian = raw.map((s) => s.map((p) => Offset(p[0], p[1])).toList()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Header area (character, pinyin, definition, radical)
    final headerArea = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  // Play pronunciation when character tapped (prefer the character itself)
                  final toSpeak = _char;
                  await _audio.speak(toSpeak);
                },
                child: Text(_char, style: const TextStyle(fontSize: 120)),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.volume_up),
                tooltip: 'Play pronunciation',
                onPressed: () async {
                  final toSpeak = _char;
                  await _audio.speak(toSpeak);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_pinyinText != null)
            Text(
              _pinyinText!,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black54,
              ),
            ),
          if (_definitionText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: SizedBox(
                width: 420,
                child: Text(
                  _definitionText!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_radicalText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                'Radical: ${_radicalText!}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );

    // Drawing area (extracted to reuse in both orientations)
    final drawArea = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        color: Colors.white,
        child: ClipRect(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SketchPainterMulti(strokes: _strokes, current: _currentStroke, debugMode: false),
                    size: Size.infinite,
                  ),
                ),
                if (_showMedian && !_animating && _medianDisplay.isNotEmpty && _targetForMedian.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MedianOverlayPainter(targetStrokes: _targetForMedian, medianStrokes: _medianDisplay, flipVertical: _flipVertical),
                      size: Size.infinite,
                    ),
                  ),
                if (_animating)
                  Positioned.fill(
                    child: TargetStrokeAnimator(character: _char, flipVertical: _flipVertical, showMedian: _showMedian),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pinyinText ?? _char,
          style: TextStyle(
            fontSize: 22,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // In portrait stack vertically; in landscape put header and drawing side-by-side
          Expanded(
            child: isPortrait
                ? Column(
                    children: [
                      Expanded(flex: 5, child: headerArea),
                      Expanded(flex: 5, child: drawArea),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 4, child: headerArea),
                      Expanded(flex: 6, child: drawArea),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Score: ${_score.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ElevatedButton(onPressed: _clearCanvas, child: const Text('Repeat')),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: _toggleAnimation, child: Text(_animating ? 'Stop' : 'Stroke order')),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Show median'),
                            const SizedBox(width: 8),
                            Switch(
                              value: _showMedian,
                              activeColor: Theme.of(context).colorScheme.primary,
                              onChanged: (v) async {
                                setState(() => _showMedian = v);
                                if (v) await _updateMedianDisplay();
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// lightweight single-stroke painter removed (unused). Keep the Multi-stroke painter below.

class _SketchPainterMulti extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;
  final bool debugMode;
  _SketchPainterMulti({required this.strokes, required this.current, this.debugMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure the drawing area is always white regardless of app theme
    // (draw an explicit white background to avoid theme/parent color bleed-through)
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    // Volumetric brush parameters (tweakable)
    final double brushMultiplier = 6.0; // base radius multiplier (reduced further)
    final double pressureFactor = 0.06; // how strongly speed reduces radius
    final double minRadius = 2.0; // minimum radius in px
    final double maxRadius = 16.0; // maximum radius in px
    final double maxGap = 24.0; // densify gap in px (increased for performance)

    // Helper: densify polyline to ensure maxGap
    List<Offset> densifyPts(List<Offset> pts, double gap) {
      if (pts.length < 2) return List<Offset>.from(pts);
      final out = <Offset>[];
      for (var i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        out.add(a);
        final d = (b - a).distance;
        if (d > gap) {
          final n = (d / gap).ceil();
          for (var k = 1; k < n; k++) {
            final t = k / n;
            out.add(Offset(lerpDouble(a.dx, b.dx, t)!, lerpDouble(a.dy, b.dy, t)!));
          }
        }
      }
      out.add(pts.last);
      return out;
    }

    // Compute radii per point based on local 'speed' (distance between points)
    // and curvature (angle change). Faster moves -> thinner stroke. Tight
    // turns -> thicker stroke to simulate brush pressure.
    List<double> computeRadii(List<Offset> pts) {
      final n = pts.length;
      final radii = List<double>.filled(n, brushMultiplier);
      if (n == 0) return radii;
      // heuristic speed divisor based on brush size
      final speedDiv = 10.0 + brushMultiplier * 0.8;
      for (var i = 0; i < n; i++) {
        double speed = 0.0;
        if (i > 0) speed = (pts[i] - pts[i - 1]).distance;
        // curvature
        double curvature = 0.0;
        if (i > 0 && i < n - 1) {
          final v1 = pts[i] - pts[i - 1];
          final v2 = pts[i + 1] - pts[i];
          final a = v1.distance;
          final b = v2.distance;
          if (a > 0 && b > 0) {
            final dot = (v1.dx * v2.dx + v1.dy * v2.dy) / (a * b);
            curvature = acos(dot.clamp(-1.0, 1.0));
          }
        }
        // speed factor: faster -> thinner (map to 0.3..1.0)
        final speedFactor = (1.0 - (speed * pressureFactor / speedDiv)).clamp(0.35, 1.0);
        // curvature factor: tighter curve -> slightly thicker
        final curvatureFactor = (1.0 + (curvature / pi) * 0.6).clamp(1.0, 1.6);
        var r = brushMultiplier * curvatureFactor * speedFactor;
        // taper near ends for smoother pick-up/drop
        final taperLen = min(4, n ~/ 4 + 1);
        if (i < taperLen) {
          final tf = (i + 1) / (taperLen + 1);
          r *= (0.5 + 0.5 * tf);
        } else if (i >= n - taperLen) {
          final ti = n - i;
          final tf = (ti) / (taperLen + 1);
          r *= (0.5 + 0.5 * tf);
        }
        radii[i] = r.clamp(minRadius, maxRadius);
      }
              // smooth radii to avoid abrupt jumps (single pass for performance)
      final tmp = List<double>.from(radii);
      for (var i = 1; i < n - 1; i++) tmp[i] = (radii[i - 1] + radii[i] + radii[i + 1]) / 3.0;
      for (var i = 1; i < n - 1; i++) radii[i] = tmp[i];
      return radii;
    }

    // Catmull-Rom spline smoothing / upsampling. Returns a new list of points
    // interpolated between the input control points. `segments` controls how
    // many samples per original segment to generate (higher -> smoother).
    List<Offset> catmullRomSpline(List<Offset> pts, int segments) {
      if (pts.length < 2) return List<Offset>.from(pts);
      final out = <Offset>[];
      // duplicate endpoints for proper endpoint interpolation
      final p = <Offset>[];
      p.add(pts.first);
      p.addAll(pts);
      p.add(pts.last);

      for (var i = 1; i < p.length - 2; i++) {
        final p0 = p[i - 1];
        final p1 = p[i];
        final p2 = p[i + 1];
        final p3 = p[i + 2];

        for (var j = 0; j < segments; j++) {
          final t = j / segments;
          final t2 = t * t;
          final t3 = t2 * t;

          final x = 0.5 * ((2 * p1.dx) + (-p0.dx + p2.dx) * t + (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 + (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);
          final y = 0.5 * ((2 * p1.dy) + (-p0.dy + p2.dy) * t + (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 + (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);
          out.add(Offset(x, y));
        }
      }
      // ensure last control point is included
      out.add(pts.last);
      return out;
    }

    // 'fill' removed - primaryPaint/softPaint used for rendering
    // Soft paint for edges (no blur for Android performance)
    final softPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Connector/primary paint
    final primaryPaint = Paint()..color = Colors.black..style = PaintingStyle.fill..isAntiAlias = true;

    // For each user stroke, build a volumetric brush by placing oriented
    // ovals at centers and connecting them with quads. Densify first so
    // long segments are sampled sufficiently.
    for (var s in strokes) {
      if (s.isEmpty) continue;
      if (s.length == 1) {
        final r = max(minRadius, brushMultiplier);
        // immediate dot with soft edge
        canvas.drawCircle(s.first, r, primaryPaint);
        canvas.drawCircle(s.first, r * 1.1, softPaint);
        continue;
      }

      final dense = densifyPts(s, maxGap);
      final smooth = catmullRomSpline(dense, 1);
      if (smooth.length < 2) {
        canvas.drawCircle(smooth.first, brushMultiplier, primaryPaint);
        continue;
      }

      final radii = computeRadii(smooth);
      final n = smooth.length;

      // compute directions and normals
      final angles = List<double>.filled(n, 0.0);
      final normals = List<Offset>.filled(n, Offset.zero);
      for (var i = 0; i < n; i++) {
        Offset dir;
        if (i == 0) dir = (smooth[1] - smooth[0]);
        else if (i == n - 1) dir = (smooth[n - 1] - smooth[n - 2]);
        else dir = (smooth[i + 1] - smooth[i - 1]);
        final len = dir.distance;
        if (len == 0) dir = const Offset(1, 0);
        else dir = Offset(dir.dx / len, dir.dy / len);
        angles[i] = atan2(dir.dy, dir.dx);
        normals[i] = Offset(-dir.dy, dir.dx);
      }

      // draw ovals and connectors
      for (var i = 0; i < n; i++) {
        final c = smooth[i];
        final r = radii[i];
        final angle = angles[i];
        // oval dimensions: longer along travel direction
        final long = r * 1.4;
        final lat = max(r * 0.85, r - 0.5);

        // draw soft outer oval
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(angle);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: long * 2, height: lat * 2), softPaint);
        // inner pigment concentration
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: long * 1.05, height: lat * 1.0), primaryPaint);
        canvas.restore();

        // connector to next
        if (i < n - 1) {
          final a = smooth[i];
          final b = smooth[i + 1];
          final ra = radii[i];
          final rb = radii[i + 1];
          final na = normals[i];
          final nb = normals[i + 1];
          final p1 = Offset(a.dx + na.dx * ra, a.dy + na.dy * ra);
          final p2 = Offset(b.dx + nb.dx * rb, b.dy + nb.dy * rb);
          final p3 = Offset(b.dx - nb.dx * rb, b.dy - nb.dy * rb);
          final p4 = Offset(a.dx - na.dx * ra, a.dy - na.dy * ra);
          final seg = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
          canvas.drawPath(seg, primaryPaint);
          canvas.drawPath(seg, softPaint);
        }
      }

      
    }

    // current stroke feedback: immediate dot + ongoing volumetric stroke
    if (current.isNotEmpty) {
      // immediate dot
      final last = current.last;
      canvas.drawCircle(last, brushMultiplier * 0.9, primaryPaint);
      canvas.drawCircle(last, brushMultiplier * 1.05, softPaint);

      if (current.length == 1) {
        // done
      } else {
        final denseCur = densifyPts(current, maxGap);
        final smoothCur = (denseCur.length < 4) ? denseCur : catmullRomSpline(denseCur, 3);
        final radiiCur = computeRadii(smoothCur);
        final ncur = smoothCur.length;
        final anglesCur = List<double>.filled(ncur, 0.0);
        final normalsCur = List<Offset>.filled(ncur, Offset.zero);
        for (var i = 0; i < ncur; i++) {
          Offset dir;
          if (i == 0) dir = (smoothCur[min(1, ncur - 1)] - smoothCur[0]);
          else if (i == ncur - 1) dir = (smoothCur[ncur - 1] - smoothCur[ncur - 2]);
          else dir = (smoothCur[i + 1] - smoothCur[i - 1]);
          final len = dir.distance;
          if (len == 0) dir = const Offset(1, 0);
          else dir = Offset(dir.dx / len, dir.dy / len);
          anglesCur[i] = atan2(dir.dy, dir.dx);
          normalsCur[i] = Offset(-dir.dy, dir.dx);
        }
        for (var i = 0; i < ncur; i++) {
          final c = smoothCur[i];
          final r = radiiCur[i];
          final angle = anglesCur[i];
          final long = r * 1.4;
          final lat = max(r * 0.85, r - 0.5);
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(angle);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: long * 2, height: lat * 2), softPaint);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: long * 1.05, height: lat * 1.0), primaryPaint);
          canvas.restore();
          if (i < ncur - 1) {
            final a = smoothCur[i];
            final b = smoothCur[i + 1];
            final ra = radiiCur[i];
            final rb = radiiCur[i + 1];
            final na = normalsCur[i];
            final nb = normalsCur[i + 1];
            final p1 = Offset(a.dx + na.dx * ra, a.dy + na.dy * ra);
            final p2 = Offset(b.dx + nb.dx * rb, b.dy + nb.dy * rb);
            final p3 = Offset(b.dx - nb.dx * rb, b.dy - nb.dy * rb);
            final p4 = Offset(a.dx - na.dx * ra, a.dy - na.dy * ra);
            final seg = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
            canvas.drawPath(seg, primaryPaint);
            canvas.drawPath(seg, softPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SketchPainterMulti oldDelegate) => oldDelegate.strokes != strokes || oldDelegate.current != current;
}

// Painter to draw median skeleton overlay using the same transform logic as _TargetPainter
class _MedianOverlayPainter extends CustomPainter {
  final List<List<Offset>> targetStrokes;
  final List<List<Offset>> medianStrokes;
  final bool flipVertical;
  _MedianOverlayPainter({required this.targetStrokes, required this.medianStrokes, this.flipVertical = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (targetStrokes.isEmpty || medianStrokes.isEmpty) return;

    // compute bounding box from target strokes
    double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (var s in targetStrokes) {
      for (var p in s) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }
    if (minX == double.infinity) return;

    final dataW = maxX - minX;
    final dataH = maxY - minY;
    final availW = size.width * 0.9;
    final availH = size.height * 0.9;
    final scale = (dataW == 0 && dataH == 0)
        ? 1.0
        : min(availW / (dataW == 0 ? 1.0 : dataW), availH / (dataH == 0 ? 1.0 : dataH));

    final leftOffset = (size.width - (dataW * scale)) / 2.0;
    final offsetY = (size.height - (dataH * scale)) / 2.0 - minY * scale;

    Offset transform(Offset p) {
      if (!flipVertical) return Offset((p.dx - minX) * scale + leftOffset, p.dy * scale + offsetY);
      return Offset((p.dx - minX) * scale + leftOffset, (maxY - p.dy) * scale + offsetY);
    }

    // densify helper
    List<Offset> densify(List<Offset> pts, double maxGap) {
      if (pts.length < 2) return pts;
      final out = <Offset>[];
      for (var i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        out.add(a);
        final d = (b - a).distance;
        if (d > maxGap) {
          final n = (d / maxGap).ceil();
          for (var k = 1; k < n; k++) {
            final t = k / n;
            out.add(Offset(lerpDouble(a.dx, b.dx, t)!, lerpDouble(a.dy, b.dy, t)!));
          }
        }
      }
      out.add(pts.last);
      return out;
    }

    final medianPaint = Paint()
      ..color = Colors.red.withOpacity(0.9)
      ..strokeWidth = max(1.0, 2.0 * scale)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final maxGap = 8.0;
    for (var ms in medianStrokes) {
      if (ms.isEmpty) continue;
      final tms = ms.map(transform).toList();
      final dms = densify(tms, maxGap);
      final path = Path();
      path.moveTo(dms.first.dx, dms.first.dy);
      for (var p in dms.skip(1)) path.lineTo(p.dx, p.dy);
      canvas.drawPath(path, medianPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MedianOverlayPainter oldDelegate) => oldDelegate.medianStrokes != medianStrokes || oldDelegate.targetStrokes != targetStrokes || oldDelegate.flipVertical != flipVertical;
}

// Simple animator that reads target strokes from HanziLoader and draws them in order.
class TargetStrokeAnimator extends StatefulWidget {
  final String character;
  final bool flipVertical;
  final bool showMedian;
  const TargetStrokeAnimator({required this.character, this.flipVertical = false, this.showMedian = false, super.key});

  @override
  State<TargetStrokeAnimator> createState() => _TargetStrokeAnimatorState();
}

class _TargetStrokeAnimatorState extends State<TargetStrokeAnimator> with SingleTickerProviderStateMixin {
  List<List<Offset>> _target = [];
  // internal centerline representation (used for detection/matching if needed)
  // center targets removed (unused) - previously generated but not used now
  List<List<Offset>> _median = [];
  int _visible = 0;
  late AnimationController _ctrl;
  double _progress = 0.0; // 0..1 for current stroke reveal

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _ctrl.addListener(() {
      if (!mounted) return;
      setState(() {
        _progress = _ctrl.value;
      });
    });
    _load();
  }

  Future<void> _load() async {
    final loader = HanziLoader();
    await loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
    final raw = loader.getCharacterStrokeData(widget.character);
    final medRaw = loader.getCharacterMedianStrokeData(widget.character);
    debugPrint('TargetStrokeAnimator: loaded ${raw.length} target strokes, ${medRaw.length} median strokes for ${widget.character} (flip=${widget.flipVertical})');
    setState(() {
      // keep raw strokes for animation/drawing (so visual behavior remains unchanged)
      _target = raw.map((s) => s.map((p) => Offset(p[0], p[1])).toList()).toList();
      _median = medRaw.map((s) => s.map((p) => Offset(p[0], p[1])).toList()).toList();
      // centerline computation left in code for future use, not stored here
      _visible = 0;
    });
    _start();
  }

  // centerline detection/resampling helpers removed (unused). Keep code lean.

  void _start() {
    // Animate each stroke one after another. For each stroke, animate _progress 0..1
    Future.microtask(() async {
      for (var i = 0; i < _target.length; i++) {
        if (!mounted) break;
        setState(() {
          _visible = i; // index of currently animating stroke
          _progress = 0.0;
        });
        try {
          await _ctrl.forward(from: 0.0);
        } catch (_) {
          // animation was disposed
          break;
        }
        // small pause between strokes
        await Future.delayed(const Duration(milliseconds: 120));
      }
      // leave final stroke visible fully
      if (mounted) setState(() => _progress = 1.0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TargetPainter(
        strokes: _target,
        visible: _visible,
        progress: _progress,
        flipVertical: widget.flipVertical,
        medianStrokes: _median,
        showMedian: widget.showMedian,
      ),
      size: Size.infinite,
    );
  }
}

class _TargetPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final int visible;
  final double progress;
  final bool flipVertical;
  final List<List<Offset>>? medianStrokes;
  final bool showMedian;
  _TargetPainter({required this.strokes, required this.visible, this.progress = 0.0, this.flipVertical = false, this.medianStrokes, this.showMedian = false});

  @override
  void paint(Canvas canvas, Size size) {
    // ensure target animation background is white as well
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    if (strokes.isEmpty) return;

    // Compute bounding box of all visible strokes to scale/center them to the canvas
    double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (var s in strokes) {
      for (var p in s) {
        minX = min(minX, p.dx);
        minY = min(minY, p.dy);
        maxX = max(maxX, p.dx);
        maxY = max(maxY, p.dy);
      }
    }
    if (minX == double.infinity) return;

    final dataW = maxX - minX;
    final dataH = maxY - minY;
    final availW = size.width * 0.9; // leave margins
    final availH = size.height * 0.9;
    final scale = (dataW == 0 && dataH == 0)
        ? 1.0
        : min(availW / (dataW == 0 ? 1.0 : dataW), availH / (dataH == 0 ? 1.0 : dataH));

    // center offset to place strokes in the middle of canvas
    final leftOffset = (size.width - (dataW * scale)) / 2.0;
    final offsetY = (size.height - (dataH * scale)) / 2.0 - minY * scale;

    // helper: transform a point from data coords to canvas coords
    Offset transform(Offset p) {
      if (!flipVertical) return Offset((p.dx - minX) * scale + leftOffset, p.dy * scale + offsetY);
      // mirrored inside the data bounding box vertically: reflect around horizontal axis of the data bbox
      return Offset((p.dx - minX) * scale + leftOffset, (maxY - p.dy) * scale + offsetY);
    }

    // helper: insert intermediate points if distance between points is large
    List<Offset> densify(List<Offset> pts, double maxGap) {
      if (pts.length < 2) return pts;
      final out = <Offset>[];
      for (var i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        out.add(a);
        final d = (b - a).distance;
        if (d > maxGap) {
          final n = (d / maxGap).ceil();
          for (var k = 1; k < n; k++) {
            final t = k / n;
            out.add(Offset(lerpDouble(a.dx, b.dx, t)!, lerpDouble(a.dy, b.dy, t)!));
          }
        }
      }
      out.add(pts.last);
      return out;
    }

    

    // determine reasonable max gap in canvas pixels (smaller -> smoother)
    final maxGap = 8.0; // pixels

    // If requested, draw median skeleton as a thin overlay (draw full path, not animated)
    // Only draw the static median when no progress has started (so animation
    // doesn't leave the median visible on top of the brush fill).
    if (showMedian && medianStrokes != null && medianStrokes!.isNotEmpty && (progress <= 0.0001)) {
      final medianPaint = Paint()
        ..color = Colors.red.withOpacity(0.9)
        ..strokeWidth = max(1.0, 2.0 * scale)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (var ms in medianStrokes!) {
        if (ms.isEmpty) continue;
        final tms = ms.map(transform).toList();
        final dms = densify(tms, maxGap);
        final path = Path();
        path.moveTo(dms.first.dx, dms.first.dy);
        for (var p in dms.skip(1)) path.lineTo(p.dx, p.dy);
        canvas.drawPath(path, medianPaint);
      }
    }

    // Paints: fill for solid interior (dark gray) and thin stroke for outlines
    final strokeW = max(3.0, 3.0 * scale);
    // Multiplier to make the visible brush and animated line slightly larger
    // than the computed stroke width. Adjust this to control overall brush size.
    final brushMultiplier = 1.2;
    final effectiveW = strokeW * brushMultiplier;
    final fillPaint = Paint()
      ..color = Colors.grey[850] ?? const Color(0xFF222222)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    // thin outline paint removed to avoid showing an extra black contour
    // (the fill now defines the visual and the brush line uses the fill color).

    for (var i = 0; i < visible && i < strokes.length; i++) {
      final s = strokes[i];
      if (s.isEmpty) continue;
      // transform and densify
      final transformed = s.map(transform).toList();
      final dense = densify(transformed, maxGap);

      // Treat the stroke data from graphics.json as a closed polygon
      // and fill its interior fully once the stroke is completed.
      final poly = Path();
      poly.addPolygon(dense, true);
      canvas.drawPath(poly, fillPaint);
    }

    // Draw current animating stroke following median path if available
    if (visible >= 0 && visible < strokes.length) {
      final s = strokes[visible];
      if (s.isNotEmpty) {
        final transformed = s.map(transform).toList();
        final dense = densify(transformed, maxGap);

        // Helper: given a dense polyline, return the partial polyline up to
        // progress (0..1) interpolating the final point so the length matches
        // exactly the requested fraction. This avoids jumps when progress
        // falls inside a segment.
        List<Offset> partialPolyline(List<Offset> pts, double prog) {
          final out = <Offset>[];
          if (pts.isEmpty) return out;
          prog = prog.clamp(0.0, 1.0);
          if (pts.length == 1) return [pts.first];

          // compute cumulative distances
          final cum = <double>[0.0];
          for (var i = 1; i < pts.length; i++) cum.add(cum.last + (pts[i] - pts[i - 1]).distance);
          final total = cum.last;
          if (total <= 0) return [pts.first];

          final target = prog * total;
          out.add(pts.first);
          if (target <= 0.0) return [pts.first];

          for (var i = 1; i < pts.length; i++) {
            final segStart = cum[i - 1];
            final segEnd = cum[i];
            if (target >= segEnd) {
              out.add(pts[i]);
              continue;
            }
            // target falls inside this segment -> interpolate
            final segLen = segEnd - segStart;
            final t = (segLen == 0) ? 0.0 : ((target - segStart) / segLen).clamp(0.0, 1.0);
            final a = pts[i - 1];
            final b = pts[i];
            final ip = Offset(lerpDouble(a.dx, b.dx, t)!, lerpDouble(a.dy, b.dy, t)!);
            out.add(ip);
            break;
          }
          return out;
        }

        // Build brush path either from the median partial (preferred) or from
        // the stroke outline partial as a fallback. Use densified points first
        // then compute an exact partial polyline for smooth progression.
        List<Offset> brushPath = [];
        final prog = progress.clamp(0.0, 1.0);

        if (medianStrokes != null && visible < medianStrokes!.length) {
          final ms = medianStrokes![visible];
          if (ms.isNotEmpty) {
            final msTrans = ms.map(transform).toList();
            final msDense = densify(msTrans, maxGap);
            if (msDense.length >= 1) brushPath = partialPolyline(msDense, prog);
          }
        }

        // Fallback: use stroke outline progress
        if (brushPath.isEmpty && dense.length >= 1) {
          brushPath = partialPolyline(dense, prog);
        }

        if (brushPath.length >= 2) {
          // Full polygon for the target stroke
          final fullPoly = Path()..addPolygon(dense, true);

          // If animation finished, paint the full polygon to ensure complete fill
          if (progress >= 0.999) {
            canvas.drawPath(fullPoly, fillPaint);
          } else {
            // Compute nearest distance from each center point to the polygon
            // boundary and build a mask from circles + connecting quads so
            // the revealed area covers the whole stroke interior.
            double pointToSegDist(Offset p, Offset a, Offset b) {
              final vx = b.dx - a.dx;
              final vy = b.dy - a.dy;
              final wx = p.dx - a.dx;
              final wy = p.dy - a.dy;
              final c = vx * wx + vy * wy;
              final d2 = vx * vx + vy * vy;
              double t = (d2 == 0) ? 0.0 : (c / d2);
              t = t.clamp(0.0, 1.0);
              final proj = Offset(a.dx + vx * t, a.dy + vy * t);
              return (p - proj).distance;
            }

            double nearestDistanceToPoly(Offset p, List<Offset> poly) {
              if (poly.length < 2) return double.infinity;
              var best = double.infinity;
              for (var i = 0; i < poly.length - 1; i++) {
                final a = poly[i];
                final b = poly[i + 1];
                best = min(best, pointToSegDist(p, a, b));
              }
              best = min(best, pointToSegDist(p, poly.last, poly.first));
              return best;
            }

            Path buildBrushMask(List<Offset> centers, List<Offset> poly) {
              final mask = Path();
              if (centers.isEmpty) return mask;
              final radii = <double>[];
              for (var c in centers) {
                final nd = nearestDistanceToPoly(c, poly);
                // Inflate the radius a bit to ensure coverage (padding + scale)
                final r = max(effectiveW / 2.0, nd * 1.5 + 2.0);
                radii.add(r);
              }

              for (var i = 0; i < centers.length; i++) {
                final c = centers[i];
                final r = radii[i];
                mask.addOval(Rect.fromCircle(center: c, radius: r));
              }

              for (var i = 0; i < centers.length - 1; i++) {
                final a = centers[i];
                final b = centers[i + 1];
                final ra = radii[i];
                final rb = radii[i + 1];
                final dir = b - a;
                final len = dir.distance;
                if (len == 0) continue;
                final nx = -dir.dy / len;
                final ny = dir.dx / len;
                final p1 = Offset(a.dx + nx * ra, a.dy + ny * ra);
                final p2 = Offset(b.dx + nx * rb, b.dy + ny * rb);
                final p3 = Offset(b.dx - nx * rb, b.dy - ny * rb);
                final p4 = Offset(a.dx - nx * ra, a.dy - ny * ra);
                final seg = Path()
                  ..moveTo(p1.dx, p1.dy)
                  ..lineTo(p2.dx, p2.dy)
                  ..lineTo(p3.dx, p3.dy)
                  ..lineTo(p4.dx, p4.dy)
                  ..close();
                mask.addPath(seg, Offset.zero);
              }

              return mask;
            }

            final brushRegion = buildBrushMask(brushPath, dense);

            canvas.save();
            try {
              canvas.clipPath(brushRegion);
              canvas.drawPath(fullPoly, fillPaint);
            } finally {
              canvas.restore();
            }

            final brushStrokePaint = Paint()
              ..color = fillPaint.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = effectiveW
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..isAntiAlias = true;
            final brushLine = Path();
            brushLine.moveTo(brushPath.first.dx, brushPath.first.dy);
            for (var bp in brushPath.skip(1)) brushLine.lineTo(bp.dx, bp.dy);
            canvas.drawPath(brushLine, brushStrokePaint);
          }
        } else if (brushPath.length == 1) {
          // fallback: draw a small filled circle (no outline) to simulate brush tip
          final pt = (brushPath.isNotEmpty) ? brushPath.first : dense.first;
          final r = max(1.0, effectiveW * 0.5);
          canvas.drawCircle(pt, r, fillPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TargetPainter oldDelegate) =>
      oldDelegate.visible != visible || oldDelegate.strokes != strokes || oldDelegate.showMedian != showMedian || oldDelegate.medianStrokes != medianStrokes || oldDelegate.progress != progress;
}

// animation control handled inside _PracticeScreenState
