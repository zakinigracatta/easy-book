import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = [
      {'name': 'ماركوس فانس', 'role': 'حلاق محترف', 'status': 'نشط'},
      {'name': 'إيلينا روستوفا', 'role': 'مختصة ألوان أولى', 'status': 'نشط'},
      {'name': 'ديفيد كيم', 'role': 'مختص مساج', 'status': 'في إجازة'},
    ];

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
          title: const Text('دليل الموظفين'),
          actions: [
            IconButton(
              tooltip: 'إضافة موظف',
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () => context.push('/add-employee'),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final e = staff[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(e['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(e['role']!),
                  trailing: Text(e['status']!,
                      style: TextStyle(
                          color: e['status'] == 'نشط'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
