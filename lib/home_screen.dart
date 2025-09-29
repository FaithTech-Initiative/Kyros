import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/note_screen.dart';
import 'package:kyros/highlighted_verses_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kyros', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'What would you like to do today?',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withAlpha(178),
              ),
            ),
            const SizedBox(height: 48),
            _buildFeatureButton(
              context,
              icon: Icons.search,
              label: 'Bible Lookup',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleLookupScreen()));
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              icon: Icons.edit,
              label: 'My Notes',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen(userId: userId)));
              },
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              icon: Icons.bookmark,
              label: 'Highlighted Verses',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HighlightedVersesScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: theme.colorScheme.primary.withAlpha(102),
      ),
    );
  }
}
