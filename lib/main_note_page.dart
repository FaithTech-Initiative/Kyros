import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/bible_side_panel.dart';
import 'package:kyros/collection_service.dart';
import 'package:kyros/database.dart';

class MainNotePage extends StatefulWidget {
  final String userId;
  final Note? note;
  final String? collectionId;
  const MainNotePage(
      {super.key, required this.userId, this.note, this.collectionId});

  @override
  State<MainNotePage> createState() => _MainNotePageState();
}

class _MainNotePageState extends State<MainNotePage> {
  late final QuillController _controller;
  late final TextEditingController _titleController;
  final FocusNode _editorFocusNode = FocusNode();
  bool _isPanelVisible = true;
  late final FirestoreService _firestoreService;
  late final CollectionService _collectionService;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _collectionService = CollectionService();
    _titleController = TextEditingController(text: widget.note?.title);
    _selectedCollectionId = widget.note?.collectionId ?? widget.collectionId;

    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final content = jsonDecode(widget.note!.content);
        _controller = QuillController(
          document: Document.fromJson(content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController.basic();
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
    });
  }

  Future<void> _saveNote() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final title = _titleController.text.trim();
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }

    try {
      if (widget.note == null) {
        await _firestoreService.addNote(widget.userId, title, content,
            collectionId: _selectedCollectionId);
      } else {
        await _firestoreService.updateNote(
            widget.userId, widget.note!.id, title, content,
            collectionId: _selectedCollectionId);
      }
      navigator.pop(true);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  void _insertPassageIntoEditor(String passage) {
    FocusScope.of(context).requestFocus(_editorFocusNode);
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;

    _controller.replaceText(index, length, passage, null);
    _controller.document.format(index, passage.length, Attribute.blockQuote);

    final endOfQuote = index + passage.length;
    _controller.moveCursorToPosition(endOfQuote);
    _controller.document.insert(endOfQuote, '\n');
    _controller.moveCursorToPosition(endOfQuote + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration.collapsed(
            hintText: 'Note Title',
          ),
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          StreamBuilder<List<Collection>>(
            stream: _collectionService.getCollections(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final collections = snapshot.data!;
              return DropdownButton<String>(
                value: _selectedCollectionId,
                hint: const Text('Collection'),
                items: collections.map((collection) {
                  return DropdownMenuItem<String>(
                    value: collection.id,
                    child: Text(collection.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCollectionId = value;
                  });
                },
              );
            },
          ),
          IconButton(
            icon: Icon(_isPanelVisible ? Icons.menu_book : Icons.menu_open),
            onPressed: _togglePanel,
            tooltip: 'Toggle Bible Panel',
          ),
          IconButton(
            icon:
                Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _controller,
                ),
                const Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QuillEditor.basic(
                      controller: _controller,
                      //focusNode: _editorFocusNode,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_isPanelVisible)
            BibleSidePanel(
              onInsertPassage: _insertPassageIntoEditor,
            ),
        ],
      ),
    );
  }
}
