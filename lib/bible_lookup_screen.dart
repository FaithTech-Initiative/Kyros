import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'highlighted_verses_screen.dart';

class BibleLookupScreen extends StatefulWidget {
  const BibleLookupScreen({super.key});

  @override
  State<BibleLookupScreen> createState() => _BibleLookupScreenState();
}

class _BibleLookupScreenState extends State<BibleLookupScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _verseText = '';
  bool _isLoading = false;
  bool _isHighlighted = false;
  String? _highlightId;

  // TODO: Replace with your ESV API key
  final String _apiKey = 'YOUR_ESV_API_KEY';
  // TODO: Replace with your Google AI API key
  final String _googleAiApiKey = 'YOUR_GOOGLE_AI_API_KEY';

  Future<void> _lookupVerse() async {
    if (_searchController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _isHighlighted = false;
      _highlightId = null;
    });

    final query = _searchController.text;
    final url = Uri.parse('https://api.esv.org/v3/passage/text/?q=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _verseText = data['passages'].join('\n');
        });
      } else {
        setState(() {
          _verseText = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _verseText = 'Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleHighlight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save highlights.')),
      );
      return;
    }

    setState(() {
      _isHighlighted = !_isHighlighted;
    });

    if (_isHighlighted) {
      final docRef = await FirebaseFirestore.instance.collection('highlights').add({
        'userId': user.uid,
        'reference': _searchController.text,
        'text': _verseText,
        'createdAt': Timestamp.now(),
      });
      setState(() {
        _highlightId = docRef.id;
      });
    } else if (_highlightId != null) {
      await FirebaseFirestore.instance.collection('highlights').doc(_highlightId).delete();
      setState(() {
        _highlightId = null;
      });
    }
  }

  Future<void> _getAiInsights() async {
    if (_verseText.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_googleAiApiKey');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'Summarize the following Bible verse in a few bullet points: $_verseText'
                }
              ]
            }
          ]
        }),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading indicator

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final summary = data['candidates'][0]['content']['parts'][0]['text'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI-Powered Insights'),
            content: Text(summary),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating insights: ${error['error']['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating insights: $e')),
      );
    }
  }

  Future<void> _getCrossReferences() async {
    if (_searchController.text.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final query = _searchController.text;
    final url = Uri.parse('https://api.esv.org/v3/passage/search/?q=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $_apiKey',
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading indicator

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];

        showModalBottomSheet(
          context: context,
          builder: (context) => ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                title: Text(result['reference']),
                subtitle: Text(result['content']),
              );
            },
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _launchStudyTools() async {
    if (_searchController.text.isEmpty) {
      return;
    }

    final query = _searchController.text;
    final url = Uri.parse('https://www.blueletterbible.org/search/search.cfm?Criteria=$query&t=ESV');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch study tools')),
      );
    }
  }


  void _openHighlightedVerses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HighlightedVersesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bible Lookup', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _openHighlightedVerses,
            tooltip: 'Highlighted Verses',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildVerseDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Enter a Bible verse (e.g., John 3:16)',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: _lookupVerse,
        ),
      ),
      onSubmitted: (_) => _lookupVerse(),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _lookupVerse,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),
                )
              : Text('Lookup', style: GoogleFonts.lato()),
        ),
        if (_verseText.isNotEmpty && !_isLoading)
          ElevatedButton.icon(
            onPressed: _toggleHighlight,
            icon: Icon(
              _isHighlighted ? Icons.highlight_off : Icons.highlight,
            ),
            label: Text(_isHighlighted ? 'Unhighlight' : 'Highlight', style: GoogleFonts.lato()),
          ),
        if (_verseText.isNotEmpty && !_isLoading)
          ElevatedButton.icon(
            onPressed: _getAiInsights,
            icon: const Icon(Icons.auto_awesome),
            label: Text('Insights', style: GoogleFonts.lato()),
          ),
        if (_verseText.isNotEmpty && !_isLoading)
          ElevatedButton.icon(
            onPressed: _getCrossReferences,
            icon: const Icon(Icons.link),
            label: Text('Cross-Refs', style: GoogleFonts.lato()),
          ),
        if (_verseText.isNotEmpty && !_isLoading)
          ElevatedButton.icon(
            onPressed: _launchStudyTools,
            icon: const Icon(Icons.menu_book),
            label: Text('Study Tools', style: GoogleFonts.lato()),
          ),
      ],
    );
  }

  Widget _buildVerseDisplay() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: _isHighlighted ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Text(
            _verseText,
            style: GoogleFonts.lato(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
