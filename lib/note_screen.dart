import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:myapp/database.dart';
import 'package:myapp/note_repository.dart';
import 'package:drift/drift.dart' hide Column;

class NoteScreen extends StatefulWidget {
  final Note? note;
  final String userId;

  const NoteScreen({super.key, this.note, required this.userId});

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  late QuillController _controller;
  late TextEditingController _titleController;
  late final NoteRepository _noteRepository;

  @override
  void initState() {
    super.initState();
    _noteRepository = NoteRepository(AppDatabase(), widget.userId);
    _titleController = TextEditingController(text: widget.note?.title);

    Document document;
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final contentJson = jsonDecode(widget.note!.content);
        document = Document.fromJson(contentJson);
      } catch (e) {
        document = Document()..insert(0, widget.note!.content);
      }
    } else {
      document = Document();
    }
    _controller = QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isNotEmpty) {
      final noteToSave = NotesCompanion(
        id: widget.note != null ? Value(widget.note!.id) : const Value.absent(),
        title: Value(title),
        content: Value(content),
        createdAt: widget.note != null ? Value(widget.note!.createdAt) : Value(DateTime.now()),
        isFavorite: widget.note != null ? Value(widget.note!.isFavorite) : const Value(false),
        userId: Value(widget.userId),
      );

      if (widget.note != null) {
        await _noteRepository.updateNote(noteToSave);
      } else {
        await _noteRepository.addNote(noteToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveNote();
              Navigator.pop(context, true);
            },
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
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
              ),
            ),
            Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  readOnly: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
