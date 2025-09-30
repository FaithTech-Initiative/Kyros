import 'package:cloud_firestore/cloud_firestore.dart';

class Highlight {
  final String id;
  final String userId;
  final String reference;
  final String text;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.userId,
    required this.reference,
    required this.text,
    required this.createdAt,
  });

  factory Highlight.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Highlight(
      id: doc.id,
      userId: data['userId'] ?? '',
      reference: data['reference'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class HighlightService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Highlight>> getHighlights(String userId) {
    return _db
        .collection('highlights')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Highlight.fromFirestore(doc)).toList());
  }

  Future<void> deleteHighlight(String highlightId) {
    return _db.collection('highlights').doc(highlightId).delete();
  }
}
