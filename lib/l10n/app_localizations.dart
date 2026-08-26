import 'package:flutter/material.dart';

import 'russian_secondary_translations.dart';
import 'russian_translations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('ru'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Localizations.localeOf(context));
  }

  String tr(
    String source, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {
    final languageCode = locale.languageCode.toLowerCase();
    var value = source;
    if (languageCode == 'ru') {
      value = russianSecondaryTranslations[source] ??
          russianTranslations[source] ??
          source;
    }

    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationContext on BuildContext {
  String tr(
    String source, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {
    return AppLocalizations.of(this).tr(source, params: params);
  }
}
