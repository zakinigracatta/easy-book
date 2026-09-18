import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_localization.dart';
import '../../widgets/glass_card.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/admin/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/admin/dashboard'),
          ),
          title: Text(adminText(context, 'Payments', 'المدفوعات')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 54),
                    const SizedBox(height: 14),
                    Text(
                      adminText(
                        context,
                        'Payments backend is not configured yet.',
                        'نظام المدفوعات الخلفي غير مفعّل بعد.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminText(
                        context,
                        'No payout or commission values are shown until a trusted payment data source is connected.',
                        'لن يتم عرض مبالغ التحويلات أو العمولات حتى يتم ربط مصدر موثوق لبيانات المدفوعات.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
