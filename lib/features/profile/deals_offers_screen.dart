import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';

class DealsOffersScreen extends StatelessWidget {
  const DealsOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deals = [
      {
        'title': 'Summer Glow Promo',
        'discount': '30% OFF',
        'code': 'SUMMER30',
        'desc': 'Valid on all skincare & facial packages.'
      },
      {
        'title': 'First Booking Special',
        'discount': '20% OFF',
        'code': 'WELCOME20',
        'desc': 'For new customer appointments.'
      },
    ];

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
          title: const Text('Exclusive Deals & Offers'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final d = deals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d['title']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(d['discount']!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(d['desc']!,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textMutedDark)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CODE: ${d['code']!}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2)),
                        TextButton(
                            onPressed: () {}, child: const Text('Copy Promo')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
