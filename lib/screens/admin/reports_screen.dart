import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/l10n.dart';

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
          title: Text(l10nOf(context).systemAuditReports),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: ListTile(
                title: Text(l10nOf(context).securityDatabaseAuditLog),
                subtitle: Text(l10nOf(context).systemOperatingNormally),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
