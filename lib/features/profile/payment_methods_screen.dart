import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
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
                context.go('/profile');
              }
            },
          ),
          title: const Text('طرق الدفع'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const GlassCard(
                backgroundColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('فيزا بلاتينية',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Icon(Icons.credit_card_rounded, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text('•••• •••• •••• 4242',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SARAH JENKINS',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('08/28',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const GlassCard(
                child: ListTile(
                  leading: Icon(Icons.apple, size: 30),
                  title: Text('Apple Pay',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('متصل'),
                  trailing: Icon(Icons.check_circle_rounded,
                      color: AppColors.success),
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.accent),
                  title: const Text('محفظة إيزي بوك',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('الرصيد: \$240.00'),
                  trailing: ElevatedButton(
                    onPressed: () => context.push('/wallet'),
                    child: const Text('شحن الرصيد'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
