
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'main.dart';
import 'bible_lookup_screen.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({super.key, this.note});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    final user = _auth.currentUser;

    if (title.isNotEmpty && content.isNotEmpty) {
      if (widget.note != null) {
        FirebaseFirestore.instance.collection('notes').doc(widget.note!.id).update({
          'title': title,
          'content': content,
        });
      } else {
        if (user != null) {
          FirebaseFirestore.instance.collection('notes').add({
            'title': title,
            'content': content,
            'isFavorite': false,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': user.uid,
          });
        }
      }
      Navigator.pop(context);
    }
  }

  void _openBibleLookup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BibleLookupScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _contentController.text += '\n\n$result';
      });
    }
  }

  void _exportNote() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_titleController.text, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text(_contentController.text),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
            icon: const Icon(Icons.share),
            onPressed: _exportNote,
            tooltip: 'Export Note',
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
                decoration: const InputDecoration(
                  hintText: 'Note',
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
