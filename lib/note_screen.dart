import 'dart:convert';
import 'package:flutter/material.dart';
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
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  late final NoteRepository _noteRepository;

  @override
  void initState() {
    super.initState();
    _noteRepository = NoteRepository(AppDatabase(), widget.userId);
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: _getPlainText(widget.note?.content));
  }

  String _getPlainText(String? jsonContent) {
    if (jsonContent == null || jsonContent.isEmpty) {
      return '';
    }
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is List) {
        return decoded.map((item) => item['insert'] ?? '').join();
      }
      return jsonContent;
    } catch (e) {
      return jsonContent; // Fallback for plain text content
    }
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty || content.isNotEmpty) {
      final noteToSave = NotesCompanion(
        id: widget.note != null ? Value(widget.note!.id) : const Value.absent(),
        title: Value(title),
        content: Value(content), // Saving as plain text now
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
      body: WillPopScope(
        onWillPop: () async {
          _saveNote();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Title',
                ),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Note',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: Colors.black54),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, color: Colors.black54),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.text_format_outlined, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_outlined, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
