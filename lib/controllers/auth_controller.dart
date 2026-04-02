import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'note_controller.dart';
import '../services/profile_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);

  User? get user => _user.value;
  bool get isLoggedIn => _user.value != null;
  String? get userId => _user.value?.uid;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.userStream);
    
    // Listen to user changes to trigger sync
    ever(_user, (user) {
      if (user != null) {
        // Sync profile data from Google/Firebase
        _syncProfileData(user);
        
        if (Get.isRegistered<NoteController>()) {
          Get.find<NoteController>().fetchNotes();
        }
      }
    });
  }

  Future<void> _syncProfileData(User user) async {
    final profileService = ProfileService();
    
    // 1. Sync name if local name is default
    final localName = await profileService.getUserName();
    if (localName == 'Advanced User' && user.displayName != null) {
      await profileService.setUserName(user.displayName!);
    }
    
    // 2. Sync photoURL if local is empty
    final localPhoto = await profileService.getProfilePhoto();
    if (localPhoto == null && user.photoURL != null) {
      await profileService.setProfilePhoto(user.photoURL!, isCloud: true);
    }
    
    // 3. Sync email
    if (user.email != null) {
      await profileService.setUserEmail(user.email!);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'Could not sign in with Google: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/home'); // Redirect to home or login after logout
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Could not sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
