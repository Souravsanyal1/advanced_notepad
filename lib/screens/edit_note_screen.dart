import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/photo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _storageService = LocalStorageService();
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedColor = 0xFFFFFFFF; 
  bool _isPinned = false;
  bool _isArchived = false;
  bool _isDeleted = false;
  String? _imageUrl;
  bool _isUploading = false;
  List<String> _selectedLabels = [];
  List<String> _availableLabels = [];


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
      _isDeleted = widget.note!.isDeleted;
      _imageUrl = widget.note!.imageUrl;
      _selectedLabels = List<String>.from(widget.note!.labels);
    }
    _loadLabels();
  }

  void _loadLabels() {
    _firestoreService.getLabels().listen((labels) {
      if (mounted) {
        setState(() {
          _availableLabels = labels;
        });
      }
    });
  }


  Future<void> _pickAndUploadImage() async {
    try {
      final bool hasPermission = await _photoService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gallery permission is required to add images.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => _photoService.openSettings(),
              ),
            ),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final String? savedPath = await _storageService.saveImage(File(image.path), 'note_images');
      
      if (savedPath != null) {
        setState(() {
          _imageUrl = savedPath;
          _isUploading = false;
        });
      } else {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image locally.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      debugPrint('Error picking/uploading image: $e');
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
        imageUrl: _imageUrl,
        labels: _selectedLabels,
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
        imageUrl: _imageUrl,
        labels: _selectedLabels,
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
        await _firestoreService.moveToTrash(widget.note!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _restoreNote() async {
    if (widget.note != null) {
      await _firestoreService.restoreFromTrash(widget.note!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _permanentlyDeleteNote() async {
    if (widget.note != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Permanently'),
          content: const Text('This action cannot be undone. Are you sure?'),
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
        if (widget.note!.imageUrl != null && !widget.note!.imageUrl!.startsWith('http')) {
          await _storageService.deleteImage(widget.note!.imageUrl!);
        }
        await _firestoreService.deleteNote(widget.note!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }


  Color _getContrastColor() {
    return Color(_selectedColor).computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }

  Color _getHintColor() {
    return Color(_selectedColor).computeLuminance() > 0.5
        ? Colors.black45
        : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = _getContrastColor();
    final hintColor = _getHintColor();

    return Scaffold(
      backgroundColor: Color(_selectedColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: contrastColor),
          onPressed: () => Navigator.pop(context),
        ),
         actions: _isDeleted
            ? [
                IconButton(
                  icon: Icon(Icons.restore_from_trash_rounded, color: contrastColor),
                  onPressed: _restoreNote,
                  tooltip: 'Restore note',
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever_rounded, color: contrastColor),
                  onPressed: _permanentlyDeleteNote,
                  tooltip: 'Delete permanently',
                ),
                const SizedBox(width: 8),
              ]
            : [
                IconButton(
                  icon: Icon(
                    _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: contrastColor,
                  ),
                  onPressed: () => setState(() => _isPinned = !_isPinned),
                  tooltip: 'Pin note',
                ),
                IconButton(
                  icon: Icon(
                    _isArchived ? Icons.archive : Icons.archive_outlined,
                    color: contrastColor,
                  ),
                  onPressed: () => setState(() => _isArchived = !_isArchived),
                  tooltip: 'Archive note',
                ),
                IconButton(
                  icon: Icon(Icons.add_photo_alternate_outlined, color: contrastColor),
                  onPressed: _isUploading ? null : _pickAndUploadImage,
                  tooltip: 'Add image',
                ),
                if (widget.note != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: contrastColor),
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
              cursorColor: contrastColor,
              readOnly: _isDeleted,
              decoration: InputDecoration(

                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: hintColor,
                ),
              ),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: Colors.black54)),
            ),
          if (_imageUrl != null && !_isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _imageUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: _imageUrl!,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.black12,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : (File(_imageUrl!).existsSync()
                            ? Image.file(
                                File(_imageUrl!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              )
                            : Container(
                                height: 200,
                                color: Colors.black12,
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              )),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () async {
                          if (_imageUrl != null && !_imageUrl!.startsWith('http')) {
                            await _storageService.deleteImage(_imageUrl!);
                          }
                          setState(() => _imageUrl = null);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.note != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last edited: ${widget.note!.updatedAt.day}/${widget.note!.updatedAt.month}/${widget.note!.updatedAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               child: TextField(
                controller: _contentController,
                maxLines: null,
                cursorColor: contrastColor,
                readOnly: _isDeleted,
                decoration: InputDecoration(

                  hintText: 'Type something...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 18, color: hintColor),
                ),
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: contrastColor,
                ),
              ),
            ),
          ),
           if (!_isDeleted)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: Color(_selectedColor).computeLuminance() > 0.5 ? 0.3 : 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colors.map((colorValue) {
                        final isSelected = _selectedColor == colorValue;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = colorValue),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 50 : 40,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.black12,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.black, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                   const SizedBox(height: 16),
                  if (_availableLabels.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Labels',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: contrastColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _availableLabels.map((label) {
                          final isSelected = _selectedLabels.contains(label);
                          return FilterChip(
                            label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : contrastColor)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedLabels.add(label);
                                } else {
                                  _selectedLabels.remove(label);
                                }
                              });
                            },
                            selectedColor: Colors.black87,
                            checkmarkColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? Colors.black87 : contrastColor.withValues(alpha: 0.3)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.check_circle_outline, size: 24),
                      label: const Text(
                        'Save Note',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
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
