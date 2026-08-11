import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';

/// PaymentScreen (UI Prototype / Future Payment Phase)
/// Disconnected from Phase 2 booking transaction. Real booking creation occurs
/// on BookingConfirmationScreen.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _paymentMethod = 'Apple Pay';

  void _handlePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Payment integration will be enabled in Phase 3.')),
    );
    context.go('/my-bookings');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final priceStr = draft.servicePrice != null
        ? '\$${draft.servicePrice!.toStringAsFixed(2)}'
        : '\$0.00';

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
          title: const Text('Checkout & Payment (Future Phase)'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _methodTile('Apple Pay', Icons.apple),
              const SizedBox(height: 12),
              _methodTile('Credit / Debit Card', Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _methodTile('Easy Book Wallet (\$120.00)',
                  Icons.account_balance_wallet_rounded),
              const Spacer(),
              CustomButton(
                text: 'Pay $priceStr Now',
                onPressed: _handlePayment,
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
