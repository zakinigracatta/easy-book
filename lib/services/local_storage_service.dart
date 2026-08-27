import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  static const languageCodeKey = 'language_code';
  static const _legacyLocaleKey = 'locale';
  static const supportedLanguageCodes = <String>{'en', 'ar', 'ru'};

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveFavoritesBox);
    final settingsBox = await Hive.openBox(AppConstants.hiveSettingsBox);
    await _migrateLanguageCode(settingsBox);
  }

  static Future<void> _migrateLanguageCode(Box<dynamic> box) async {
    if (!box.containsKey(languageCodeKey)) {
      final legacyCode = box.get(_legacyLocaleKey);
      if (legacyCode is String && supportedLanguageCodes.contains(legacyCode)) {
        await box.put(languageCodeKey, legacyCode);
      }
    }
    if (box.containsKey(_legacyLocaleKey)) {
      await box.delete(_legacyLocaleKey);
    }
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
    final List<dynamic> favs =
        box.get('ids', defaultValue: <dynamic>[]) as List<dynamic>;
    if (!favs.contains(businessId)) {
      favs.add(businessId);
      await box.put('ids', favs);
    }
  }

  static List<String> getFavorites() {
    final box = Hive.box(AppConstants.hiveFavoritesBox);
    final List<dynamic> favs =
        box.get('ids', defaultValue: <dynamic>[]) as List<dynamic>;
    return favs.cast<String>();
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return;
    final box = Hive.box(AppConstants.hiveSettingsBox);
    await box.put('theme_mode', mode.name);
  }

  static ThemeMode getThemeMode() {
    if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) {
      return ThemeMode.light;
    }
    final box = Hive.box(AppConstants.hiveSettingsBox);
    final modeStr = box.get('theme_mode', defaultValue: 'light') as String;
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static Future<bool> saveLanguageCode(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode) ||
        !Hive.isBoxOpen(AppConstants.hiveSettingsBox)) {
      return false;
    }
    final box = Hive.box(AppConstants.hiveSettingsBox);
    await box.put(languageCodeKey, languageCode);
    return true;
  }

  static Future<bool> saveLocale(Locale locale) =>
      saveLanguageCode(locale.languageCode);

  static String? getLanguageCode() {
    if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) {
      return null;
    }
    final box = Hive.box(AppConstants.hiveSettingsBox);
    final languageCode = box.get(languageCodeKey);
    return languageCode is String &&
            supportedLanguageCodes.contains(languageCode)
        ? languageCode
        : null;
  }

  static Locale getLocale() => Locale(getLanguageCode() ?? 'en');
}
