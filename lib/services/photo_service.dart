import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  /// Requests permissions for media access.
  /// Handles different Android versions automatically.
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      // Check Android version
      // For Android 13+ (API 33+), we need READ_MEDIA_IMAGES
      // For older versions, we need READ_EXTERNAL_STORAGE
      final PermissionStatus status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
      
      // Fallback for older Android (some devices might not respond correctly to Permission.photos)
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      return false;
    } else if (Platform.isIOS) {
      final PermissionState state = await PhotoManager.requestPermissionExtend();
      return state.isAuth || state == PermissionState.limited;
    }

    return true;
  }

  /// Returns the first image from the gallery as a File.
  /// This is a basic example of using photo_manager.
  /// For a full gallery UI, you would use PhotoManager.getAssetPathList().
  Future<File?> pickRecentImage() async {
    final bool hasPermission = await requestPermissions();
    if (!hasPermission) return null;

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );

    if (paths.isEmpty) return null;

    final List<AssetEntity> assets = await paths[0].getAssetListRange(start: 0, end: 1);
    if (assets.isEmpty) return null;

    return await assets[0].file;
  }
  
  /// Helper to open app settings if permission is permanently denied.
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
