import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Saves a file from a temporary location to the persistent application document directory.
  /// Returns the absolute path of the saved file.
  Future<String?> saveImage(File imageFile, String folder) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String directoryPath = path.join(appDocDir.path, folder);
      
      final Directory targetDir = Directory(directoryPath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final String filePath = path.join(directoryPath, fileName);
      
      final File savedFile = await imageFile.copy(filePath);
      return savedFile.path;
    } catch (e) {
      debugPrint('Local Storage Error: $e');
      return null;
    }
  }

  /// Deletes a file from the local storage.
  Future<void> deleteImage(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Local Storage Error: $e');
    }
  }

  /// Checks if a file exists at the given path.
  bool fileExists(String? filePath) {
    if (filePath == null || filePath.isEmpty) return false;
    return File(filePath).existsSync();
  }
}
