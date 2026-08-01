import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class GoogleAuthScreen extends StatelessWidget {
  const GoogleAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Authentication'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.g_mobiledata_rounded, size: 50, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const GradientText(
                  'Single Sign-On',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Authenticating via Google Cloud Identity Services...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMutedDark, fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Simulate Successful Auth'),
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
