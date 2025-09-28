import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/database.dart';

class NoteRepository {
  final AppDatabase _database;
  final CollectionReference _notesCollection = FirebaseFirestore.instance.collection('notes');

  NoteRepository(this._database);

  Future<List<Note>> getNotes() async {
    final localNotes = await _database.select(_database.notes).get();
    if (localNotes.isNotEmpty) {
      return localNotes;
    }
    return _syncNotesFromFirestore();
  }

  Future<List<Note>> _syncNotesFromFirestore() async {
    final snapshot = await _notesCollection.get();
    final notes = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Note(
        id: int.parse(doc.id),
        title: data['title'],
        content: data['content'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        isFavorite: data['isFavorite'],
      );
    }).toList();

    await _database.batch((batch) {
      batch.insertAll(_database.notes, notes);
    });

    return notes;
  }

  Future<void> addNote(Note note) async {
    await _database.into(_database.notes).insert(note);
    await _notesCollection.doc(note.id.toString()).set({
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt,
      'isFavorite': note.isFavorite,
    });
  }

  Future<void> updateNote(Note note) async {
    await _database.update(_database.notes).replace(note);
    await _notesCollection.doc(note.id.toString()).update({
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt,
      'isFavorite': note.isFavorite,
    });
  }

  Future<void> deleteNote(Note note) async {
    await _database.delete(_database.notes).delete(note);
    await _notesCollection.doc(note.id.toString()).delete();
  }
}
