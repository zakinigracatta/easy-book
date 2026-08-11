import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../core/constants/app_colors.dart';

class AdminPayoutsScreen extends StatelessWidget {
  const AdminPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Payout Approval Queue')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: ListTile(
              title: const Text('Executive Barber Lounge',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Requested: \$2,450.00 • Stripe Connect'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                child: const Text('Approve Payout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
