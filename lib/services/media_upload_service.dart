import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MediaUploadService {
  MediaUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage,
        _picker = picker ?? ImagePicker();

  static const int maxImageBytes = 5 * 1024 * 1024;

  FirebaseStorage? _storage;
  final ImagePicker _picker;
  final Uuid _uuid = const Uuid();

  // Resolve Firebase Storage only when an upload/delete is actually requested.
  // This keeps screens constructible in tests and in read-only flows even when
  // a Storage bucket is unavailable or intentionally not configured.
  FirebaseStorage get _resolvedStorage =>
      _storage ??= FirebaseStorage.instance;

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
    if (maxCount <= 0) return const [];

    final files = await _picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 2200,
      maxHeight: 2200,
      limit: maxCount,
      requestFullMetadata: false,
    );
    if (files.isEmpty) return const [];

    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final url = await uploadXFile(
        files[i],
        storageFolder: storageFolder,
        onProgress: (progress) => onProgress?.call(
          i + 1,
          files.length,
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
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.$extension';
    final ref = _resolvedStorage.ref().child('$cleanFolder/$fileName');

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
    final value = url?.trim() ?? '';
    if (value.isEmpty || !_isFirebaseStorageUrl(value)) return;

    try {
      await _resolvedStorage.refFromURL(value).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  bool _isFirebaseStorageUrl(String value) {
    if (value.startsWith('gs://')) return true;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.host == 'firebasestorage.googleapis.com' ||
        uri.host == 'storage.googleapis.com';
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
