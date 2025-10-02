import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyros/bible_side_panel.dart';
import 'package:kyros/database.dart';
import 'package:path/path.dart' as path;

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
  bool _isPanelVisible = true;
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

  Future<void> _saveNote() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final title = _titleController.text.trim();
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: material.Text('Please enter a title.')),
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
        SnackBar(content: material.Text('Error saving note: $e')),
      );
    }
  }

  Future<void> _archiveNote() async {
    if (widget.note == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final title = _titleController.text.trim();
      final content = jsonEncode(_controller.document.toDelta().toJson());

      await _firestoreService.updateNote(
        widget.userId,
        widget.note!.id,
        title.isEmpty ? 'Untitled Note' : title,
        content,
        collectionId: _selectedCollectionId,
        isArchived: true,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: material.Text('Note archived.')),
      );
      if (navigator.canPop()) {
        navigator.pop(true);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: material.Text('Error archiving note: $e')),
      );
    }
  }

  Future<void> _unarchiveNote() async {
    if (widget.note == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final title = _titleController.text.trim();
      final content = jsonEncode(_controller.document.toDelta().toJson());

      await _firestoreService.updateNote(
        widget.userId,
        widget.note!.id,
        title.isEmpty ? 'Untitled Note' : title,
        content,
        collectionId: _selectedCollectionId,
        isArchived: false,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: material.Text('Note unarchived.')),
      );
      if (navigator.canPop()) {
        navigator.pop(true);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: material.Text('Error unarchiving note: $e')),
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

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const material.Text('Delete Note'),
        content:
            const material.Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const material.Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const material.Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteNote(widget.userId, widget.note!.id);
        if (navigator.canPop()) {
          navigator.pop(true);
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: material.Text('Error deleting note: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName = path.basename(file.path);
    final destination = 'files/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      _insertImageIntoEditor(url);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: material.Text('Error uploading image: $e')),
      );
    }
  }

  void _insertImageIntoEditor(String url) {
    final index = _controller.selection.baseOffset;
    _controller.document.insert(index, BlockEmbed.image(url));
    _controller.updateSelection(
        TextSelection.collapsed(offset: index + 1), ChangeSource.local);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: _pickAndUploadImage,
            tooltip: 'Insert Image',
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              tooltip: 'Delete Note',
            ),
          if (widget.collections.isNotEmpty)
            DropdownButton<String>(
              value: _selectedCollectionId,
              hint: const material.Text('Collection'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: material.Text('No Collection'),
                ),
                ...widget.collections.map((collection) {
                  return DropdownMenuItem<String>(
                    value: collection.id,
                    child: material.Text(collection.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCollectionId = value;
                });
              },
            ),
          if (widget.note != null && !widget.note!.isArchived)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: _archiveNote,
              tooltip: 'Archive Note',
            ),
          if (widget.note != null && widget.note!.isArchived)
            IconButton(
              icon: const Icon(Icons.unarchive_outlined),
              onPressed: _unarchiveNote,
              tooltip: 'Unarchive Note',
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
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha(235),
        ),
        child: Row(
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
                      padding: const EdgeInsets.all(24.0),
                      child: QuillEditor.basic(
                        controller: _controller,
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
      ),
    );
  }
}
