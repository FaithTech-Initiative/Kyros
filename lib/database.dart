import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final String? collectionId;
  final bool isArchived;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.collectionId,
    this.isArchived = false,
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
      isArchived: data['isArchived'] ?? false,
    );
  }
}

class Collection {
  final String id;
  final String name;

  Collection({required this.id, required this.name});

  factory Collection.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Collection(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Note methods
  Future<void> addNote(String userId, String title, String content,
      {String? collectionId, bool isArchived = false}) {
    return _db.collection('users').doc(userId).collection('notes').add({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
      'collectionId': collectionId,
      'isArchived': isArchived,
    });
  }

  Future<void> updateNote(
      String userId, String noteId, String title, String content,
      {String? collectionId, bool? isArchived}) {
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
      if (isArchived != null) 'isArchived': isArchived,
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
    Query query = _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('isArchived', isEqualTo: false);

    if (collectionId != null) {
      query = query.where('collectionId', isEqualTo: collectionId);
    }

    return query.orderBy('updatedAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }

  Stream<List<Note>> getArchivedNotes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('isArchived', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }

  // Collection methods
  Future<void> addCollection(String userId, String name) {
    return _db.collection('users').doc(userId).collection('collections').add({
      'name': name,
    });
  }

  Future<void> renameCollection(
      String collectionId, String userId, String newName) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('collections')
        .doc(collectionId)
        .update({'name': newName});
  }

  Future<void> deleteCollection(String collectionId, String userId) async {
    // First, delete all notes in the collection
    final notesSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('collectionId', isEqualTo: collectionId)
        .get();

    for (final doc in notesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Then, delete the collection itself
    return _db
        .collection('users')
        .doc(userId)
        .collection('collections')
        .doc(collectionId)
        .delete();
  }

  Stream<List<Collection>> getCollections(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('collections')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Collection.fromFirestore(doc))
            .toList());
  }

  Stream<List<Note>> getNotesForCollection(String userId, String collectionId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('collectionId', isEqualTo: collectionId)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }
}
