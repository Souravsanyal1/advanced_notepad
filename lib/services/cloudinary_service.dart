import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dfa8k8rn7', // Cloud Name
    'ml_default', // Using a default preset, user might need to ensure this is active in Cloudinary dashboard
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'notes_images',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
