import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({
    super.key,
    required this.controller,
    required this.editorFocusNode,
  });

  final QuillController controller;
  final FocusNode editorFocusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: QuillEditor.basic(
        controller: controller,
        focusNode: editorFocusNode,
      ),
    );
  }
}
