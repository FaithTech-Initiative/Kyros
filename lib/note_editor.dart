import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode editorFocusNode;

  const NoteEditor({
    super.key,
    required this.controller,
    required this.editorFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillSimpleToolbar(
          controller: controller,
        ),
        const Divider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: QuillEditor.basic(
              controller: controller,
              focusNode: editorFocusNode,
            ),
          ),
        ),
      ],
    );
  }
}
