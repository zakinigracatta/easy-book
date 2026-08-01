import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/welcome');
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
                context.go('/welcome');
              }
            },
          ),
          title: const Text('Partner Subscriptions'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const GradientText(
                'Grow Your Salon Business',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Choose the subscription plan that fits your operational scale.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _planCard(context, 'Starter Plan', '\$29/mo', ['Up to 3 Staff Members', 'Basic Booking POS', 'Standard Analytics']),
              const SizedBox(height: 16),
              _planCard(context, 'Pro Business', '\$79/mo', ['Unlimited Staff', 'Full POS & Inventory', 'Automated SMS Marketing', 'Priority Support'], isPopular: true),
              const SizedBox(height: 16),
              _planCard(context, 'Enterprise', '\$199/mo', ['Multi-Branch Support', 'Custom Domain Integration', 'Dedicated Account Manager']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard(BuildContext context, String title, String price, List<String> features, {bool isPopular = false}) {
    return GlassCard(
      borderColor: isPopular ? AppColors.accent : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('MOST POPULAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const Divider(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppColors.accent : AppColors.primary,
                foregroundColor: isPopular ? Colors.black : Colors.white,
              ),
              child: const Text('Subscribe Now'),
            ),
          ),
        ],
      ),
    );
  }
}
