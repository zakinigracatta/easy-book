import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class SalonSuccessScreen extends StatelessWidget {
  const SalonSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.success),
                const SizedBox(height: 16),
                const GradientText('Registration Submitted!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Your business profile is under super admin review. Approval usually takes under 2 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMutedDark),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/business-dashboard'),
                  child: const Text('Go to Business Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
