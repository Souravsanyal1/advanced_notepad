import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../widgets/note_card.dart';
import '../widgets/app_drawer.dart';
import '../services/profile_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:upgrader/upgrader.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ProfileService _profileService = ProfileService();
  String _searchQuery = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_loadProfile);
    _loadProfile();
  }

  @override
  void dispose() {
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
        upgrader: Upgrader(
          dialogStyle: UpgradeDialogStyle.material,
          showIgnore: false,
        ),
        child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            floating: true,
            snap: true,
            pinned: true,
            elevation: innerBoxIsScrolled ? 4 : 0,
            forceElevated: innerBoxIsScrolled,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: _profileImageUrl != null
                        ? CachedNetworkImageProvider(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 20)
                        : null,
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
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search your notes...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<Note>>(
          stream: _firestoreService.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final notes = (snapshot.data ?? []).where((note) => !note.isArchived).toList();
            final filteredNotes = notes.where((note) {
              return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  note.content.toLowerCase().contains(_searchQuery.toLowerCase());
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
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          final note = pinnedNotes[index];
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
                                  closedBuilder: (context, action) => NoteCard(note: note, onTap: action),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: pinnedNotes.length,
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
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          final note = otherNotes[index];
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
                                  closedBuilder: (context, action) => NoteCard(note: note, onTap: action),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: otherNotes.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ],
              ),
            );
          },
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
}
