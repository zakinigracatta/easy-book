import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

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
      SnackBar(content: Text(context.tr('Payment integration will be enabled in Phase 3.'))),
    );
    context.go('/my-bookings');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final amount = draft.servicePrice ?? 0;
    final priceStr = CurrencyFormatter.format(amount);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Checkout & Payment (Future Phase)')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _methodTile('Apple Pay', Icons.apple),
              const SizedBox(height: 12),
              _methodTile('Credit / Debit Card', Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _methodTile('Easy Book Wallet', Icons.account_balance_wallet_rounded),
              const Spacer(),
              CustomButton(
                text: '${context.tr('Pay')} $priceStr ${context.tr('Now')}',
                onPressed: _handlePayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodTile(String title, IconData icon) {
    final isSelected = _paymentMethod == title;
    return GlassCard(
      onTap: () => setState(() => _paymentMethod = title),
      borderColor: isSelected ? AppColors.primary : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : null),
        title: Text(
          context.tr(title),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
      ),
    );
  }
}
