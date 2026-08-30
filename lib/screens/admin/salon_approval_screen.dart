import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';

class SalonApprovalScreen extends StatelessWidget {
  const SalonApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = [
      {
        'name': 'صالون إيليت للعناية',
        'owner': 'مايكل سكوت',
        'location': 'بروكلين، نيويورك'
      },
      {
        'name': 'استوديو سيرينيتي للتجميل',
        'owner': 'راشيل غرين',
        'location': 'مانهاتن، نيويورك'
      },
    ];

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
          title: const Text('طلبات اعتماد الصالونات المعلقة'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pending.length,
          itemBuilder: (context, index) {
            final p = pending[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('المالك: ${p['owner']} • ${p['location']}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                            onPressed: () {},
                            child: const Text('رفض',
                                style: TextStyle(color: AppColors.error))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {},
                            child: const Text('اعتماد الشريك')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
