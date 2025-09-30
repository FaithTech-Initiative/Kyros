import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/collection_notes_screen.dart';
import 'package:kyros/collection_service.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final CollectionService _collectionService = CollectionService();
  final TextEditingController _collectionNameController = TextEditingController();

  void _showAddCollectionDialog(BuildContext context, String userId) {
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_collectionNameController.text.isNotEmpty) {
                  _collectionService.addCollection(userId, _collectionNameController.text);
                  _collectionNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCollectionDialog(BuildContext context, Collection collection) {
    _collectionNameController.text = collection.name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Collection'),
          content: TextField(
            controller: _collectionNameController,
            decoration: const InputDecoration(hintText: 'Collection Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_collectionNameController.text.isNotEmpty) {
                  _collectionService.updateCollection(collection.id, _collectionNameController.text);
                  _collectionNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showMoreMenu(BuildContext context, Collection collection) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(context).pop();
                _showRenameCollectionDialog(context, collection);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Collection'),
                      content: const Text('Are you sure you want to delete this collection and all its notes?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _collectionService.deleteCollection(collection.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Collection deleted')),
                            );
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Collections', style: GoogleFonts.lato()),
      ),
      body: user == null
          ? Center(child: Text('Please log in to see your collections.'))
          : StreamBuilder<List<Collection>>(
              stream: _collectionService.getCollections(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No collections yet.',
                      style: GoogleFonts.lato(fontSize: 18, color: theme.colorScheme.onSurface),
                    ),
                  );
                }
                final collections = snapshot.data!;
                return ListView.builder(
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      title: Text(collection.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showMoreMenu(context, collection),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionNotesScreen(
                              collectionId: collection.id,
                              collectionName: collection.name,
                              userId: user.uid,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: user != null ? FloatingActionButton(
        onPressed: () => _showAddCollectionDialog(context, user.uid),
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
