import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/database.dart';
import 'package:kyros/main_note_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class CollectionNotesScreen extends StatelessWidget {
  final String collectionId;
  final String collectionName;
  final String userId;

  const CollectionNotesScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
    required this.userId,
  });

  void _navigateToNotePage(BuildContext context, {Note? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainNotePage(
          userId: userId,
          note: note,
          collectionId: collectionId,
        ),
      ),
    );
  }

  String _getPlainText(String jsonString) {
    if (jsonString.isEmpty) return '';
    try {
      final json = jsonDecode(jsonString) as List<dynamic>;
      final buffer = StringBuffer();
      for (var item in json) {
        if (item is Map<String, dynamic> && item.containsKey('insert')) {
          buffer.write(item['insert']);
        }
      }
      return buffer.toString().replaceAll('\n', ' ').trim();
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(collectionName, style: GoogleFonts.lato()),
      ),
      body: StreamBuilder<List<Note>>(
        stream: FirestoreService().getNotes(userId, collectionId: collectionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No notes in this collection yet.',
                style: GoogleFonts.lato(fontSize: 18, color: theme.colorScheme.onSurface),
              ),
            );
          }
          final notes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.8,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final plainTextContent = _getPlainText(note.content);
              return GestureDetector(
                onTap: () => _navigateToNotePage(context, note: note),
                child: Card(
                  elevation: 4.0,
                  shadowColor: theme.colorScheme.primary.withAlpha(75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            plainTextContent,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withAlpha(180),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(note.updatedAt),
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNotePage(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
