
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BibleLookupScreen extends StatefulWidget {
  const BibleLookupScreen({super.key});

  @override
  _BibleLookupScreenState createState() => _BibleLookupScreenState();
}

class _BibleLookupScreenState extends State<BibleLookupScreen> {
  final _searchController = TextEditingController();
  String _verse = '';

  Future<void> _searchVerse() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final response = await http.get(Uri.parse('https://bible-api.com/$query'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _verse = data['text'];
        });
      } else {
        setState(() {
          _verse = 'Verse not found.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Lookup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter a Bible verse (e.g., John 3:16)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchVerse,
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            if (_verse.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_verse),
                ),
              ),
            const Spacer(),
            if (_verse.isNotEmpty && _verse != 'Verse not found.')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _verse);
                },
                child: const Text('Add to Note'),
              ),
          ],
        ),
      ),
    );
  }
}
