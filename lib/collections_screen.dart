import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/collection_notes_screen.dart';
import 'package:kyros/database.dart';

class CollectionsScreen extends StatefulWidget {
  final String userId;

  const CollectionsScreen({super.key, required this.userId});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _collectionNameController =
      TextEditingController();

  void _showAddCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Collection'),
          content: TextField(
            controller: _collectionNameController,
            decoration: const InputDecoration(hintText: 'Collection Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_collectionNameController.text.isNotEmpty) {
                  _firestoreService.addCollection(
                      widget.userId, _collectionNameController.text);
                  _collectionNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCollectionNotes(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionNotesScreen(
          userId: widget.userId,
          collection: collection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: StreamBuilder<List<Collection>>(
        stream: _firestoreService.getCollections(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.collections_bookmark_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'You have no collections yet.',
                    style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the "+" button to create your first collection!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final collections = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return GestureDetector(
                  onTap: () => _navigateToCollectionNotes(collection),
                  child: Card(
                    elevation: 4.0,
                    shadowColor: theme.colorScheme.primary.withAlpha(75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder, size: 50, color: Colors.amber),
                          const SizedBox(height: 10),
                          Text(
                            collection.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCollectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
