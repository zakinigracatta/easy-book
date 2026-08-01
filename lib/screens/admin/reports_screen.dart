import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: const Text('System Audit Reports'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            GlassCard(
              child: ListTile(
                title: Text('Security & Database Audit Log'),
                subtitle: Text('System operating normally. 0 breaches.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
