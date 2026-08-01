import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';

class SalonSettingsScreen extends StatelessWidget {
  const SalonSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salon Business Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-Approve Appointments'),
                  subtitle: const Text('Instantly confirm client bookings'),
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Allow Cancellation 2 Hours Prior'),
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
