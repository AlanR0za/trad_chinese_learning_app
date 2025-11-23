import 'package:flutter/material.dart';
import 'data/lessons.dart';
import 'pages/practice_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese Practice',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<Word> _allWords() {
    final out = <Word>[];
    for (var l in lessons) {
      for (var d in l.dialogues) {
        out.addAll(d.words);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final words = _allWords();
    return Scaffold(
      appBar: AppBar(title: const Text('Chinese Character Practice')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9),
        itemCount: words.length,
        itemBuilder: (c, i) {
          final w = words[i];
          return Card(
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PracticePage(word: w))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(w.chinese, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(w.pinyin, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(w.english, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
