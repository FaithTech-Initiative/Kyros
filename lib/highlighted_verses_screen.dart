import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/highlight_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class HighlightedVersesScreen extends StatefulWidget {
  const HighlightedVersesScreen({super.key});

  @override
  State<HighlightedVersesScreen> createState() =>
      _HighlightedVersesScreenState();
}

class _HighlightedVersesScreenState extends State<HighlightedVersesScreen> {
  Future<void> _deleteHighlight(String highlightId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<HighlightService>().deleteHighlight(highlightId);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Highlight deleted.')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error deleting highlight: $e')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, String highlightId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Highlight'),
          content:
              const Text('Are you sure you want to delete this highlight?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHighlight(highlightId);
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
            style: GoogleFonts.lato(
                fontSize: 18, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedVersesList(User user, ThemeData theme) {
    return StreamBuilder<List<Highlight>>(
      stream: context.watch<HighlightService>().getHighlights(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyView(theme);
        }
        final highlights = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: highlights.length,
          itemBuilder: (context, index) {
            final highlight = highlights[index];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              shadowColor: theme.colorScheme.primary.withAlpha(75),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      highlight.reference,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      highlight.text,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        height: 1.5, // Line height
                        color: theme.colorScheme.onSurface.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeago.format(highlight.createdAt),
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: theme.colorScheme.error.withAlpha(200)),
                          onPressed: () =>
                              _showDeleteConfirmation(context, highlight.id),
                          tooltip: 'Delete Highlight',
                        ),
                      ],
                    )
                  ],
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
          Icon(Icons.highlight_off,
              size: 60, color: theme.colorScheme.secondary.withAlpha(150)),
          const SizedBox(height: 20),
          Text(
            'You have no highlighted verses yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 20,
                color: theme.colorScheme.onSurface.withAlpha(200)),
          ),
          const SizedBox(height: 10),
          Text(
            'You can highlight verses from the Bible screen.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
