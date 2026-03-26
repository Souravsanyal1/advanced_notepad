import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../services/profile_service.dart';
import '../services/theme_service.dart';
import '../controllers/note_controller.dart';
import 'loading_widget.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  final NoteController _noteController = Get.find<NoteController>();

  late AnimationController _rotationController;
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  // For the sliding pill
  int _selectedIndex = 0;

  // Profile data
  String _userName = 'User';
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

    _profileService.addListener(_loadProfileData);
    _loadProfileData();

    // Initial Selection Sync
    _calculateInitialSelection();
  }

  void _calculateInitialSelection() {
    final currentRoute = Get.currentRoute;
    final selectedLabel = _noteController.selectedLabel.value;

    if (currentRoute == '/favorites') {
      _selectedIndex = 1;
    } else if (currentRoute == '/archive') {
      _selectedIndex = 2;
    } else if (currentRoute == '/trash') {
      _selectedIndex = 3;
    } else if (selectedLabel.isNotEmpty) {
      final labelIndex = _noteController.labels.indexOf(selectedLabel);
      if (labelIndex != -1) {
        _selectedIndex = 100 + labelIndex;
      } else {
        _selectedIndex = 0;
      }
    } else {
      _selectedIndex = 0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sheenController.dispose();
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

    final newName = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Name',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[900]?.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.1,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'EDIT PROFILE NAME',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLength: 15,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.outfit(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.4),
                        ),
                        filled: true,
                        fillColor: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.outfit(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [Colors.white, Colors.grey[300]!]
                                    : [Colors.black, Colors.grey[800]!],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(
                                context,
                                controller.text.trim(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'SAVE CHANGES',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      if (mounted) {
        setState(() => _userName = newName);
      }
      await _profileService.setUserName(newName);
    }
  }

  void _onItemTapped(int index) {
    if (mounted) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = index;
      });
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
              child: ListView(
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
                  _buildThemeSection(theme, isDark),
                  const SizedBox(height: 16),
                  _buildLabelSection(theme),
                ],
              ),
            ),
            _buildBottomSection(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(ThemeData theme, bool isDark) {
    final themeService = Get.find<ThemeService>();
    return Obx(() {
      final currentMode = themeService.themeMode;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'THEME',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.05,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.05,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildThemeToggleItem(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () => themeService.setThemeMode(ThemeMode.light),
                    isDark: isDark,
                  ),
                  _buildThemeToggleItem(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () => themeService.setThemeMode(ThemeMode.dark),
                    isDark: isDark,
                  ),
                  _buildThemeToggleItem(
                    icon: Icons
                        .settings_brightness_rounded, // or Icons.system_update_alt_rounded
                    label: 'System',
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () => themeService.setThemeMode(ThemeMode.system),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildThemeToggleItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 1.0,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme, bool isDark) {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B3E) : const Color(0xFFF1F5F9),
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
                    // Elite Colorful Chrome Aura
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFF00ACC1),
                              const Color(0xFF8E24AA),
                              const Color(0xFF0D1B3E),
                              const Color(0xFF00ACC1),
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
                                : FileImage(File(_profileImageUrl!))
                                      as ImageProvider)
                          : null,
                      child: _isUploadingProfile
                          ? const AppLoadingWidget(size: 20)
                          : (_profileImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                : null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Name & Edit Button with Rainbow Border
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00ACC1),
                      Color(0xFF8E24AA),
                      Color(0xFF0D1B3E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5), // Border thickness
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _userName.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2.0,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _editName,
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PREMIUM MEMBER',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.4,
                  ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF00ACC1).withValues(alpha: 0.8),
                    const Color(0xFF8E24AA).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected && isDark
              ? Colors.white.withValues(alpha: 0.02)
              : !isSelected && !isDark
                  ? Colors.black.withValues(alpha: 0.02)
                  : null,
          border: !isSelected
              ? Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.05,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: isSelected
              ? const EdgeInsets.all(1.5) // Border thickness
              : EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? Colors.black.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(isSelected ? 10.5 : 12),
            ),
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
          trailing: count != null
              ? Text(
                  count.toString(),
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.3,
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
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
          ...labels.map(
            (label) => _buildDrawerItem(
              index: 100 + labels.indexOf(label), // Offset to avoid collisions
              icon: Icons.label_outline_rounded,
              label: label,
              onTap: () {
                _onItemTapped(100 + labels.indexOf(label));
                _noteController.setSelectedLabel(label);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBottomSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _buildBottomItem(
            Icons.info_outline,
            'About',
            () => Get.toNamed('/about'),
          ),
          _buildBottomItem(
            Icons.favorite_rounded,
            'Support Us',
            () => Get.toNamed('/donation'),
          ),
          const SizedBox(height: 12),
          Text(
            'VERSION 1.0.2',
            style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.05,
            ),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          dense: true,
          leading: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          title: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
