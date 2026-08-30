import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';

class PartnerVerificationCenterScreen extends StatelessWidget {
  const PartnerVerificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Verification Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Velvet Glow Beauty & Spa',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                const Text('Tax ID: TX-99201482 • Trade License Submitted',
                    style: TextStyle(color: AppColors.textMutedDark)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {}, child: const Text('رفض'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Verify Partner'))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
