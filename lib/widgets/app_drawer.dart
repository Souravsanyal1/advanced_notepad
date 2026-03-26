import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../services/profile_service.dart';
import '../controllers/note_controller.dart';
import 'loading_widget.dart';


class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  final NoteController _noteController = Get.find<NoteController>();


  late AnimationController _rotationController;
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;
  
  // For the sliding pill
  int _selectedIndex = 0;
  late AnimationController _pillController;
  late Animation<double> _pillPositionAnimation;

  // Profile data
  String _userName = 'Advanced User';
  String? _profileImageUrl;
  bool _isUploadingProfile = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sheenAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _sheenController, curve: Curves.easeInOut),
    );

    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pillPositionAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _pillController, curve: Curves.elasticOut),
    );

    _profileService.addListener(_loadProfileData);
    _loadProfileData();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sheenController.dispose();
    _pillController.dispose();
    _profileService.removeListener(_loadProfileData);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final name = await _profileService.getUserName();
    final url = await _profileService.getProfilePhoto();
    if (mounted) {
      setState(() {
        _userName = name;
        _profileImageUrl = url;
      });
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() => _isUploadingProfile = true);
        await _profileService.setProfilePhoto(image.path);
        setState(() => _isUploadingProfile = false);
        Get.snackbar(
          'Success',
          'Profile photo updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isUploadingProfile = false);
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _editName() async {
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('EDIT NAME', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _profileService.setUserName(newName);
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
      _pillPositionAnimation = Tween<double>(
        begin: _pillPositionAnimation.value,
        end: index.toDouble(),
      ).animate(
        CurvedAnimation(parent: _pillController, curve: Curves.elasticOut),
      );
      _pillController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withValues(alpha: 0.9) : Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            _buildPremiumHeader(theme, isDark),
            Expanded(
              child: Stack(
                children: [
                  // Sliding Pill Indicator
                  AnimatedBuilder(
                    animation: _pillPositionAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 2 + (_pillPositionAnimation.value * 52), // 52 is item height + margin
                        left: 8,
                        child: Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDrawerItem(
                        index: 0,
                        icon: Icons.notes_rounded,
                        label: 'All Notes',
                        onTap: () {
                          _onItemTapped(0);
                          _noteController.setSelectedLabel(null);
                          Navigator.pop(context);
                        },
                        count: _noteController.allNotes.length,
                      ),
                      _buildDrawerItem(
                        index: 1,
                        icon: Icons.favorite_outline_rounded,
                        label: 'Favorites',
                        onTap: () {
                          _onItemTapped(1);
                          Navigator.pop(context);
                          Get.toNamed('/favorites');
                        },
                        count: _noteController.favoriteNotes.length,
                      ),
                      _buildDrawerItem(
                        index: 2,
                        icon: Icons.archive_outlined,
                        label: 'Archive',
                        onTap: () {
                          _onItemTapped(2);
                          Navigator.pop(context);
                          Get.toNamed('/archive');
                        },
                        count: _noteController.archivedNotes.length,
                      ),
                      _buildDrawerItem(
                        index: 3,
                        icon: Icons.delete_outline_rounded,
                        label: 'Trash',
                        onTap: () {
                          _onItemTapped(3);
                          Navigator.pop(context);
                          Get.toNamed('/trash');
                        },
                        count: _noteController.trashNotes.length,
                      ),
                      const Divider(indent: 20, endIndent: 20, height: 32),
                      _buildLabelSection(theme),
                    ],
                  ),
                ],
              ),
            ),
            _buildBottomSection(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme, bool isDark) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Gloss Sheen Animation
          AnimatedBuilder(
            animation: _sheenAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment(_sheenAnimation.value, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: isDark ? 0.03 : 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.5, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _isUploadingProfile ? null : _pickAndUploadProfilePhoto,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Monochrome Chrome Aura
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFF000000),
                              Color(0xFF333333),
                              Color(0xFF666666),
                              Color(0xFF999999),
                              Color(0xFFCCCCCC),
                              Color(0xFFFFFFFF),
                              Color(0xFFCCCCCC),
                              Color(0xFF999999),
                              Color(0xFF666666),
                              Color(0xFF333333),
                              Color(0xFF000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _profileImageUrl != null
                          ? (_profileImageUrl!.startsWith('http')
                              ? CachedNetworkImageProvider(_profileImageUrl!)
                              : FileImage(File(_profileImageUrl!)) as ImageProvider)
                          : null,
                      child: _isUploadingProfile 
                          ? const AppLoadingWidget(size: 20)
                          : (_profileImageUrl == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _userName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 2.0,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_rounded, size: 18, 
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5)),
                    onPressed: _editName,
                  ),
                ],
              ),
              Text(
                'PREMIUM MEMBER',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int? count,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          icon,
          color: isSelected 
              ? (isDark ? Colors.white : Colors.black) 
              : (isDark ? Colors.white70 : Colors.black54),
          size: 22,
        ),
        title: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
            color: isSelected 
                ? (isDark ? Colors.white : Colors.black) 
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        trailing: count != null ? Text(
          count.toString(),
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLabelSection(ThemeData theme) {
    return Obx(() {
      final labels = _noteController.labels;
      if (labels.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'LABELS',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          ...labels.map((label) => _buildDrawerItem(
            index: 100 + labels.indexOf(label), // Offset to avoid collisions
            icon: Icons.label_outline_rounded,
            label: label,
            onTap: () {
              _onItemTapped(100 + labels.indexOf(label));
              _noteController.setSelectedLabel(label);
              Navigator.pop(context);
            },
          )),
        ],
      );
    });
  }

  Widget _buildBottomSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _buildBottomItem(Icons.info_outline, 'About', () => Get.toNamed('/about')),
          _buildBottomItem(Icons.favorite_rounded, 'Support Us', () => Get.toNamed('/donation')),
          const SizedBox(height: 12),
          Text(
            'VERSION 1.0.2',
            style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, size: 20, color: isDark ? Colors.white54 : Colors.black54),
        title: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

}
