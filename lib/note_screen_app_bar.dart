import 'package:flutter/material.dart';
import 'package:kyros/database.dart';

class NotePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController titleController;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onUnarchive;
  final VoidCallback onTogglePanel;
  final VoidCallback onPickImage;
  final bool isPanelVisible;
  final bool isArchived;
  final List<Collection> collections;
  final String? selectedCollectionId;
  final Function(String?) onCollectionChanged;

  const NotePageAppBar({
    super.key,
    required this.titleController,
    required this.onSave,
    required this.onShare,
    required this.onDelete,
    required this.onArchive,
    required this.onUnarchive,
    required this.onTogglePanel,
    required this.onPickImage,
    required this.isPanelVisible,
    required this.isArchived,
    required this.collections,
    required this.selectedCollectionId,
    required this.onCollectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: titleController,
        decoration: const InputDecoration.collapsed(
          hintText: 'Note Title',
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.image_outlined),
          onPressed: onPickImage,
          tooltip: 'Insert Image',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onShare,
          tooltip: 'Share Note',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Delete Note',
        ),
        if (collections.isNotEmpty)
          DropdownButton<String>(
            value: selectedCollectionId,
            hint: const Text('Collection'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('No Collection'),
              ),
              ...collections.map((collection) {
                return DropdownMenuItem<String>(
                  value: collection.id,
                  child: Text(collection.name),
                );
              }),
            ],
            onChanged: onCollectionChanged,
          ),
        if (!isArchived)
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: onArchive,
            tooltip: 'Archive Note',
          ),
        if (isArchived)
          IconButton(
            icon: const Icon(Icons.unarchive_outlined),
            onPressed: onUnarchive,
            tooltip: 'Unarchive Note',
          ),
        IconButton(
          icon: Icon(isPanelVisible ? Icons.menu_book : Icons.menu_open),
          onPressed: onTogglePanel,
          tooltip: 'Toggle Bible Panel',
        ),
        IconButton(
          icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
          onPressed: onSave,
          tooltip: 'Save Note',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
