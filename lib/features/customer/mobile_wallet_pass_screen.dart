import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class MobileWalletPassScreen extends StatelessWidget {
  const MobileWalletPassScreen({super.key});

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
          title: const Text('Digital Wallet Pass'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const GlassCard(
                backgroundColor: AppColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('EASY BOOK PASS',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Icon(Icons.wallet_rounded, color: AppColors.accent),
                      ],
                    ),
                    SizedBox(height: 20),
                    GradientText('Executive Barber Lounge',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Appointment: Tomorrow, 2:30 PM',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 20),
                    Center(
                      child:
                          Icon(Icons.qr_code, size: 100, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_to_home_screen_rounded),
                label: const Text('Add to Apple Wallet / Google Pay'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
