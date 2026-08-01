import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class CancelBookingScreen extends StatelessWidget {
  const CancelBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/my-bookings');
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
                context.go('/my-bookings');
              }
            },
          ),
          title: const Text('Cancel Booking'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                borderColor: AppColors.error,
                child: const Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 50, color: AppColors.error),
                    SizedBox(height: 12),
                    Text('Are you sure you want to cancel?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Full refund will be credited to your Easy Book Wallet.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMutedDark)),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Confirm Cancellation',
                backgroundColor: AppColors.error,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully.')));
                  context.go('/my-bookings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
