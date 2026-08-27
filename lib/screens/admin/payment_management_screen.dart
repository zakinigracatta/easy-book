import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

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
          title: Text(l10nOf(context).payoutQueuesCommissions),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: ListTile(
                title: const Text('Executive Barber Lounge'),
                subtitle: Text(l10nOf(context).pendingPayout('\$3,450.00')),
                trailing: Text(l10nOf(context).approve,
                    style: const TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
