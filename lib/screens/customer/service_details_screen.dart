import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_guard.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
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
                context.go('/home');
              }
            },
          ),
          title: const Text('معلومات الخدمة'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('قصة شعر ملكية ونحت اللحية',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('\$65.00 • 45 دقيقة',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    const Text('مميزات الخدمة:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        '• استشارة دقيقة للشعر وتصفيف مخصص\n• منشفة ساخنة للوجه وترطيب بزيت اللحية\n• تدليك فروة الرأس وغسيل فاخر للشعر'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'المتابعة إلى الحجز',
                onPressed: () async {
                  final allowed = await requireLogin(context);
                  if (allowed && context.mounted) {
                    context.push('/booking-service');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
