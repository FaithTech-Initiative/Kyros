import 'package:drift/drift.dart';
import 'package:myapp/database.dart';

class NoteRepository {
  final AppDatabase _database;
  final String userId;

  NoteRepository(this._database, this.userId);

  Future<List<Note>> getNotes() {
    return (_database.select(_database.notes)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> addNote(Note note) {
    return _database.into(_database.notes).insert(note);
  }

  Future<void> updateNote(Note note) {
    return _database.update(_database.notes).replace(note);
  }

  Future<void> deleteNote(Note note) {
    return _database.delete(_database.notes).delete(note);
  }

  Future<void> syncNotes(List<Note> notes) async {
    await _database.batch((batch) {
      batch.deleteAll(_database.notes);
      batch.insertAll(_database.notes, notes);
    });
  }

   Future<List<Note>> searchNotes(String query) {
    return (_database.select(_database.notes)
          ..where((tbl) =>
              tbl.title.like('%$query%') | tbl.content.like('%$query%')))
        .get();
  }
}
