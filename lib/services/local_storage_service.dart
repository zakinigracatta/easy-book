import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class LocalStorageService {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveFavoritesBox);
    await Hive.openBox(AppConstants.hiveSettingsBox);
  }

  static bool _isOpen(String boxName) => Hive.isBoxOpen(boxName);

  static Future<void> saveUserToken(String token) async {
    if (!_isOpen(AppConstants.hiveUserBox)) return;
    try {
      await Hive.box(AppConstants.hiveUserBox).put('token', token);
    } catch (_) {
      // Authentication is owned by Firebase; local token persistence is optional.
    }
  }

  static String? getUserToken() {
    if (!_isOpen(AppConstants.hiveUserBox)) return null;
    try {
      return Hive.box(AppConstants.hiveUserBox).get('token') as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveFavorite(String businessId) async {
    if (!_isOpen(AppConstants.hiveFavoritesBox)) return;
    try {
      final box = Hive.box(AppConstants.hiveFavoritesBox);
      final stored = box.get('ids', defaultValue: <dynamic>[]);
      final favs = stored is List
          ? List<dynamic>.from(stored)
          : <dynamic>[];
      if (!favs.contains(businessId)) {
        favs.add(businessId);
        await box.put('ids', favs);
      }
    } catch (_) {
      // Firestore-backed favorites remain authoritative in the current app.
    }
  }

  static List<String> getFavorites() {
    if (!_isOpen(AppConstants.hiveFavoritesBox)) return const <String>[];
    try {
      final stored = Hive.box(AppConstants.hiveFavoritesBox)
          .get('ids', defaultValue: <dynamic>[]);
      if (stored is! List) return const <String>[];
      return stored.whereType<String>().toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }
}
