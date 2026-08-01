import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          title: const Text('Users & Accounts Management'),
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
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(u['role']!),
                  trailing: Text(u['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
