import 'package:flutter/material.dart';
import 'package:myapp/bible_lookup_screen.dart';
import 'package:myapp/note_screen.dart';
import 'package:myapp/highlighted_verses_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Study App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleLookupScreen()));
              },
              child: const Text('Bible Lookup'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen(userId: userId)));
              },
              child: const Text('My Notes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HighlightedVersesScreen()));
              },
              child: const Text('Highlighted Verses'),
            ),
          ],
        ),
      ),
    );
  }
}
