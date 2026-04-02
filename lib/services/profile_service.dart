import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _profilePhotoKey = 'profile_photo_url';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<String?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePhotoKey);
  }

  Future<void> setProfilePhoto(String url, {bool isCloud = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePhotoKey, url);
    
    // If it's a local file and user is logged in, upload it to cloud
    final user = _auth.currentUser;
    if (user != null && !isCloud) {
       // Note: url might be a local file path
       // This will be handled in AppDrawer where we pick the file
    } else if (user != null && isCloud) {
       // Update Firestore if it's already a cloud URL
       await _firestore.collection('users').doc(user.uid).set({
         'photoURL': url,
         'updatedAt': FieldValue.serverTimestamp(),
       }, SetOptions(merge: true));
    }
    
    notifyListeners();
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Advanced User';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    
    notifyListeners();
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? 'premium@advanced.com';
  }

  Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    notifyListeners();
  }
}
