import 'package:flutter/material.dart';
import '../services/hanzi_loader.dart';
import 'practice_screen.dart';

class CharacterListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const CharacterListScreen({required this.onToggleTheme, required this.isDark, super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final HanziLoader _loader = HanziLoader();
  List<String> _chars = ['中','人','大'];
  List<String> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // defer loading to after first frame so we can use DefaultAssetBundle
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await _loader.loadFromAssetBundle(DefaultAssetBundle.of(context));
      final sample = _loader.sampleCharacters(200);
      if (sample.isNotEmpty) {
        setState(() {
          _chars = sample;
          _filtered = List<String>.from(sample);
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  // Normalize pinyin by removing diacritics and lowercasing to make searches
  // accent-insensitive. This mapping covers common pinyin diacritics.
  String _stripDiacritics(String s) {
    if (s.isEmpty) return s;
    final map = {
      'ā':'a','á':'a','ǎ':'a','à':'a','Ā':'A','Á':'A','Ǎ':'A','À':'A',
      'ē':'e','é':'e','ě':'e','è':'e','Ē':'E','É':'E','Ě':'E','È':'E',
      'ī':'i','í':'i','ǐ':'i','ì':'i','Ī':'I','Í':'I','Ǐ':'I','Ì':'I',
      'ō':'o','ó':'o','ǒ':'o','ò':'o','Ō':'O','Ó':'O','Ǒ':'O','Ò':'O',
      'ū':'u','ú':'u','ǔ':'u','ù':'u','Ū':'U','Ú':'U','Ǔ':'U','Ù':'U',
      'ǖ':'u','ǘ':'u','ǚ':'u','ǜ':'u','ü':'u','Ü':'U'
    };
    final buf = StringBuffer();
    for (var r in s.runes) {
      final ch = String.fromCharCode(r);
      buf.write(map.containsKey(ch) ? map[ch] : ch);
    }
    return buf.toString().toLowerCase();
  }

  void _applyFilter(String q) {
    final qtrim = q.trim().toLowerCase();
    if (qtrim.isEmpty) {
      setState(() => _filtered = List<String>.from(_chars));
      return;
    }
    final qNoDia = _stripDiacritics(qtrim);
    final out = <String>[];
    for (var ch in _chars) {
      // direct character contains
      if (ch.contains(qtrim)) {
        out.add(ch);
        continue;
      }
      // pinyin match (ignore diacritics)
      final pinyinList = _loader.getPinyin(ch).map((e) => _stripDiacritics(e)).toList();
      final pJoined = pinyinList.join(' ');
      if (pJoined.contains(qNoDia)) {
        out.add(ch);
        continue;
      }
      // definition / meaning match
      final entry = _loader.getCharacterDictEntry(ch);
      if (entry != null && entry.containsKey('definition')) {
        final def = entry['definition'].toString().toLowerCase();
        if (def.contains(qtrim) || _stripDiacritics(def).contains(qNoDia)) {
          out.add(ch);
          continue;
        }
      }
    }
    setState(() => _filtered = out);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a character'),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by character, pinyin, or definion...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _applyFilter,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final ch = _filtered[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PracticeScreen(),
                            settings: RouteSettings(arguments: ch),
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              ch,
                              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                            ),
                          ),
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
