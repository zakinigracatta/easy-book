import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'Apple Pay';

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
          title: const Text('الخطوة 5: إتمام الحجز والدفع'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _methodTile('Apple Pay', Icons.apple),
              const SizedBox(height: 12),
              _methodTile('بطاقة ائتمان / خصم', Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _methodTile('محفظة Easy Book (\$120.00)',
                  Icons.account_balance_wallet_rounded),
              const Spacer(),
              CustomButton(
                text: 'ادفع \$65.00 الآن',
                onPressed: () => context.push('/booking-success'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodTile(String title, IconData icon) {
    final isSel = _paymentMethod == title;
    return GlassCard(
      onTap: () => setState(() => _paymentMethod = title),
      borderColor: isSel ? AppColors.primary : null,
      child: ListTile(
        leading: Icon(icon, color: isSel ? AppColors.primary : null),
        title: Text(title,
            style: TextStyle(
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
        trailing: isSel
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
      ),
    );
  }
}
