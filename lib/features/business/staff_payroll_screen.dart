import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';

class StaffPayrollScreen extends StatelessWidget {
  const StaffPayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Payroll & Commissions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const GlassCard(
              child: Column(
                children: [
                  GradientText('\$14,250.00',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Total Monthly Staff Payouts',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: ListTile(
                title: const Text('Marcus Vance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Base Salary: \$3,000 • Commission: \$1,420 • Tips: \$340'),
                trailing: const Text('\$4,760',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
