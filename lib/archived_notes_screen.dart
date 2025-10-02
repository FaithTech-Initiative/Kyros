import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyros/database.dart';
import 'package:kyros/main_note_page.dart';

class ArchivedNotesScreen extends StatefulWidget {
  const ArchivedNotesScreen({super.key});

  @override
  State<ArchivedNotesScreen> createState() => _ArchivedNotesScreenState();
}

class _ArchivedNotesScreenState extends State<ArchivedNotesScreen> {
  final firestoreService = FirestoreService();
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  void navigateToNotePage(BuildContext context, {Note? note}) async {
    final collections = await firestoreService.getCollections(userId).first;
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNotePage(
          userId: userId,
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
        title: const Text('Archived Notes'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: firestoreService.getArchivedNotes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No archived notes.'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content.length > 100
                      ? '${note.content.substring(0, 100)}...'
                      : note.content,
                ),
                onTap: () => navigateToNotePage(context, note: note),
              );
            },
          );
        },
      ),
    );
  }
}
