
import 'package:flutter/material.dart';
import 'package:esv_bible/esv_bible.dart';

class BibleLookupScreen extends StatefulWidget {
  const BibleLookupScreen({super.key});

  @override
  _BibleLookupScreenState createState() => _BibleLookupScreenState();
}

class _BibleLookupScreenState extends State<BibleLookupScreen> {
  final _searchController = TextEditingController();
  String _passage = '';

  // TODO: Replace with your ESV API key
  final String _apiKey = 'YOUR_API_KEY';

  Future<void> _searchPassage() async {
    if (_apiKey == 'YOUR_API_KEY') {
      setState(() {
        _passage = 'Please replace \'YOUR_API_KEY\' with your ESV API key.';
      });
      return;
    }

    final esv = EsvBible(apiKey: _apiKey);

    try {
      final passage = await esv.getPassageHtml(_searchController.text);
      setState(() {
        _passage = passage;
      });
    } catch (e) {
      setState(() {
        _passage = 'Error: ${e.toString()}';
      });
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a passage (e.g., John 3:16)',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPassage,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_passage),
              ),
            ),
            if (_passage.isNotEmpty && !_passage.startsWith('Error') && !_passage.startsWith('Please'))
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _passage);
                },
                child: const Text('Select'),
              ),
          ],
        ),
      ),
    );
  }
}
