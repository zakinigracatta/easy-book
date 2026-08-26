import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

const _themeModeKey = 'theme_mode';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(_readInitialThemeMode());

  static ThemeMode _readInitialThemeMode() {
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) {
        return ThemeMode.dark;
      }
      final value = Hive.box(AppConstants.hiveSettingsBox).get(_themeModeKey);
      if (value == 'light') return ThemeMode.light;
      if (value == 'system') return ThemeMode.system;
      if (value == 'dark') return ThemeMode.dark;
    } catch (_) {
      // Preserve the existing dark appearance if local settings are unavailable.
    }
    return ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return;
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await Hive.box(AppConstants.hiveSettingsBox).put(_themeModeKey, value);
    } catch (_) {
      // The current session still switches theme if persistence is unavailable.
    }
  }

  Future<void> setDarkMode(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);
