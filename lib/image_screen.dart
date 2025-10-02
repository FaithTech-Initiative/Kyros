import 'dart:io';
import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  final File imageFile;

  const ImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
