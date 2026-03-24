import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedColor = 0xFFFFFFFF; 
  bool _isPinned = false;
  bool _isArchived = false;

  final List<int> _colors = [
    0xFFFFFFFF, // white
    0xFFF28B82, // red
    0xFFFBBC04, // orange
    0xFFFFF475, // yellow
    0xFFCCFF90, // green
    0xFFA7FFEB, // teal
    0xFFCBF0F8, // blue
    0xFFAECBFA, // dark blue
    0xFFD7AEFB, // purple
    0xFFFDCFE8, // pink
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      _isPinned = widget.note!.isPinned;
      _isArchived = widget.note!.isArchived;
    }
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();
    if (widget.note == null) {
      final newNote = Note(
        id: '',
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        createdAt: now,
        updatedAt: now,
        isPinned: _isPinned,
        isArchived: _isArchived,
      );
      _firestoreService.addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        updatedAt: now,
        isPinned: _isPinned,
        isArchived: _isArchived,
      );
      _firestoreService.updateNote(updatedNote);
    }
    Navigator.pop(context);
  }

  void _deleteNote() async {
    if (widget.note != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _firestoreService.deleteNote(widget.note!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_selectedColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: 'Pin note',
          ),
          IconButton(
            icon: Icon(_isArchived ? Icons.archive : Icons.archive_outlined),
            onPressed: () => setState(() => _isArchived = !_isArchived),
            tooltip: 'Archive note',
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              tooltip: 'Delete note',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18, color: Colors.black45),
                ),
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _colors.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.black87
                                  : Colors.black12,
                              width: _selectedColor == color ? 2.5 : 1,
                            ),
                            boxShadow: [
                              if (_selectedColor == color)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
