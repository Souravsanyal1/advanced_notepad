import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../widgets/note_card.dart';
import 'edit_note_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Note>>(
        stream: firestoreService.getNotes(isFavorite: true, isDeleted: false, isArchived: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favoriteNotes = snapshot.data ?? [];

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
                  const Text('Mark some notes as favorite to see them here', style: TextStyle(color: Colors.grey)),
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
                          closedBuilder: (context, action) => NoteCard(note: note, onTap: action),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
