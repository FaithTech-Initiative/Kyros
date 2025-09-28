
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/bible_lookup_screen.dart';
import 'package:myapp/note_screen.dart';
import 'package:myapp/highlighted_verses_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Bible Study App',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/illustration.png', 
                height: 250,
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome Back!',
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'What would you like to do today?',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildQuickActionButton(
                context,
                icon: Icons.search,
                label: 'Bible Lookup',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BibleLookupScreen()));
                },
              ),
              const SizedBox(height: 20),
              _buildQuickActionButton(
                context,
                icon: Icons.edit,
                label: 'My Notes',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen(userId: userId)));
                },
              ),
              const SizedBox(height: 20),
              _buildQuickActionButton(
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
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 15,
        ),
        minimumSize: const Size(280, 60),
        elevation: 5,
      ),
    );
  }
}
