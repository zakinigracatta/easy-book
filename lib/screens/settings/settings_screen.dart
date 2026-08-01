import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          children: const [
            GlassCard(
              child: ListTile(
                leading: Icon(Icons.notifications_rounded),
                title: Text('Push Notifications'),
                trailing: Switch(value: true, onChanged: null),
              ),
            ),
            SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                leading: Icon(Icons.dark_mode_rounded),
                title: Text('Dark Theme Mode'),
                trailing: Switch(value: true, onChanged: null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
