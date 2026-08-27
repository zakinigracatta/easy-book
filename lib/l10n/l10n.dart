import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

AppLocalizations l10nOf(BuildContext context) {
  final localizations = Localizations.of<AppLocalizations>(
    context,
    AppLocalizations,
  );
  if (localizations != null) return localizations;

  // Some widget tests and isolated previews intentionally mount a screen
  // without the app delegate. Resolve the active Flutter locale directly so
  // the fallback still respects ar/en/ru instead of silently forcing English.
  return lookupAppLocalizations(Localizations.localeOf(context));
}
