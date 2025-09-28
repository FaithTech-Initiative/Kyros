import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:myapp/database.dart';

// Helper function to convert Quill delta to plain text
String _getPlainText(String content) {
  if (content.isEmpty || content == '{"insert":"\n"}') {
    return '';
  }
  try {
    final json = jsonDecode(content);
    final doc = quill.Document.fromJson(json);
    return doc.toPlainText().trim();
  } catch (e) {
    // If it's not a valid JSON, it might be plain text already
    return content.trim();
  }
}

class NoteRepository {
  final AppDatabase _database;
  final String userId;

  NoteRepository(this._database, this.userId);

  Future<List<Note>> getNotes() {
    return (_database.select(_database.notes)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> addNote(NotesCompanion note) {
    final plainTextContent = _getPlainText(note.content.value);
    final noteWithPlainText =
        note.copyWith(plainTextContent: Value(plainTextContent));
    return _database.into(_database.notes).insert(noteWithPlainText);
  }

  Future<void> updateNote(NotesCompanion note) {
    final plainTextContent = _getPlainText(note.content.value);
    final noteWithPlainText =
        note.copyWith(plainTextContent: Value(plainTextContent));
    return (_database.update(_database.notes)..where((t) => t.id.equals(note.id.value))).write(noteWithPlainText);
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
              tbl.title.like('%$query%') | tbl.plainTextContent.like('%$query%')))
        .get();
  }
}
