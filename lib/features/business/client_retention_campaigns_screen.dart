import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';

class ClientRetentionCampaignsScreen extends StatelessWidget {
  const ClientRetentionCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Retention Campaigns')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const GlassCard(
              child: Column(
                children: [
                  GradientText('Automated SMS & Email Marketing',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Re-engage clients who have not booked in the last 30 days automatically.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: SwitchListTile(
                title: const Text('Send "We Miss You" 20% Discount SMS'),
                subtitle: const Text('Triggers after 30 days inactivity'),
                value: true,
                onChanged: (val) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
