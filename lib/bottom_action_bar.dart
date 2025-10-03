import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.text_format_outlined),
                onPressed: () {},
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.redo_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
