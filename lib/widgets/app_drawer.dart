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

class _AppDrawerState extends State<AppDrawer> {
  final ProfileService _profileService = ProfileService();
  final LocalStorageService _storageService = LocalStorageService();
  final PhotoService _photoService = PhotoService();
  final ImagePicker _picker = ImagePicker();
  final NoteController _noteController = Get.find<NoteController>();
  final ThemeService _themeService = Get.find<ThemeService>();

  String? _profileImageUrl;
  String _userName = 'Advanced User';
  bool _isUploadingProfile = false;

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_loadProfileData);
    _loadProfileData();
  }

  @override
  void dispose() {
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: GestureDetector(
              onTap: _isUploadingProfile ? null : _pickAndUploadProfilePhoto,
              child: Stack(
                children: [
                   CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImageUrl != null
                        ? (_profileImageUrl!.startsWith('http')
                            ? CachedNetworkImageProvider(_profileImageUrl!)
                            : FileImage(File(_profileImageUrl!)) as ImageProvider)
                        : null,
                    child: _profileImageUrl == null && !_isUploadingProfile
                        ? const Icon(Icons.person, size: 42, color: Colors.white)
                        : (_profileImageUrl != null && !_profileImageUrl!.startsWith('http') && !File(_profileImageUrl!).existsSync()
                            ? const Icon(Icons.person, size: 42, color: Colors.white)
                            : null),
                  ),
                  if (_isUploadingProfile)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                   Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
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
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('LABELS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
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

          const Divider(),
          Obx(() => SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _themeService.isDarkMode,
            onChanged: (value) => _themeService.toggleTheme(),
          )),
          const Divider(),
          _DrawerItem(
            icon: Icons.info_outline,
            label: 'About',
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/about');
            },
          ),
          _DrawerItem(
            icon: Icons.favorite_border,
            label: 'Donation',
            onTap: () => _showDonationDialog(context),
          ),
          _DrawerItem(
            icon: Icons.system_update_alt,
            label: 'Update',
            onTap: () => _showUpdateDialog(context),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Version: 1.0.1+2',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFFF5252), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Support Us',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'If you love using Advanced Notepad, consider supporting our development journey!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3F75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment ID: sourav@upi',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Maybe Later',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5B4F1),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Donate Now',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          backgroundColor: Colors.red.withOpacity(0.8),
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
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color
      ),
      title: Text(
        label, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
        )
      ),
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      onTap: onTap,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
