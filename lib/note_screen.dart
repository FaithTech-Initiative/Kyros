import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _saveNote();
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined, color: Colors.black),
            onPressed: () {
              _saveNote();
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _saveNote();
          Navigator.of(context).pop(true);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildToolbar(),
              _buildEditor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration.collapsed(
        hintText: 'Title',
        hintStyle: GoogleFonts.lato(fontSize: 26, fontWeight: FontWeight.w500),
      ),
      style: GoogleFonts.lato(fontSize: 26, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildToolbar() {
    return QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Expanded(
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          controller: _controller,
          readOnly: false,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
      ),
    );
  }
}
