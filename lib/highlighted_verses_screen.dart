import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HighlightedVersesScreen extends StatelessWidget {
  const HighlightedVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Highlighted Verses', style: GoogleFonts.lato()),
      ),
      body: user == null
          ? _buildLoggedOutView(theme)
          : _buildHighlightedVersesList(user, theme),
    );
  }

  Widget _buildLoggedOutView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 50, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Please log in to see your highlighted verses.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 18, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedVersesList(User user, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('highlights')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyView(theme);
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  data['reference'] ?? 'No Reference',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data['text'] ?? 'No Text',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(204)),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  onPressed: () => doc.reference.delete(),
                  tooltip: 'Delete Highlight',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.highlight_off, size: 50, color: theme.colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            'You have no highlighted verses yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 18, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
