import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class PaymentManagementScreen extends StatelessWidget {
  PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/admin-dashboard'),
          ),
          title: Text(context.tr('Payout Queues & Commissions')),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            GlassCard(
              child: ListTile(
                title: Text(context.tr('Executive Barber Lounge')),
                subtitle: Text(context.tr('Pending Payout: {amount}', params: {'amount': '\$3,450.00'})),
                trailing: Text(
                  context.tr('Approve'),
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
