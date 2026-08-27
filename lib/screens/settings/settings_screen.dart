import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final effectiveLanguage = selectedLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('App Settings')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(context.tr('Language')),
                subtitle: Text(_languageName(context, effectiveLanguage)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    _showLanguagePicker(context, ref, effectiveLanguage),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.notifications_rounded),
                title: Text(context.tr('Push Notifications')),
                trailing: const Switch(value: true, onChanged: null),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                leading: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                title: Text(context.tr('Dark Theme Mode')),
                subtitle: Text(
                  context.tr(
                    isDarkMode ? 'Dark mode is on' : 'Light mode is on',
                  ),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (enabled) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setDarkMode(enabled);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(BuildContext context, String code) {
    return switch (code) {
      'ru' => context.tr('Russian'),
      'ar' => context.tr('Arabic'),
      _ => context.tr('English'),
    };
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('EN'),
              title: Text(sheetContext.tr('English')),
              trailing:
                  currentCode == 'en' ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(sheetContext, 'en'),
            ),
            ListTile(
              leading: const Text('AR'),
              title: Text(sheetContext.tr('Arabic')),
              trailing:
                  currentCode == 'ar' ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(sheetContext, 'ar'),
            ),
            ListTile(
              leading: const Text('RU'),
              title: Text(sheetContext.tr('Russian')),
              trailing:
                  currentCode == 'ru' ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(sheetContext, 'ru'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (code == null) return;
    await ref.read(localeProvider.notifier).setLocale(Locale(code));
  }
}
