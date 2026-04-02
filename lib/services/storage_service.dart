import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfilePhoto(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('users/${user.uid}/profile_photo.jpg');
      
      // Upload with metadata
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<void> deleteProfilePhoto() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final ref = _storage.ref().child('users/${user.uid}/profile_photo.jpg');
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting profile photo: $e');
    }
  }
}
