import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class BibleSidePanel extends StatefulWidget {
  final Function(String) onInsertPassage;
  const BibleSidePanel({super.key, required this.onInsertPassage});

  @override
  State<BibleSidePanel> createState() => _BibleSidePanelState();
}

class _BibleSidePanelState extends State<BibleSidePanel> {
  final TextEditingController _passageController = TextEditingController();
  String _passage = '';
  String _reference = '';
  String _error = '';
  bool _isLoading = false;

  Future<void> _lookupPassage() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final passage = _passageController.text;
    if (passage.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('https://bible-api.com/$passage?translation=kjv'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          setState(() {
            _error = data['error'];
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _passage = data['text'];
          _reference = data['reference'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Could not find passage. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred while fetching the passage.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
        color: theme.canvasColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Study Panel',
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a passage (e.g., John 3:16)',
                    ),
                    onSubmitted: (_) => _lookupPassage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _lookupPassage,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _error.isNotEmpty
                      ? Center(
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _passage.isEmpty
                          ? const Center(
                              child: Text('Look up a passage to see it here.'),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_reference,
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: Icon(Icons.add_comment,
                                          color: theme.colorScheme.primary),
                                      onPressed: () {
                                        final fullPassage =
                                            '"$_passage" - $_reference';
                                        widget.onInsertPassage(fullPassage);
                                      },
                                      tooltip: 'Insert passage into note',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(_passage),
                                  ),
                                ),
                              ],
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
