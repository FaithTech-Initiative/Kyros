
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HighlightedVersesScreen extends StatelessWidget {
  const HighlightedVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlighted Verses'),
      ),
      body: user == null
          ? const Center(
              child: Text('You must be logged in to see your highlights.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('highlights')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final highlights = snapshot.data!.docs;

                if (highlights.isEmpty) {
                  return const Center(
                    child: Text('You have no highlighted verses yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = highlights[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      child: ListTile(
                        title: Text(highlight['reference']),
                        subtitle: Text(highlight['text']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('highlights')
                                .doc(highlight.id)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
