import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:myapp/database.dart';
import 'package:myapp/note_repository.dart';
import 'package:drift/drift.dart' hide Column;
import 'bible_lookup_screen.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  final String userId;

  const NoteScreen({super.key, this.note, required this.userId});

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  late quill.QuillController _controller;
  late TextEditingController _titleController;
  late final NoteRepository _noteRepository;

  @override
  void initState() {
    super.initState();
    _noteRepository = NoteRepository(AppDatabase(), widget.userId);
    _titleController = TextEditingController(text: widget.note?.title);

    quill.Document document;
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final contentJson = jsonDecode(widget.note!.content);
        document = quill.Document.fromJson(contentJson);
      } catch (e) {
        document = quill.Document()..insert(0, widget.note!.content);
      }
    } else {
      document = quill.Document();
    }
    _controller = quill.QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isNotEmpty) {
      if (widget.note != null) {
        final updatedNote = NotesCompanion(
          id: Value(widget.note!.id),
          title: Value(title),
          content: Value(content),
          createdAt: Value(widget.note!.createdAt),
          isFavorite: Value(widget.note!.isFavorite),
          userId: Value(widget.userId),
        );
        await _noteRepository.updateNote(updatedNote);
      } else {
        final newNote = NotesCompanion(
          title: Value(title),
          content: Value(content),
          createdAt: Value(DateTime.now()),
          isFavorite: const Value(false),
          userId: Value(widget.userId),
        );
        await _noteRepository.addNote(newNote);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void _openBibleLookup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BibleLookupScreen()),
    );

    if (result != null && result is String) {
      final index = _controller.selection.baseOffset;
      _controller.document.insert(index, '\n\n$result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _openBibleLookup,
            tooltip: 'Lookup Bible Verse',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            quill.QuillToolbar.simple(
              controller: _controller,
            ),
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _controller,
                readOnly: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}
