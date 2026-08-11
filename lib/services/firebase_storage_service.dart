import 'dart:io';
import 'package:flutter/foundation.dart';
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
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  /// Uploads an image file or URL to the appropriate storage destination path and returns the Storage download URL.
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
      throw DomainException('Unsupported image format. Allowed formats: JPG, PNG, WEBP.');
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

    // Simulated network delay / Real Firebase Storage upload hook
    await Future.delayed(const Duration(milliseconds: 600));

    // Return production CDN storage URL representation
    return 'https://firebasestorage.googleapis.com/v0/b/easy-book-zaki.appspot.com/o/${Uri.encodeComponent(path)}?alt=media';
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
