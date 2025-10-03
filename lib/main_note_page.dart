import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:kyros/bible_side_panel.dart';
import 'package:kyros/bottom_action_bar.dart';
import 'package:kyros/database.dart';
import 'package:kyros/note_editor.dart';
import 'package:share_plus/share_plus.dart';

class MainNotePage extends StatefulWidget {
  final String userId;
  final Note? note;
  final List<Collection> collections;
  const MainNotePage(
      {super.key, required this.userId, this.note, required this.collections});

  @override
  State<MainNotePage> createState() => _MainNotePageState();
}

class _MainNotePageState extends State<MainNotePage> {
  late final QuillController _controller;
  late final TextEditingController _titleController;
  final FocusNode _editorFocusNode = FocusNode();
  bool _isPanelVisible = false;
  late final FirestoreService _firestoreService;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _titleController = TextEditingController(text: widget.note?.title);
    _selectedCollectionId = widget.note?.collectionId;

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

  Future<void> _shareNote() async {
    final title = _titleController.text.trim();
    final content = _controller.document.toPlainText();
    final noteText = '$title\n\n$content';
    await SharePlus.instance.share(ShareParams(text: noteText));
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
            collectionId: _selectedCollectionId,
            isArchived: widget.note!.isArchived);
      }
      if (navigator.canPop()) {
        navigator.pop(true);
      }
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
            hintText: 'Title',
          ),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: _togglePanel,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          NoteEditor(
            controller: _controller,
            editorFocusNode: _editorFocusNode,
          ),
          if (_isPanelVisible)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: BibleSidePanel(
                onInsertPassage: _insertPassageIntoEditor,
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomActionBar(),
    );
  }
}
