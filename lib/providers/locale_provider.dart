import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_storage_service.dart';

abstract interface class LocaleStorage {
  String? readLanguageCode();

  Future<bool> writeLanguageCode(String languageCode);
}

class HiveLocaleStorage implements LocaleStorage {
  const HiveLocaleStorage();

  @override
  String? readLanguageCode() => LocalStorageService.getLanguageCode();

  @override
  Future<bool> writeLanguageCode(String languageCode) =>
      LocalStorageService.saveLanguageCode(languageCode);
}

class LocaleController extends StateNotifier<Locale> {
  LocaleController({
    LocaleStorage storage = const HiveLocaleStorage(),
    Locale? initialLocale,
  })  : _storage = storage,
        super(
          _resolveInitialLocale(storage, initialLocale),
        );

  static const supportedLanguageCodes = <String>{'en', 'ar', 'ru'};

  final LocaleStorage _storage;

  static Locale _resolveInitialLocale(
    LocaleStorage storage,
    Locale? initialLocale,
  ) {
    final storedCode = storage.readLanguageCode();
    if (storedCode != null && supportedLanguageCodes.contains(storedCode)) {
      return Locale(storedCode);
    }
    if (initialLocale != null &&
        supportedLanguageCodes.contains(initialLocale.languageCode)) {
      return Locale(initialLocale.languageCode);
    }
    return const Locale('en');
  }

  Future<bool> setLocale(Locale locale) => setLanguageCode(locale.languageCode);

  Future<bool> setLanguageCode(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode)) return false;

    final saved = await _storage.writeLanguageCode(languageCode);
    if (!saved) return false;

    state = Locale(languageCode);
    return true;
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);
