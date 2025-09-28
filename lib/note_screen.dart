
import 'package:flutter/material.dart';
import 'package:myapp/database.dart';
import 'package:myapp/note_repository.dart';
import 'bible_lookup_screen.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  final String userId;

  const NoteScreen({super.key, this.note, required this.userId});

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late final NoteRepository _noteRepository;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    _noteRepository = NoteRepository(AppDatabase(), widget.userId);
  }

  void _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty) {
      final now = DateTime.now();
      if (widget.note != null) {
        final updatedNote = widget.note!.copyWith(
          title: title,
          content: content,
        );
        await _noteRepository.updateNote(updatedNote);
      } else {
        final newNote = Note(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          content: content,
          createdAt: now,
          isFavorite: false,
          userId: widget.userId,
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
      final currentText = _contentController.text;
      _contentController.text = '$currentText\n\n$result';
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
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Content',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
