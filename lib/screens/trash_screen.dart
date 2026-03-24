import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../widgets/note_card.dart';
import 'edit_note_screen.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final deletedNotes = noteController.trashNotes;

        if (deletedNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded, size: 80, color: theme.colorScheme.error),
                ),
                const SizedBox(height: 16),
                Text('Trash is empty', style: theme.textTheme.titleMedium),
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
              itemCount: deletedNotes.length,
              itemBuilder: (context, index) {
                final note = deletedNotes[index];
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
                        closedBuilder: (context, action) => NoteCard(note: note, onTap: action),
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
}
