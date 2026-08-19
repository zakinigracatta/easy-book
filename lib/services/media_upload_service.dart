import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MediaUploadService {
  MediaUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  static const int maxImageBytes = 5 * 1024 * 1024;

  final FirebaseStorage _storage;
  final ImagePicker _picker;
  final Uuid _uuid = const Uuid();

  Future<String?> pickAndUploadImage({
    required String storageFolder,
    ImageSource source = ImageSource.gallery,
    void Function(double progress)? onProgress,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2200,
      maxHeight: 2200,
      requestFullMetadata: false,
    );
    if (file == null) return null;

    return uploadXFile(
      file,
      storageFolder: storageFolder,
      onProgress: onProgress,
    );
  }

  Future<List<String>> pickAndUploadMultipleImages({
    required String storageFolder,
    int maxCount = 8,
    void Function(int current, int total, double fileProgress)? onProgress,
  }) async {
    final files = await _picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 2200,
      maxHeight: 2200,
      requestFullMetadata: false,
    );
    if (files.isEmpty) return const [];

    final selected = files.take(maxCount).toList();
    final urls = <String>[];

    for (var i = 0; i < selected.length; i++) {
      final url = await uploadXFile(
        selected[i],
        storageFolder: storageFolder,
        onProgress: (progress) => onProgress?.call(
          i + 1,
          selected.length,
          progress,
        ),
      );
      urls.add(url);
    }

    return urls;
  }

  Future<String> uploadXFile(
    XFile file, {
    required String storageFolder,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('The selected image is empty.');
    }
    if (bytes.length > maxImageBytes) {
      throw StateError('Image must be smaller than 5 MB after compression.');
    }

    final cleanFolder = storageFolder
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .join('/');
    if (cleanFolder.isEmpty) {
      throw ArgumentError.value(storageFolder, 'storageFolder');
    }

    final extension = _safeExtension(file.name);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.$extension';
    final ref = _storage.ref().child('$cleanFolder/$fileName');

    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: _contentType(extension)),
    );

    final subscription = task.snapshotEvents.listen((snapshot) {
      final total = snapshot.totalBytes;
      if (total <= 0) return;
      onProgress?.call(snapshot.bytesTransferred / total);
    });

    try {
      await task;
      return await ref.getDownloadURL();
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> deleteByUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      // Deleting an already-missing object should not block profile updates.
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _safeExtension(String name) {
    final dot = name.lastIndexOf('.');
    final raw = dot >= 0 ? name.substring(dot + 1).toLowerCase() : 'jpg';
    switch (raw) {
      case 'jpeg':
      case 'jpg':
      case 'png':
      case 'webp':
      case 'gif':
        return raw;
      default:
        return 'jpg';
    }
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
