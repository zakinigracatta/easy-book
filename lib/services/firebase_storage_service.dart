import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../core/domain_exceptions.dart';

enum ImageTargetType {
  logo,
  cover,
  gallery,
  service,
  employee,
  userProfile,
}

class FirebaseStorageService {
  final FirebaseStorage _storage;

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  FirebaseStorageService([FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads an image file to real Firebase Storage destination path and returns the Storage download URL.
  Future<String> uploadImage({
    required String businessId,
    required ImageTargetType targetType,
    required String filePathOrUrl,
    String? targetId,
  }) async {
    // If it is already a network URL, return it directly
    if (filePathOrUrl.startsWith('http://') ||
        filePathOrUrl.startsWith('https://')) {
      return filePathOrUrl;
    }

    final file = File(filePathOrUrl);
    if (!await file.exists()) {
      throw DomainException('Selected image file does not exist locally.');
    }

    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      throw DomainException('Image file size exceeds maximum 5MB limit.');
    }

    final ext = filePathOrUrl.split('.').last.toLowerCase();
    final allowedExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    if (!allowedExts.contains(ext)) {
      throw DomainException(
          'Unsupported image format. Allowed formats: JPG, PNG, WEBP.');
    }

    final uniqueId = const Uuid().v4();
    final fileName = '$uniqueId.$ext';
    final path = _resolveStoragePath(
      businessId: businessId,
      targetType: targetType,
      targetId: targetId ?? uniqueId,
      fileName: fileName,
    );

    debugPrint('UPLOADING_IMAGE_TO_STORAGE: $path (size: ${fileSize}B)');

    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: 'image/$ext',
        customMetadata: {
          'businessId': businessId,
          'targetType': targetType.name,
        },
      );

      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('UPLOAD_SUCCESSFUL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('FIREBASE_STORAGE_ERROR: ${e.code} - ${e.message}');
      throw DomainException('Failed to upload image: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('STORAGE_UPLOAD_ERROR: $e');
      throw DomainException(
          'An unexpected error occurred during image upload.');
    }
  }

  String _resolveStoragePath({
    required String businessId,
    required ImageTargetType targetType,
    required String targetId,
    required String fileName,
  }) {
    switch (targetType) {
      case ImageTargetType.logo:
        return 'businesses/$businessId/profile/logo/$fileName';
      case ImageTargetType.cover:
        return 'businesses/$businessId/profile/cover/$fileName';
      case ImageTargetType.gallery:
        return 'businesses/$businessId/gallery/$targetId/$fileName';
      case ImageTargetType.service:
        return 'businesses/$businessId/services/$targetId/$fileName';
      case ImageTargetType.employee:
        return 'businesses/$businessId/employees/$targetId/$fileName';
      case ImageTargetType.userProfile:
        return 'users/$targetId/profile/$fileName';
    }
  }
}
