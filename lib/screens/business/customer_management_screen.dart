import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = [
      {'name': 'Ahmed Mohamed', 'visits': '12 Visits', 'total': '\$780.00 Spent'},
      {'name': 'Sarah Jenkins', 'visits': '8 Visits', 'total': '\$520.00 Spent'},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
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
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Customer Relationship Database'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final c = clients[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                  title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c['visits']} • ${c['total']}'),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 3),
      ),
    );
  }
}
