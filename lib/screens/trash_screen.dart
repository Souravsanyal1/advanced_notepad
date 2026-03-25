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
        actions: [
          Obx(() => IconButton(
            onPressed: () => _showFilterSheet(context, noteController), 
            icon: Icon(
              noteController.currentFilter.value == NoteFilter.all 
                ? Icons.filter_list_rounded 
                : Icons.filter_alt_rounded,
              color: noteController.currentFilter.value == NoteFilter.all 
                ? null 
                : theme.colorScheme.error,
            ),
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final deletedNotes = noteController.filteredTrashNotes;

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

  void _showFilterSheet(BuildContext context, NoteController noteController) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter Trash',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.all,
              icon: Icons.notes_rounded,
              label: 'Everything',
              subtitle: 'Show all deleted notes',
            ),
            _buildFilterDivider(theme),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.dateNewest,
              icon: Icons.history_rounded,
              label: 'Latest First',
              subtitle: 'Recently deleted at the top',
            ),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.dateOldest,
              icon: Icons.update_rounded,
              label: 'Oldest First',
              subtitle: 'Long ago deleted at the top',
            ),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.byDate,
              icon: Icons.calendar_today_rounded,
              label: 'Filter by Date',
              subtitle: noteController.selectedDate.value == null 
                ? 'Select a specific day'
                : 'Showing notes from ${_formatDate(noteController.selectedDate.value!)}',
            ),
            _buildFilterDivider(theme),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.hasSignature,
              icon: Icons.gesture_rounded,
              label: 'With Signature',
              subtitle: 'Hand-signed deleted notes',
            ),
            _buildFilterOption(
              context,
              noteController,
              filter: NoteFilter.hasImage,
              icon: Icons.image_outlined,
              label: 'With Photos',
              subtitle: 'Notes with visual memories',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    NoteController noteController, {
    required NoteFilter filter,
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = noteController.currentFilter.value == filter;
      
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.error : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.error) 
            : null,
        onTap: () async {
          if (filter == NoteFilter.byDate) {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: noteController.selectedDate.value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              noteController.setFilter(NoteFilter.byDate, date: picked);
              if (context.mounted) Navigator.pop(context);
            }
          } else {
            noteController.setFilter(filter);
            Navigator.pop(context);
          }
        },
      );
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildFilterDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(
        height: 1,
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }
}
