import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';
import '../services/photo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import '../widgets/loading_widget.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final NoteController _noteController = Get.find<NoteController>();
  final LocalStorageService _storageService = LocalStorageService();
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedColor = 0xFFFFFFFF; 
  bool _isPinned = false;
  bool _isFavorite = false;
  bool _isArchived = false;
  bool _isDeleted = false;
  String? _imageUrl;
  bool _isUploading = false;
  List<String> _selectedLabels = [];
  bool _isSaving = false;
  String _lastSaved = '';
  int _wordCount = 0;
  int _charCount = 0;
  String? _signatureUrl;
  late SignatureController _sigController;
  late DateTime _creationTime;

  final List<int> _colors = [
    0xFFFFFFFF, // white
    0xFFF8D7DA, // soft red
    0xFFFFF3CD, // soft yellow
    0xFFD4EDDA, // soft green
    0xFFD1ECF1, // soft teal
    0xFFCCE5FF, // soft blue
    0xFFE2E3E5, // soft grey
    0xFFF3E5F5, // soft purple
    0xFFFCE4EC, // soft pink
    0xFFE8F5E9, // mint
  ];

  @override
  void initState() {
    super.initState();
    _creationTime = DateTime.now();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
      _isPinned = widget.note!.isPinned;
      _isFavorite = widget.note!.isFavorite;
      _isArchived = widget.note!.isArchived;
      _isDeleted = widget.note!.isDeleted;
      _imageUrl = widget.note!.imageUrl;
      _signatureUrl = widget.note!.signatureUrl;
      _selectedLabels = List<String>.from(widget.note!.labels);
      _updateStats();
    }

    _sigController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    _contentController.addListener(_updateStats);
  }

  void _updateStats() {
    final text = _contentController.text.trim();
    setState(() {
      _charCount = text.length;
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateStats);
    _titleController.dispose();
    _contentController.dispose();
    _sigController.dispose();
    super.dispose();
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

  void _saveNote() async {
    setState(() => _isSaving = true);
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
        isFavorite: _isFavorite,
        isArchived: _isArchived,
        imageUrl: _imageUrl,
        signatureUrl: _signatureUrl,
        labels: List.from(_selectedLabels),
      );
      await _noteController.addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        updatedAt: now,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        isArchived: _isArchived,
        imageUrl: _imageUrl,
        signatureUrl: _signatureUrl,
        labels: List.from(_selectedLabels),
      );
      await _noteController.updateNote(updatedNote);
    }
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _lastSaved = DateFormat('jm').format(now);
      });
      Navigator.pop(context);
    }
  }

  Future<void> _updateFirestoreIfExisting() async {
    if (widget.note != null) {
      final now = DateTime.now();
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _selectedColor,
        updatedAt: now,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        isArchived: _isArchived,
        imageUrl: _imageUrl,
        signatureUrl: _signatureUrl,
        labels: List.from(_selectedLabels),
      );
      await _noteController.updateNote(updatedNote);
    }
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
        await _noteController.deleteNote(widget.note!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _restoreNote() async {
    if (widget.note != null) {
      await _noteController.restoreNote(widget.note!.id);
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
        await _noteController.deleteNotePermanently(widget.note!.id);
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
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _isSaving 
          ? Text('Saving...', style: TextStyle(color: contrastColor.withValues(alpha: 0.6), fontSize: 14))
          : (_lastSaved.isNotEmpty ? Text('Saved at $_lastSaved', style: TextStyle(color: contrastColor.withValues(alpha: 0.6), fontSize: 14)) : null),
        leading: IconButton(
          icon: Icon(Icons.close, color: contrastColor),
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
                    color: _isPinned ? Colors.blue.shade700 : contrastColor,
                  ),
                  onPressed: () {
                    setState(() => _isPinned = !_isPinned);
                    _updateFirestoreIfExisting();
                  },
                  tooltip: 'Pin note',
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red.shade400 : contrastColor,
                  ),
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    _updateFirestoreIfExisting();
                  },
                  tooltip: 'Favorite note',
                ),
                IconButton(
                  icon: Icon(
                    _isArchived ? Icons.archive : Icons.archive_outlined,
                    color: _isArchived ? Colors.orange.shade700 : contrastColor,
                  ),
                  onPressed: () {
                    setState(() => _isArchived = !_isArchived);
                    _updateFirestoreIfExisting();
                  },
                  tooltip: 'Archive note',
                ),
                const SizedBox(width: 8),
              ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: TextField(
                    controller: _titleController,
                    cursorColor: contrastColor,
                    readOnly: _isDeleted,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: hintColor,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: contrastColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    widget.note != null
                        ? 'Edited • ${DateFormat('MMM d, yyyy • h:mm a').format(widget.note!.updatedAt)}'
                        : 'New Note • ${DateFormat('MMM d, yyyy • h:mm a').format(_creationTime)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: hintColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: AppLoadingWidget(size: 30)),
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
                                    child: const Center(child: AppLoadingWidget(size: 30)),
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
                if (_signatureUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.draw_rounded, size: 16, color: contrastColor.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Text(
                              'Signature',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: contrastColor.withValues(alpha: 0.5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: contrastColor.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: contrastColor.withValues(alpha: 0.08), width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.file(
                                  File(_signatureUrl!),
                                  fit: BoxFit.contain,
                                  height: 120,
                                  color: contrastColor.withValues(alpha: 0.8),
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  if (_signatureUrl != null) {
                                    await _storageService.deleteImage(_signatureUrl!);
                                  }
                                  setState(() => _signatureUrl = null);
                                  _updateFirestoreIfExisting();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.red, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    cursorColor: contrastColor,
                    readOnly: _isDeleted,
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.outfit(fontSize: 18, color: hintColor),
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      height: 1.6,
                      color: contrastColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isDeleted)
            _buildGlassToolbar(contrastColor, hintColor),
          
          if (_isDeleted)
             Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This note is in Trash.',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isDeleted ? null : FloatingActionButton.extended(
        onPressed: _saveNote,
        backgroundColor: contrastColor,
        foregroundColor: Color(_selectedColor),
        icon: const Icon(Icons.check),
        label: const Text('Save'),
      ),
    );
  }

  Widget _buildGlassToolbar(Color contrastColor, Color hintColor) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: contrastColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: contrastColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_wordCount words | $_charCount chars',
                        style: TextStyle(
                          fontSize: 12,
                          color: contrastColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showColorPicker(contrastColor),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: contrastColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(_selectedColor),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: contrastColor.withValues(alpha: 0.2)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.palette_outlined, size: 14, color: contrastColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolbarAction(
                      Icons.add_photo_alternate_rounded,
                      'Image',
                      contrastColor,
                      _isUploading ? null : _pickAndUploadImage,
                    ),
                    _buildToolbarAction(
                      Icons.label_outline_rounded,
                      'Labels',
                      contrastColor,
                      () => _showLabelPicker(contrastColor),
                    ),
                    _buildToolbarAction(
                      Icons.draw_rounded,
                      'Signature',
                      contrastColor,
                      () => _showSignatureDialog(contrastColor),
                    ),
                    if (widget.note != null)
                      _buildToolbarAction(
                        Icons.delete_outline_rounded,
                        'Delete',
                        Colors.red.withValues(alpha: 0.8),
                        _deleteNote,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarAction(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(Color contrastColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Color',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _colors.map((colorValue) {
                  final isSelected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = colorValue);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.black12,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLabelPicker(Color contrastColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Labels',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final newLabel = await _showCreateLabelDialogInline();
                      if (newLabel != null) {
                        setModalState(() {});
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'New Label',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                final availableLabels = _noteController.labels;
                if (availableLabels.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No labels created yet.'),
                    ),
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableLabels.map((label) {
                    final isSelected = _selectedLabels.contains(label);
                    return GestureDetector(
                      onLongPress: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context); // Close label picker bottom sheet
                        _showDeleteLabelDialog(label);
                      },
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedLabels.add(label);
                            } else {
                              _selectedLabels.remove(label);
                            }
                          });
                          setModalState(() {});
                          _updateFirestoreIfExisting();
                        },
                        selectedColor: Colors.blue.withValues(alpha: 0.2),
                        checkmarkColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showCreateLabelDialogInline() async {
    final controller = TextEditingController();
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Label name',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (newLabel != null && newLabel.isNotEmpty) {
      try {
        await _noteController.addLabel(newLabel);
        setState(() {
          if (!_selectedLabels.contains(newLabel)) {
            _selectedLabels.add(newLabel);
          }
        });
        _updateFirestoreIfExisting();
        return newLabel;
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to create label: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    }
    return null;
  }

  void _showDeleteLabelDialog(String labelName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Label'),
        content: Text('Are you sure you want to delete the label "$labelName"? This will remove it from all notes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _noteController.deleteLabel(labelName);
              setState(() {
                _selectedLabels.remove(labelName);
              });
              Get.snackbar(
                'Label Deleted',
                'Label "$labelName" has been removed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                colorText: Colors.red,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _showSignatureDialog(Color contrastColor) {
    HapticFeedback.mediumImpact();
    // Re-initialize controller with correct color to avoid final field error
    _sigController = SignatureController(
      penStrokeWidth: 3,
      penColor: contrastColor.withValues(alpha: 0.8),
      exportBackgroundColor: Colors.transparent,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Color(_selectedColor).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: contrastColor.withValues(alpha: 0.1), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.draw_rounded, color: contrastColor),
              const SizedBox(width: 12),
              Text(
                'Add Signature', 
                style: GoogleFonts.poppins(
                  color: contrastColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 250,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: contrastColor.withValues(alpha: 0.05),
                  border: Border.all(color: contrastColor.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Signature(
                    controller: _sigController,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSigAction(Icons.undo, 'Undo', contrastColor, () => _sigController.undo()),
                  const SizedBox(width: 24),
                  _buildSigAction(Icons.clear, 'Clear', contrastColor, () => _sigController.clear()),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _sigController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel', 
                style: GoogleFonts.poppins(
                  color: contrastColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_sigController.isNotEmpty) {
                  final Uint8List? data = await _sigController.toPngBytes();
                  if (data != null) {
                    final path = await _storageService.saveImageFromBytes(data, 'signatures');
                    if (mounted) {
                      setState(() {
                        _signatureUrl = path;
                      });
                    }
                    _updateFirestoreIfExisting();
                  }
                }
                if (mounted) Get.back();
                _sigController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: contrastColor,
                foregroundColor: Color(_selectedColor),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Save Signature',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSigAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
