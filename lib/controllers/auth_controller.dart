import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'note_controller.dart';

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
        // Trigger generic sync in NoteController when user logs in
        if (Get.isRegistered<NoteController>()) {
          Get.find<NoteController>().fetchNotes();
        }
      }
    });
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
