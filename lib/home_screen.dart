
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
