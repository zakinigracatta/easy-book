import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_button.dart';
import '../../core/constants/app_colors.dart';

class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

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
          title: const Text('Digital Gift Cards'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                backgroundColor: AppColors.accent.withOpacity(0.15),
                child: const Column(
                  children: [
                    Icon(Icons.card_giftcard_rounded,
                        size: 50, color: AppColors.accent),
                    SizedBox(height: 12),
                    GradientText('Gift an Experience',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                        'Send instant digital spa & grooming vouchers to loved ones.',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['\$25', '\$50', '\$100', '\$200']
                    .map((amt) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(amt,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Purchase Gift Voucher',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
