import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/database.dart';
import 'package:kyros/note_repository.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: theme.colorScheme.primary),
            onPressed: () {
              _saveNote();
              Navigator.pop(context, true);
            },
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTitleField(theme),
            const SizedBox(height: 16),
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(locale: Locale('en')),
              ),
            ),
            const SizedBox(height: 8),
            _buildEditor(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return TextField(
      controller: _titleController,
      style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        hintStyle: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: QuillEditor.basic(
          configurations: QuillEditorConfigurations(
            controller: _controller,
            readOnly: false,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }
}
