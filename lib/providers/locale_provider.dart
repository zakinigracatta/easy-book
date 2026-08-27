import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

const _languageKey = 'language_code';
const _supportedLanguageCodes = <String>{'en', 'ar', 'ru'};

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(_readInitialLocale());

  static Locale? _readInitialLocale() {
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return null;
      final code = Hive.box(AppConstants.hiveSettingsBox).get(_languageKey);
      if (code is String && _supportedLanguageCodes.contains(code)) {
        return Locale(code);
      }
    } catch (_) {
      // Fall back to the device locale if local settings are unavailable.
    }
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null &&
        !_supportedLanguageCodes.contains(locale.languageCode)) {
      return;
    }

    state = locale;

    try {
      if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return;
      final box = Hive.box(AppConstants.hiveSettingsBox);
      if (locale == null) {
        await box.delete(_languageKey);
      } else {
        await box.put(_languageKey, locale.languageCode);
      }
    } catch (_) {
      // The in-memory language still changes even if persistence fails.
    }
  }
}

/// Null follows the device locale. A concrete locale is an explicit in-app
/// language choice that is persisted across app restarts when Hive is ready.
final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(),
);
