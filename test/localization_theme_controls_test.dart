import 'package:easy_book/l10n/app_localizations.dart';
import 'package:easy_book/providers/locale_provider.dart';
import 'package:easy_book/providers/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic localization resolves core settings strings', () {
    const l10n = AppLocalizations(Locale('ar'));

    expect(l10n.tr('Language'), 'اللغة');
    expect(l10n.tr('Arabic'), 'العربية');
    expect(l10n.tr('Dark Theme Mode'), 'الوضع الداكن');
    expect(l10n.tr('Light mode is on'), 'الوضع الفاتح مفعّل');
  });

  test('Russian localization resolves core settings strings', () {
    const l10n = AppLocalizations(Locale('ru'));

    expect(l10n.tr('Language'), 'Язык');
    expect(l10n.tr('Russian'), 'Русский');
    expect(l10n.tr('Dark Theme Mode'), 'Тёмная тема');
    expect(l10n.tr('Light mode is on'), 'Светлая тема включена');
  });

  test('locale controller changes language even without an open Hive box', () async {
    final controller = LocaleController();

    await controller.setLocale(const Locale('ru'));
    expect(controller.state, const Locale('ru'));

    await controller.setLocale(const Locale('ar'));
    expect(controller.state, const Locale('ar'));
  });

  test('theme controller can switch between dark and light', () async {
    final controller = ThemeModeController();

    await controller.setDarkMode(false);
    expect(controller.state, ThemeMode.light);

    await controller.setDarkMode(true);
    expect(controller.state, ThemeMode.dark);
  });
}
