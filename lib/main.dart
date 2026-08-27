import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'providers/locale_provider.dart';
import 'routes/app_router.dart';
import 'services/local_storage_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class EasyBookScrollBehavior extends MaterialScrollBehavior {
  const EasyBookScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalStorageService.initHive();
  final initialLocale = LocalStorageService.getLocale();

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(
          (ref) => LocaleController(initialLocale: initialLocale),
        ),
      ],
      child: const EasyBookApp(),
    ),
  );
}

class EasyBookApp extends ConsumerWidget {
  const EasyBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      LocalStorageService.saveThemeMode(next);
    });
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scrollBehavior: const EasyBookScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
