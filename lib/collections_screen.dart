import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
  }

  void _showAddCollectionDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Collection', style: GoogleFonts.lato()),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _firestore.collection('collections').add({
                    'name': nameController.text,
                    'ownerId': _userId,
                    'createdAt': Timestamp.now(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections', style: GoogleFonts.lato()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('collections')
            .where('ownerId', isEqualTo: _userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No collections yet.\nTap the "+" button to create one.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var collections = snapshot.data!.docs;

          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              var collection = collections[index];
              return ListTile(
                title: Text(collection['name'], style: GoogleFonts.lato()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement rename functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Implement delete functionality
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCollectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
