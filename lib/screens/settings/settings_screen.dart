import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isLight = themeMode == ThemeMode.light;

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
          title: const Text('إعدادات التطبيق'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const GlassCard(
              child: ListTile(
                leading: Icon(Icons.notifications_rounded),
                title: Text('الإشعارات الفورية'),
                trailing: Switch(value: true, onChanged: null),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                title: const Text('الوضع الفاتح'),
                subtitle: Text(
                  isLight ? 'المظهر الفاتح مفعّل' : 'تفعيل المظهر الفاتح',
                ),
                value: isLight,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
