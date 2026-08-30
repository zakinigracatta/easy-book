import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class EmployeeScheduleScreen extends StatelessWidget {
  const EmployeeScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
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
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('قائمة الموظفين والجدول'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _shiftCard(
                'ماركوس فانس', 'الاثنين - الجمعة', '09:00 AM - 05:00 PM'),
            _shiftCard(
                'إيلينا روستوفا', 'الثلاثاء - السبت', '10:00 AM - 06:00 PM'),
            _shiftCard('ديفيد كيم', 'الأربعاء - الأحد', '12:00 PM - 08:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _shiftCard(String name, String days, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: const Icon(Icons.schedule_rounded),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$days • $hours'),
        ),
      ),
    );
  }
}
