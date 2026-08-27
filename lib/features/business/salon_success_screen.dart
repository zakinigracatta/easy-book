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
          padding: EdgeInsets.all(24),
          child: GlassCard(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 80, color: AppColors.success),
                SizedBox(height: 16),
                GradientText('Registration Submitted!',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(
                  'Your business profile is under super admin review. Approval usually takes under 2 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/business-dashboard'),
                  child: Text('Go to Business Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
