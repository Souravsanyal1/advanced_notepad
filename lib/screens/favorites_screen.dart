import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../models/note.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_card.dart';
import 'edit_note_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final favoriteNotes = noteController.favoriteNotes;

        if (favoriteNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_rounded, size: 80, color: Colors.red.shade400),
                ),
                const SizedBox(height: 16),
                Text('No favorites yet', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Mark some notes as favorite to see them here', 
                  style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return AnimationLimiter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: favoriteNotes.length,
              itemBuilder: (context, index) {
                final note = favoriteNotes[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: OpenContainer(
                        transitionDuration: const Duration(milliseconds: 500),
                        openColor: Color(note.color),
                        closedColor: Colors.transparent,
                        closedElevation: 0,
                        openElevation: 0,
                        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        openBuilder: (context, action) => EditNoteScreen(note: note),
                        closedBuilder: (context, action) => NoteCard(
                          note: note, 
                          onTap: action,
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            _showNoteOptions(context, noteController, note);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _showNoteOptions(BuildContext context, NoteController noteController, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(context);
                noteController.togglePin(note);
              },
            ),
            ListTile(
              leading: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
              title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                noteController.toggleFavorite(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline_rounded),
              title: const Text('Labels'),
              onTap: () {
                Navigator.pop(context);
                _showLabelSelectionDialog(context, noteController, note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                noteController.toggleArchive(note);
                Get.snackbar('Archived', 'Note moved to archive', snackPosition: SnackPosition.BOTTOM);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                noteController.moveToTrash(note);
                Get.snackbar('Deleted', 'Note moved to trash', snackPosition: SnackPosition.BOTTOM);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLabelSelectionDialog(BuildContext context, NoteController noteController, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Labels'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...noteController.labels.map((label) {
                final isSelected = note.labels.contains(label);
                return CheckboxListTile(
                  title: Text(label),
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      noteController.addLabelToNote(note, label);
                    } else {
                      noteController.removeLabelFromNote(note, label);
                    }
                  },
                );
              }),
              if (noteController.labels.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No labels created yet.'),
                ),
            ],
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
