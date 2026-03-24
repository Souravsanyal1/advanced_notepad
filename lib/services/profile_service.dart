import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _profilePhotoKey = 'profile_photo_url';
  static const String _userNameKey = 'user_name';

  Future<String?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePhotoKey);
  }

  Future<void> setProfilePhoto(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePhotoKey, url);
    notifyListeners();
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Advanced User';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    notifyListeners();
  }
}
