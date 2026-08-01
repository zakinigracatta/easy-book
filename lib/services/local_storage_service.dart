import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveFavoritesBox);
    await Hive.openBox(AppConstants.hiveSettingsBox);
  }

  static Future<void> saveUserToken(String token) async {
    final box = Hive.box(AppConstants.hiveUserBox);
    await box.put('token', token);
  }

  static String? getUserToken() {
    final box = Hive.box(AppConstants.hiveUserBox);
    return box.get('token') as String?;
  }

  static Future<void> saveFavorite(String businessId) async {
    final box = Hive.box(AppConstants.hiveFavoritesBox);
    final List<dynamic> favs = box.get('ids', defaultValue: <dynamic>[]) as List<dynamic>;
    if (!favs.contains(businessId)) {
      favs.add(businessId);
      await box.put('ids', favs);
    }
  }

  static List<String> getFavorites() {
    final box = Hive.box(AppConstants.hiveFavoritesBox);
    final List<dynamic> favs = box.get('ids', defaultValue: <dynamic>[]) as List<dynamic>;
    return favs.cast<String>();
  }
}
