import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/lessons.dart';
import '../services/leaderboard_service.dart';

class PracticePage extends StatefulWidget {
  final Word word;

  const PracticePage({super.key, required this.word});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final GlobalKey _repaintKey = GlobalKey();
  List<List<Offset>> strokes = [];
  List<Offset> current = [];
  // expected (authoritative) strokes for this character
  List<List<Offset>> expectedStrokes = [];
  // in-memory store for saved expected strokes per character (keyed by character)
  static final Map<String, List<List<Offset>>> _savedExpected = {};
  bool authoring = false; // when true, drawing edits expectedStrokes instead of strokes
  double similarity = 0.0;
  String username = '';
  final LeaderboardService _leaderboard = LeaderboardService();
  final TextEditingController _userController = TextEditingController();

  void start(Offset p) {
    current = [p];
    if (authoring) {
      expectedStrokes.add(current);
    } else {
      strokes.add(current);
    }
    setState(() {});
  }

  void append(Offset p) {
    current.add(p);
    setState(() {});
  }

  void endStroke() {
    current = [];
    setState(() {});
  }

  void clearCanvas() {
    strokes = [];
    similarity = 0.0;
    setState(() {});
  }

  void clearExpected() {
    expectedStrokes = [];
    _savedExpected.remove(widget.word.chinese);
    setState(() {});
  }

  void saveExpected() {
    // shallow-copy offsets
    final copy = expectedStrokes.map((s) => s.map((p) => Offset(p.dx, p.dy)).toList()).toList();
    _savedExpected[widget.word.chinese] = copy;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expected stroke order saved')));
    setState(() {});
  }

  Future<void> computeSimilarity() async {
    // create two images at same size and compare pixels
    const int size = 256;
    final recorder1 = ui.PictureRecorder();
    final canvas1 = Canvas(recorder1, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
    // draw target character centered
    final tp = TextPainter(
      text: TextSpan(text: widget.word.chinese, style: const TextStyle(color: Colors.black, fontSize: 220)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas1, Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final picture1 = recorder1.endRecording();
    final img1 = await picture1.toImage(size, size);

    final recorder2 = ui.PictureRecorder();
    final canvas2 = Canvas(recorder2, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
    // white background
    final bg = Paint()..color = Colors.white;
    canvas2.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bg);
    // paint strokes scaled to fit
    if (strokes.isNotEmpty) {
      // flatten all points to find bounds
      double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
      for (var s in strokes) {
        for (var p in s) {
          if (p.dx < minX) minX = p.dx;
          if (p.dy < minY) minY = p.dy;
          if (p.dx > maxX) maxX = p.dx;
          if (p.dy > maxY) maxY = p.dy;
        }
      }
      if (minX.isInfinite) {
        minX = 0;
        minY = 0;
        maxX = size.toDouble();
        maxY = size.toDouble();
      }
      final w = (maxX - minX).clamp(1, size.toDouble());
      final h = (maxY - minY).clamp(1, size.toDouble());
      final scale = (size - 20) / (w > h ? w : h);
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final offsetCenter = Offset((size - w * scale) / 2 - minX * scale + 10, (size - h * scale) / 2 - minY * scale + 10);
      for (var s in strokes) {
        final path = Path();
        for (var i = 0; i < s.length; i++) {
          final p = s[i];
          final sp = Offset(p.dx * scale + offsetCenter.dx, p.dy * scale + offsetCenter.dy);
          if (i == 0) {
            path.moveTo(sp.dx, sp.dy);
          } else {
            path.lineTo(sp.dx, sp.dy);
          }
        }
        canvas2.drawPath(path, paint);
      }
    }
    final picture2 = recorder2.endRecording();
    final img2 = await picture2.toImage(size, size);

    final b1 = await img1.toByteData(format: ui.ImageByteFormat.rawRgba);
    final b2 = await img2.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (b1 == null || b2 == null) return;
    final bytes1 = b1.buffer.asUint8List();
    final bytes2 = b2.buffer.asUint8List();
    int diff = 0;
    for (var i = 0; i < bytes1.length; i += 4) {
      // compare luminance-like value per pixel
      final r1 = bytes1[i];
      final g1 = bytes1[i + 1];
      final b_1 = bytes1[i + 2];
      final lum1 = (0.299 * r1 + 0.587 * g1 + 0.114 * b_1).round();

      final r2 = bytes2[i];
      final g2 = bytes2[i + 1];
      final b_2 = bytes2[i + 2];
      final lum2 = (0.299 * r2 + 0.587 * g2 + 0.114 * b_2).round();

      diff += (lum1 - lum2).abs();
    }
    final maxDiff = 255 * (size * size);
    final score = (1.0 - (diff / maxDiff)).clamp(0.0, 1.0);
    if (!mounted) return;
    setState(() {
      similarity = score * 100.0;
    });
    // if expected is available, also compute stroke-order match
    final saved = _savedExpected[widget.word.chinese];
    if (saved != null && saved.isNotEmpty && strokes.isNotEmpty) {
      final minLen = saved.length < strokes.length ? saved.length : strokes.length;
      int matched = 0;
      for (var i = 0; i < minLen; i++) {
        final sExp = saved[i];
        final sDraw = strokes[i];
        if (sExp.isEmpty || sDraw.isEmpty) continue;
        final startExp = sExp.first;
        final startDraw = sDraw.first;
          final dx = startExp.dx - startDraw.dx;
          final dy = startExp.dy - startDraw.dy;
          final dist = math.sqrt(dx * dx + dy * dy);
        // threshold relative to canvas (use 40 px)
        if (dist <= 40.0) matched++;
      }
      final orderScore = (matched / saved.length) * 100.0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order match ${matched}/${saved.length} => ${orderScore.toStringAsFixed(0)}%')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    // if there's a saved expected in persistent map load into runtime
    final saved = _savedExpected[widget.word.chinese];
    if (saved != null) expectedStrokes = saved.map((s) => s.map((p) => Offset(p.dx, p.dy)).toList()).toList();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString('username') ?? '';
    if (!mounted) return;
    setState(() {
      username = u;
      _userController.text = u;
    });
  }

  Future<void> _saveUsername(String u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', u);
    setState(() => username = u);
  }

  Future<void> _submitScore() async {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set a username first')));
      return;
    }
    final ok = await _leaderboard.submitScore(username, widget.word.chinese, similarity);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score submitted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit')));
    }
  }

  Future<void> _showLeaderboard() async {
    final list = await _leaderboard.getLeaderboard(widget.word.chinese);
    if (!mounted) return;
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text('Leaderboard: ${widget.word.chinese}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (c, i) {
              final row = list[i];
              return ListTile(
                title: Text(row['username'] ?? ''),
                trailing: Text((row['best_score'] ?? 0).toString()),
                subtitle: Text(row['last_at'] ?? ''),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      );
    });
  }

  // Render the reference character into an offscreen image and extract dark pixel coordinates.
  Future<List<List<num>>> _renderReferencePoints({int size = 256, int threshold = 200, int maxPoints = 2000}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
    final tp = TextPainter(
      text: TextSpan(text: widget.word.chinese, style: TextStyle(color: Colors.black, fontSize: size * 0.85)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null) return [];
    final bytes = bd.buffer.asUint8List();
    final pts = <List<num>>[];
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final i = (y * size + x) * 4;
        final r = bytes[i];
        final g = bytes[i + 1];
        final b = bytes[i + 2];
        final lum = (0.299 * r + 0.587 * g + 0.114 * b).round();
        if (lum < threshold) pts.add([x, y]);
      }
    }
    if (pts.length > maxPoints) {
      final step = pts.length / maxPoints;
      final sampled = <List<num>>[];
      for (var i = 0; i < maxPoints; i++) sampled.add(pts[(i * step).floor()]);
      return sampled;
    }
    return pts;
  }

  // Flatten strokes (List<List<Offset>>) into an ordered list of [x,y].
  List<List<num>> _flattenStrokesToPoints() {
    final out = <List<num>>[];
    for (var s in strokes) {
      for (var p in s) {
        out.add([p.dx, p.dy]);
      }
    }
    return out;
  }

  Future<void> _checkOnline() async {
    final drawn = _flattenStrokesToPoints();
    if (drawn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draw something first')));
      return;
    }
    final reference = await _renderReferencePoints();
    if (reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to render reference')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending contours to server...')));
    final resp = await _leaderboard.compareContours(reference: reference, drawn: drawn, username: username.isEmpty ? null : username, character: widget.word.chinese);
    if (!mounted) return;
    if (resp == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server error')));
      return;
    }
    final s = (resp['score'] is num) ? (resp['score'] as num).toDouble() : null;
    if (!mounted) return;
    setState(() {
      if (s != null) similarity = s * 100.0;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Online score: ${s != null ? (s * 100).toStringAsFixed(1) + '%' : 'N/A'}')));
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    return Scaffold(
      appBar: AppBar(title: Text('${word.chinese} — ${word.pinyin}')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  // faded target character
                  Center(
                    child: Text(word.chinese,
                        style: const TextStyle(color: Color.fromRGBO(128, 128, 128, 0.3), fontSize: 160)),
                  ),
                  // drawing area
                  GestureDetector(
                    onPanStart: (e) => start(e.localPosition),
                    onPanUpdate: (e) => append(e.localPosition),
                    onPanEnd: (e) => endStroke(),
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _StrokePainter(strokes: strokes),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(onPressed: clearCanvas, child: const Text('Clear')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: computeSimilarity, child: const Text('Check similarity')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _checkOnline, child: const Text('Check online')),
                const SizedBox(width: 8),
                Text('Similarity: ${similarity.toStringAsFixed(1)}%'),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      authoring = !authoring;
                      if (authoring) {
                        // load saved expected if present
                        expectedStrokes = _savedExpected[widget.word.chinese]?.map((s) => s.map((p) => Offset(p.dx, p.dy)).toList()).toList() ?? [];
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authoring mode ON - draw expected strokes')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authoring mode OFF')));
                      }
                    });
                  },
                  child: Text(authoring ? 'Authoring: ON' : 'Authoring: OFF'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: saveExpected, child: const Text('Save expected')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: clearExpected, child: const Text('Clear expected')),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _userController,
                    decoration: const InputDecoration(labelText: 'Username', isDense: true),
                    onSubmitted: (v) => _saveUsername(v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _saveUsername(_userController.text), child: const Text('Save user')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _submitScore, child: const Text('Submit score')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _showLeaderboard, child: const Text('View leaderboard')),
                const Spacer(),
                Text(word.english),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: strokes.length,
              itemBuilder: (c, i) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Stroke ${i + 1}'),
                      SizedBox(
                        width: 80,
                        height: 60,
                        child: CustomPaint(
                          painter: _MiniStrokePainter(stroke: strokes[i]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _StrokePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < strokes.length; i++) {
      final s = strokes[i];
      final path = Path();
      for (var j = 0; j < s.length; j++) {
        if (j == 0) {
          path.moveTo(s[j].dx, s[j].dy);
        } else {
          path.lineTo(s[j].dx, s[j].dy);
        }
      }
      canvas.drawPath(path, paint);
      if (s.isNotEmpty) {
        final dot = Paint()..color = Colors.red;
        canvas.drawCircle(s.first, 10, dot);
        final tp = TextPainter(
          text: TextSpan(text: '${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 10)),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, s.first - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniStrokePainter extends CustomPainter {
  final List<Offset> stroke;

  _MiniStrokePainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    if (stroke.isEmpty) return;
    double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (var p in stroke) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    final w = (maxX - minX).clamp(1, size.width);
    final h = (maxY - minY).clamp(1, size.height);
    final scale = (size.width - 4) / (w > h ? w : h);
    final offsetCenter = Offset((size.width - w * scale) / 2 - minX * scale + 2, (size.height - h * scale) / 2 - minY * scale + 2);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < stroke.length; i++) {
      final p = stroke[i];
      final sp = Offset(p.dx * scale + offsetCenter.dx, p.dy * scale + offsetCenter.dy);
      if (i == 0) {
        path.moveTo(sp.dx, sp.dy);
      } else {
        path.lineTo(sp.dx, sp.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
