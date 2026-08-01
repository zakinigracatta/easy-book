import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
          title: const Text('Easy Loyalty Rewards'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Column(
                  children: [
                    const Icon(Icons.stars_rounded, size: 48, color: AppColors.accent),
                    const SizedBox(height: 12),
                    const GradientText(
                      '1,450 Points',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text('VIP Gold Tier Member', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.72,
                      backgroundColor: Colors.white24,
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    const Text('550 pts until Platinum Tier', style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Redeemable Rewards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              _rewardTile(context, 'Free Hot Towel Treatment', '300 pts', Icons.dry_cleaning_rounded),
              _rewardTile(context, '\$15 Off Any Hair Salon Booking', '500 pts', Icons.content_cut_rounded),
              _rewardTile(context, 'Full Body Spa Voucher (30 min)', '1,000 pts', Icons.spa_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardTile(BuildContext context, String title, String points, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(points, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: const Text('Redeem', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
