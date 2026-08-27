import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/l10n.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {
        'name': 'Ahmed Mohamed',
        'role': l10nOf(context).customer,
        'status': l10nOf(context).active
      },
      {
        'name': 'Executive Barber Lounge',
        'role': l10nOf(context).businessPartner,
        'status': l10nOf(context).verified
      },
      {
        'name': 'Sarah Jenkins',
        'role': l10nOf(context).customer,
        'status': l10nOf(context).active
      },
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/admin-dashboard');
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
                context.go('/admin-dashboard');
              }
            },
          ),
          title: Text(l10nOf(context).usersAccountsManagement),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(u['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(u['role']!),
                  trailing: Text(u['status']!,
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
