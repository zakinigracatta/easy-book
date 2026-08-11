import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                const Text('Toggle between Light and Dark modern luxury theme'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state =
                  val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Push Notifications',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Receive appointment updates & offers'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
