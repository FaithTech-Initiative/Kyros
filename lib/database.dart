import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final String? collectionId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.collectionId,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      updatedAt: data['updatedAt'] == null
          ? DateTime.now()
          : (data['updatedAt'] as Timestamp).toDate(),
      collectionId: data['collectionId'],
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNote(String userId, String title, String content,
      {String? collectionId}) {
    return _db.collection('users').doc(userId).collection('notes').add({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
      'collectionId': collectionId,
    });
  }

  Future<void> updateNote(
      String userId, String noteId, String title, String content,
      {String? collectionId}) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
      'collectionId': collectionId,
    });
  }

  Future<void> deleteNote(String userId, String noteId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Stream<List<Note>> getNotes(String userId, {String? collectionId}) {
    Query query = _db.collection('users').doc(userId).collection('notes');

    if (collectionId != null) {
      query = query.where('collectionId', isEqualTo: collectionId);
    }

    return query.orderBy('updatedAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }
}
