import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/note.dart';
import '../../services/firestore_service.dart';
import '../../widgets/note_card.dart';
import 'edit_note_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final archivedNotes = (snapshot.data ?? []).where((note) => note.isArchived).toList();

          if (archivedNotes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No archived notes'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemBuilder: (context, index) {
                return NoteCard(
                  note: archivedNotes[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(note: archivedNotes[index]),
                    ),
                  ),
                );
              },
              itemCount: archivedNotes.length,
            ),
          );
        },
      ),
    );
  }
}
