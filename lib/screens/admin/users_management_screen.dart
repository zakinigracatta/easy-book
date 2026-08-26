import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/glass_card.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': 'Ahmed Mohamed', 'role': 'Customer', 'status': 'Active'},
      {'name': 'Executive Barber Lounge', 'role': 'Business Partner', 'status': 'Verified'},
      {'name': 'Sarah Jenkins', 'role': 'Customer', 'status': 'Active'},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/admin-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/admin-dashboard'),
          ),
          title: Text(context.tr('Users & Accounts Management')),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(context.tr(user['role']!)),
                  trailing: Text(
                    context.tr(user['status']!),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
