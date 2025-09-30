import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  Collection({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Collection.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Collection(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class CollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Collection>> getCollections(String userId) {
    return _db
        .collection('collections')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Collection.fromFirestore(doc)).toList());
  }

  Future<void> addCollection(String userId, String name) {
    return _db.collection('collections').add({
      'userId': userId,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCollection(String collectionId, String newName) {
    return _db.collection('collections').doc(collectionId).update({
      'name': newName,
    });
  }

  Future<void> deleteCollection(String collectionId) {
    return _db.collection('collections').doc(collectionId).delete();
  }
}
