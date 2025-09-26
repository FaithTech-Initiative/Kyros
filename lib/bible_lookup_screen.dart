
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
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
      final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-pro-latest');
      final prompt = 'Summarize the following Bible verse in a few bullet points: $_verseText';
      final response = await model.generateContent([Content.text(prompt)]);

      Navigator.of(context).pop(); // Close the loading indicator

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI-Powered Insights'),
          content: Text(response.text ?? 'No response from model.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
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
        title: const Text('Bible Lookup'),
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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter a Bible verse (e.g., John 3:16)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _lookupVerse(),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _lookupVerse,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Lookup'),
                ),
                if (_verseText.isNotEmpty && !_isLoading)
                  ElevatedButton.icon(
                    onPressed: _toggleHighlight,
                    icon: Icon(
                      _isHighlighted ? Icons.highlight_off : Icons.highlight,
                    ),
                    label: Text(_isHighlighted ? 'Unhighlight' : 'Highlight'),
                  ),
                if (_verseText.isNotEmpty && !_isLoading)
                  ElevatedButton.icon(
                    onPressed: _getAiInsights,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Insights'),
                  ),
                if (_verseText.isNotEmpty && !_isLoading)
                  ElevatedButton.icon(
                    onPressed: _getCrossReferences,
                    icon: const Icon(Icons.link),
                    label: const Text('Cross-Refs'),
                  ),
                if (_verseText.isNotEmpty && !_isLoading)
                  ElevatedButton.icon(
                    onPressed: _launchStudyTools,
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Study Tools'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: _isHighlighted ? Colors.yellow.withOpacity(0.3) : null,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_verseText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
