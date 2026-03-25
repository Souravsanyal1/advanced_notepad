import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/note_card.dart';
import '../widgets/app_drawer.dart';
import '../services/profile_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:upgrader/upgrader.dart';
import 'edit_note_screen.dart';

import 'package:get/get.dart';
import '../models/note.dart';
import '../controllers/note_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final NoteController _noteController = Get.find<NoteController>();
  final ProfileService _profileService = ProfileService();
  final RxString _searchQuery = ''.obs;
  String? _profileImageUrl;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _profileService.addListener(_loadProfile);
    _loadProfile();
    
    // Check for arguments and set selected label
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? routeLabel = ModalRoute.of(context)?.settings.arguments as String?;
      if (routeLabel != null) {
        _noteController.setSelectedLabel(routeLabel);
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _profileService.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final url = await _profileService.getProfilePhoto();
    if (mounted) {
      setState(() => _profileImageUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      drawer: const AppDrawer(),
      body: UpgradeAlert(
        upgrader: Upgrader(),
        dialogStyle: UpgradeDialogStyle.material,
        showIgnore: false,
        child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Obx(() => Text(
              _noteController.selectedLabel.value.isEmpty ? 'My Notes' : _noteController.selectedLabel.value, 
              style: const TextStyle(fontWeight: FontWeight.bold)
            )),
            floating: true,
            snap: true,
            pinned: true,
            elevation: innerBoxIsScrolled ? 4 : 0,
            forceElevated: innerBoxIsScrolled,
            leading: Obx(() => _noteController.selectedLabel.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _noteController.setSelectedLabel(null),
                )
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                )),
            actions: [
              Obx(() => IconButton(
                onPressed: () => _showFilterSheet(context), 
                icon: Icon(
                  _noteController.currentFilter.value == NoteFilter.all 
                    ? Icons.filter_list_rounded 
                    : Icons.filter_alt_rounded,
                  color: _noteController.currentFilter.value == NoteFilter.all 
                    ? null 
                    : theme.colorScheme.primary,
                ),
              )),
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Rainbow Border
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.red,
                                Colors.orange,
                                Colors.yellow,
                                Colors.green,
                                Colors.blue,
                                Colors.indigo,
                                Colors.purple,
                                Colors.red,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Inner background to mask the border
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                        ),
                      ),
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: _profileImageUrl != null
                            ? (_profileImageUrl!.startsWith('http')
                                ? CachedNetworkImageProvider(_profileImageUrl!)
                                : FileImage(File(_profileImageUrl!)) as ImageProvider)
                            : null,
                        child: _profileImageUrl == null
                            ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 18)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => _searchQuery.value = value,
                    decoration: const InputDecoration(
                      hintText: 'Search your notes...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            _buildLabelSelector(theme),
            Expanded(
              child: Obx(() {
                final filteredNotes = _noteController.filteredNotes.where((note) {
                  return note.title.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
                      note.content.toLowerCase().contains(_searchQuery.value.toLowerCase());
                }).toList();

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_note_rounded, size: 80, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _searchQuery.isEmpty ? 'Begin your journey' : 'No matches found',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty ? 'Tap the button below to create a note' : 'Try a different keyword',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
                final otherNotes = filteredNotes.where((n) => !n.isPinned).toList();

                return AnimationLimiter(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (pinnedNotes.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text('PINNED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            children: pinnedNotes.map((note) {
                              final index = pinnedNotes.indexOf(note);
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 400),
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
                                          _showNoteOptions(note);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      if (otherNotes.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Text('OTHERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            children: otherNotes.map((note) {
                              final index = otherNotes.indexOf(note);
                              final staggeredIndex = index + pinnedNotes.length;
                              return AnimationConfiguration.staggeredGrid(
                                position: staggeredIndex,
                                duration: const Duration(milliseconds: 400),
                                columnCount: 2,
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
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
                                          _showNoteOptions(note);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openColor: theme.colorScheme.surface,
        closedElevation: 6,
        closedColor: theme.colorScheme.primaryContainer,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        openBuilder: (context, action) => const EditNoteScreen(),
        closedBuilder: (context, action) => SizedBox(
          height: 56,
          width: 140,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text('New Note', style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteOptions(Note note) {
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
                _noteController.togglePin(note);
              },
            ),
            ListTile(
              leading: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
              title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                _noteController.toggleFavorite(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline_rounded),
              title: const Text('Labels'),
              onTap: () {
                Navigator.pop(context);
                _showLabelSelectionDialog(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                _noteController.toggleArchive(note);
                Get.snackbar('Archived', 'Note moved to archive', snackPosition: SnackPosition.BOTTOM);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _noteController.moveToTrash(note);
                Get.snackbar('Deleted', 'Note moved to trash', snackPosition: SnackPosition.BOTTOM);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLabelSelectionDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Labels'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._noteController.labels.map((label) {
                final isSelected = note.labels.contains(label);
                return GestureDetector(
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context); // Close selection dialog
                    _showDeleteLabelDialog(label);
                  },
                  child: CheckboxListTile(
                    title: Text(label),
                    value: isSelected,
                    onChanged: (value) {
                      if (value == true) {
                        _noteController.addLabelToNote(note, label);
                      } else {
                        _noteController.removeLabelFromNote(note, label);
                      }
                    },
                  ),
                );
              }),
              if (_noteController.labels.isEmpty)
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

  Widget _buildLabelSelector(ThemeData theme) {
    return Obx(() {
      final labels = ['All', ..._noteController.labels];
      final activeLabel = _noteController.selectedLabel.value;
      
      return Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: labels.length,
          itemBuilder: (context, index) {
            final label = labels[index];
            final isSelected = (label == 'All' && activeLabel.isEmpty) || label == activeLabel;
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.lightImpact();
                    _noteController.setSelectedLabel(label == 'All' ? null : label);
                  }
                },
                onLongPress: label == 'All' ? null : () {
                  HapticFeedback.heavyImpact();
                  _showDeleteLabelDialog(label);
                },
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
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

  void _showFilterSheet(BuildContext context) {
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
              'Filter Notes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              context,
              filter: NoteFilter.all,
              icon: Icons.notes_rounded,
              label: 'Everything',
              subtitle: 'Show all your notes',
            ),
            _buildFilterDivider(theme),
            _buildFilterOption(
              context,
              filter: NoteFilter.dateNewest,
              icon: Icons.history_rounded,
              label: 'Latest First',
              subtitle: 'Newest notes at the top',
            ),
            _buildFilterOption(
              context,
              filter: NoteFilter.dateOldest,
              icon: Icons.update_rounded,
              label: 'Oldest First',
              subtitle: 'Classic notes at the top',
            ),
            _buildFilterDivider(theme),
            _buildFilterOption(
              context,
              filter: NoteFilter.hasSignature,
              icon: Icons.gesture_rounded,
              label: 'With Signature',
              subtitle: 'Hand-signed special notes',
            ),
            _buildFilterOption(
              context,
              filter: NoteFilter.hasImage,
              icon: Icons.image_outlined,
              label: 'With Photos',
              subtitle: 'Notes with visual memories',
            ),
            _buildFilterDivider(theme),
            _buildFilterOption(
              context,
              filter: NoteFilter.byDate,
              icon: Icons.calendar_today_rounded,
              label: 'Specific Date',
              subtitle: _noteController.selectedDate.value != null 
                ? 'Filtering by ${_noteController.selectedDate.value!.day}/${_noteController.selectedDate.value!.month}/${_noteController.selectedDate.value!.year}'
                : 'Choose a calendar day',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _handleFilterTap(NoteFilter filter) async {
    if (filter == NoteFilter.byDate) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _noteController.selectedDate.value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Theme.of(context).colorScheme.onPrimary,
                onSurface: Theme.of(context).colorScheme.onSurface,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        _noteController.setFilter(filter, date: picked);
        if (mounted) Navigator.pop(context);
      }
    } else {
      _noteController.setFilter(filter);
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required NoteFilter filter,
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = _noteController.currentFilter.value == filter;
      
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.colorScheme.primaryContainer 
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) 
            : null,
        onTap: () {
          HapticFeedback.lightImpact();
          _handleFilterTap(filter);
        },
      );
    });
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
