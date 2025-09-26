
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
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
  late quill.QuillController _contentController;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = quill.QuillController.basic();

    // Load existing note content if available
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final contentJson = jsonDecode(widget.note!.content);
        _contentController = quill.QuillController(
          document: quill.Document.fromJson(contentJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Handle plain text content for backward compatibility
        _contentController = quill.QuillController(
          document: quill.Document()..insert(0, widget.note!.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }
  }

  // Save note to Firestore
  void _saveNote() {
    final title = _titleController.text;
    final content = jsonEncode(_contentController.document.toDelta().toJson());
    final user = _auth.currentUser;

    if (title.isNotEmpty) {
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

  // Open Bible lookup screen
  void _openBibleLookup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BibleLookupScreen()),
    );

    if (result != null && result is String) {
      final index = _contentController.selection.baseOffset;
      final length = _contentController.selection.extentOffset - index;
      _contentController.replaceText(index, length, '\n\n$result', null);
    }
  }

  // Export note as PDF
  void _exportNote() async {
    final pdf = pw.Document();
    final content = _contentController.document.toPlainText();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_titleController.text, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text(content),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Pick and upload an image
  Future<String?> _pickAndUploadImage(quill.QuillController controller) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = _storage.ref().child('note_images/${DateTime.now().toIso8601String()}');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      controller.insertImageBlock(imageUrl: url);
    }
    return null;
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
            quill.QuillToolbar.simple(
              controller: _contentController,
              onImageInsert: (image, controller) => _pickAndUploadImage(controller),
            ),
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _contentController,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
