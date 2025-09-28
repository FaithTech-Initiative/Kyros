import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final QuillController _controller = QuillController.basic();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Screen'),
      ),
      body: Column(
        children: [
          // Remove `const` and provide the controller
          QuillSimpleToolbar(
            controller: _controller,
            configurations: const QuillSimpleToolbarConfigurations(),
          ),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              // Remove `const` from configurations
              // readOnly is now a parameter of QuillEditorConfigurations
              configurations: QuillEditorConfigurations(
                readOnly: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}