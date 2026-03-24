import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/profile_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/theme_service.dart';


class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final ProfileService _profileService = ProfileService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  String? _profileImageUrl;
  String _userName = 'Advanced User';
  String _userEmail = 'premium@advanced.com';
  bool _isUploadingProfile = false;
  final ThemeService _themeService = ThemeService();
  List<String> _labels = [];


  @override
  void initState() {
    super.initState();
    _profileService.addListener(_loadProfileData);
    _themeService.addListener(_handleThemeChange);
    _loadProfileData();
    _listenToLabels();
  }

  @override
  void dispose() {
    _profileService.removeListener(_loadProfileData);
    _themeService.removeListener(_handleThemeChange);
    super.dispose();
  }

  void _handleThemeChange() {
    if (mounted) setState(() {});
  }

  void _listenToLabels() {
    _firestoreService.getLabels().listen((labels) {
      if (mounted) {
        setState(() {
          _labels = labels;
        });
      }
    });
  }


  Future<void> _loadProfileData() async {
    final url = await _profileService.getProfilePhoto();
    final name = await _profileService.getUserName();
    final email = await _profileService.getUserEmail();
    if (mounted) {
      setState(() {
        _profileImageUrl = url;
        _userName = name;
        _userEmail = email;
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

      setState(() => _isUploadingProfile = true);

      final String? uploadedUrl = await _storageService.uploadImage(File(image.path), 'profile_photos');

      if (uploadedUrl != null) {
        await _profileService.setProfilePhoto(uploadedUrl);
        if (mounted) {
          setState(() {
            _profileImageUrl = uploadedUrl;
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

  void _editEmail() async {
    final controller = TextEditingController(text: _userEmail);
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your email'),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
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

    if (newEmail != null && newEmail.isNotEmpty) {
      await _profileService.setUserEmail(newEmail);
      setState(() => _userEmail = newEmail);
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
                        ? CachedNetworkImageProvider(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null && !_isUploadingProfile
                        ? const Icon(Icons.person, size: 42, color: Colors.white)
                        : null,
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
            accountEmail: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userEmail,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _editEmail,
                  child: const Icon(Icons.alternate_email_rounded, size: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.notes_rounded,
            label: 'All Notes',
            onTap: () => Navigator.pop(context),
            trailing: StreamBuilder<int>(
              stream: _firestoreService.getNoteCount(),
              builder: (context, snapshot) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${snapshot.data ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              },
            ),
          ),
          _DrawerItem(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/archive');
            },
          ),
           _DrawerItem(
            icon: Icons.delete_outline_rounded,
            label: 'Trash',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trash');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('LABELS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          ),
          // Personal & Work Labels (Dynamic)
          ..._labels.map((label) => _DrawerItem(
            icon: Icons.label_outline_rounded,
            label: label,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home', arguments: label);
            },
          )),

          _DrawerItem(
            icon: Icons.add_rounded,
            label: 'Create new Label',
            onTap: () => _showCreateLabelDialog(),
          ),

          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _themeService.isDarkMode,
            onChanged: (value) => _themeService.toggleTheme(),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.info_outline,
            label: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
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
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Version: 1.0.0+1',
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

  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red[400]),
            const SizedBox(width: 10),
            const Text('Support Us'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you love using Advanced Notepad, consider supporting our development journey!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mail_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payment ID: sourav@upi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Donate Now'),
          ),
        ],
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
      await _firestoreService.addLabel(newLabel);
    }
  }
}


class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
