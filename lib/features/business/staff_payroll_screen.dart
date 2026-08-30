import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';

class StaffPayrollScreen extends StatelessWidget {
  const StaffPayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رواتب الموظفين والعمولات')),
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
                  Text('إجمالي مستحقات الموظفين الشهرية',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: ListTile(
                title: const Text('ماركوس فانس',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'الراتب الأساسي: \$3,000 • العمولة: \$1,420 • الإكراميات: \$340'),
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
