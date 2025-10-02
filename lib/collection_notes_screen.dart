import 'package:flutter/material.dart';
import 'package:kyros/database.dart';
import 'package:kyros/main_note_page.dart';

class CollectionNotesScreen extends StatefulWidget {
  final String userId;
  final Collection collection;

  const CollectionNotesScreen(
      {super.key, required this.userId, required this.collection});

  @override
  State<CollectionNotesScreen> createState() => _CollectionNotesScreenState();
}

class _CollectionNotesScreenState extends State<CollectionNotesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToNotePage({Note? note}) async {
    if (!mounted) return;
    final collections =
        await _firestoreService.getCollections(widget.userId).first;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNotePage(
          userId: widget.userId,
          note: note,
          collections: collections,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _firestoreService.getNotesForCollection(
            widget.userId, widget.collection.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notes in this collection yet.'),
            );
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _navigateToNotePage(note: note),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNotePage(),
        child: const Icon(Icons.add),
      ),
    );
  }
}