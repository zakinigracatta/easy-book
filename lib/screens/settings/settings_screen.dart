import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('App Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Appearance Header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'APPEARANCE & THEME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: mutedTextColor,
                ),
              ),
            ),

            // Quick Dark Mode Switch
            GlassCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : themeMode == ThemeMode.light
                          ? Icons.light_mode_rounded
                          : Icons.brightness_auto_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Dark Theme Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? 'Dark mode active'
                      : themeMode == ThemeMode.light
                          ? 'Light mode active'
                          : 'System mode active',
                  style: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
                value: themeMode == ThemeMode.dark,
                onChanged: (bool enabled) {
                  ref.read(themeModeProvider.notifier).state =
                      enabled ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Theme Mode Options (Light, Dark, System)
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Preference',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _themeOptionTile(
                        context: context,
                        ref: ref,
                        mode: ThemeMode.light,
                        label: 'Light',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: themeMode == ThemeMode.light,
                      ),
                      const SizedBox(width: 8),
                      _themeOptionTile(
                        context: context,
                        ref: ref,
                        mode: ThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.nightlight_round,
                        isSelected: themeMode == ThemeMode.dark,
                      ),
                      const SizedBox(width: 8),
                      _themeOptionTile(
                        context: context,
                        ref: ref,
                        mode: ThemeMode.system,
                        label: 'System',
                        icon: Icons.hdr_auto_rounded,
                        isSelected: themeMode == ThemeMode.system,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Preferences & Help
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'PREFERENCES & HELP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: mutedTextColor,
                ),
              ),
            ),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.notifications_rounded,
                    color: AppColors.accent),
                title: Text('Push Notifications',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryTextColor)),
                subtitle: Text('Appointment reminders and status updates',
                    style: TextStyle(color: mutedTextColor, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.help_outline_rounded,
                    color: AppColors.info),
                title: Text('Help & Support',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryTextColor)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/help'),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: AppColors.gold),
                title: Text('About Easy Book',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryTextColor)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/about'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOptionTile({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = AppColors.primary.withValues(alpha: 0.15);
    final inactiveBg = isDark ? AppColors.glassBgDark : AppColors.glassBgLight;
    const activeBorder = AppColors.primary;
    final inactiveBorder =
        isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeModeProvider.notifier).state = mode;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeBorder : inactiveBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
