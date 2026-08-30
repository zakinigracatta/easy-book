import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/admin-dashboard');
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
                context.go('/admin-dashboard');
              }
            },
          ),
          title: const Text('تحليلات المنصة'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              GlassCard(
                child: ListTile(
                  title: Text('المستخدمون النشطون شهريًا'),
                  subtitle: Text('15,243 مستخدمًا (نمو +12%)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
