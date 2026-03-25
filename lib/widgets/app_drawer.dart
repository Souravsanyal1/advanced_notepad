import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../services/profile_service.dart';
import '../services/local_storage_service.dart';
import '../services/theme_service.dart';
import '../services/photo_service.dart';
import '../controllers/note_controller.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final LocalStorageService _storageService = LocalStorageService();
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();
  final NoteController _noteController = Get.find<NoteController>();
  final ThemeService _themeService = Get.find<ThemeService>();

  late AnimationController _rotationController;

  String? _profileImageUrl;
  String _userName = 'Advanced User';
  bool _isUploadingProfile = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _profileService.addListener(_loadProfileData);
    _loadProfileData();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _profileService.removeListener(_loadProfileData);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final url = await _profileService.getProfilePhoto();
    final name = await _profileService.getUserName();
    if (mounted) {
      setState(() {
        _profileImageUrl = url;
        _userName = name;
      });
    }
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image == null) return;

      final bool hasPermission = await _photoService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gallery permission is required to update profile photo.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => _photoService.openSettings(),
              ),
            ),
          );
        }
        return;
      }

      setState(() => _isUploadingProfile = true);

      final String? savedPath = await _storageService.saveImage(File(image.path), 'profile_photos');

      if (savedPath != null) {
        if (_profileImageUrl != null && !_profileImageUrl!.startsWith('http')) {
          await _storageService.deleteImage(_profileImageUrl!);
        }

        await _profileService.setProfilePhoto(savedPath);
        if (mounted) {
          setState(() {
            _profileImageUrl = savedPath;
            _isUploadingProfile = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully!')),
          );
        }
      } else {
        setState(() => _isUploadingProfile = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile photo.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingProfile = false);
      debugPrint('Error updating profile: $e');
    }
  }

  void _editName() async {
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _profileService.setUserName(newName);
      setState(() => _userName = newName);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.brightness == Brightness.dark 
          ? const Color(0xFF0D0D0D) 
          : const Color(0xFFFBFBFF),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [Colors.black, const Color(0xFF1A1A2E).withValues(alpha: 0.1)]
                : [Colors.white, const Color(0xFFF0F2F5)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.brightness == Brightness.dark
                    ? [
                        const Color(0xFF141E30),
                        const Color(0xFF243B55),
                      ]
                    : [
                        const Color(0xFFE0C3FC),
                        const Color(0xFF8EC5FC),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: GestureDetector(
              onTap: _isUploadingProfile ? null : _pickAndUploadProfilePhoto,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rainbow Border with Rotation Animation
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 76,
                      height: 76,
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
                  // Inner Background Mask
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.brightness == Brightness.dark ? const Color(0xFF141E30) : Colors.white,
                    ),
                  ),
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImageUrl != null
                        ? (_profileImageUrl!.startsWith('http')
                            ? CachedNetworkImageProvider(_profileImageUrl!)
                            : FileImage(File(_profileImageUrl!)) as ImageProvider)
                        : null,
                    child: _profileImageUrl == null && !_isUploadingProfile
                        ? const Icon(Icons.person, size: 38, color: Colors.white)
                        : (_profileImageUrl != null && !_profileImageUrl!.startsWith('http') && !File(_profileImageUrl!).existsSync()
                            ? const Icon(Icons.person, size: 38, color: Colors.white)
                            : null),
                  ),
                  if (_isUploadingProfile)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            accountName: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userName,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _editName,
                  child: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white70),
                ),
              ],
            ),
            accountEmail: null,
          ),
          Obx(() => _DrawerItem(
            icon: Icons.notes_rounded,
            label: 'All Notes',
            isSelected: _noteController.selectedLabel.value.isEmpty,
            onTap: () {
              _noteController.setSelectedLabel(null);
              Navigator.pop(context);
            },
            trailing: _buildBadge(_noteController.allNotes.length, theme),
          )),
          Obx(() => _DrawerItem(
            icon: Icons.favorite_outline_rounded,
            label: 'Favorites',
            trailing: _buildBadge(_noteController.favoriteNotes.length, theme),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/favorites');
            },
          )),
          Obx(() => _DrawerItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            trailing: _buildBadge(_noteController.archivedNotes.length, theme),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/archive');
            },
          )),
           Obx(() => _DrawerItem(
            icon: Icons.delete_outline_rounded,
            label: 'Trash',
            trailing: _buildBadge(_noteController.trashNotes.length, theme),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/trash');
            },
          )),
          _buildCustomDivider(theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Text(
              'LABELS', 
              style: GoogleFonts.outfit(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: theme.colorScheme.primary.withValues(alpha: 0.6), 
                letterSpacing: 1.5
              )
            ),
          ),
          // Personal & Work Labels (Dynamic)
          Obx(() => Column(
            children: _noteController.labels.map((label) {
              final count = _noteController.allNotes.where((n) => n.labels.contains(label)).length;
              return _DrawerItem(
                icon: Icons.label_outline_rounded,
                label: label,
                isSelected: _noteController.selectedLabel.value == label,
                trailing: _buildBadge(count, theme),
                onTap: () {
                  _noteController.setSelectedLabel(label);
                  Navigator.pop(context);
                },
                onLongPress: () => _showDeleteLabelDialog(label),
              );
            }).toList(),
          )),

          _DrawerItem(
            icon: Icons.add_rounded,
            label: 'Create new Label',
            onTap: () => _showCreateLabelDialog(),
          ),

          _buildCustomDivider(theme),
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SwitchListTile(
              title: Text('Dark Mode', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              secondary: Icon(
                _themeService.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: _themeService.isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              value: _themeService.isDarkMode,
              onChanged: (value) => _themeService.toggleTheme(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
          _buildCustomDivider(theme),
          _DrawerItem(
            icon: Icons.info_outline,
            label: 'About',
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/about');
            },
          ),
          _DrawerItem(
            icon: Icons.favorite_rounded,
            label: 'Support the Project',
            onTap: () {
              Navigator.pop(context);
              _showDonationDialog(context);
            },
          ),
          _DrawerItem(
            icon: Icons.system_update_alt,
            label: 'Update',
            onTap: () => _showUpdateDialog(context),
          ),
          _buildCustomDivider(theme),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'App Version: 1.0.1+2',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCustomDivider(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  Widget _buildBadge(int count, ThemeData theme) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _showDeleteLabelDialog(String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Label'),
        content: Text('Are you sure you want to delete the label "$label"? This will remove it from all notes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _noteController.deleteLabel(label);
                Get.snackbar(
                  'Success',
                  'Label "$label" deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete label: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
 
  void _showDonationDialog(BuildContext context) {
    Get.toNamed('/donation');
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 10),
            Text('App Update'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'You are using the latest version!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0+1'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showCreateLabelDialog() async {
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
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.trailing,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Stack(
        children: [
          ListTile(
            leading: Icon(
              icon, 
              color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color?.withValues(alpha: 0.7)
            ),
            title: Text(
              label, 
              style: GoogleFonts.outfit(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
              )
            ),
            trailing: trailing,
            selected: isSelected,
            selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            onTap: onTap,
            onLongPress: onLongPress,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          if (isSelected)
            Positioned(
              left: 0,
              top: 12,
              bottom: 12,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 0),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
