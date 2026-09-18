import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_localization.dart';
import '../../widgets/glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/admin/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/admin/dashboard'),
          ),
          title: Text(adminText(context, 'Audit reports', 'تقارير التدقيق')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fact_check_outlined, size: 54),
                    const SizedBox(height: 14),
                    Text(
                      adminText(
                        context,
                        'Persistent audit logs are not configured yet.',
                        'سجلات التدقيق الدائمة غير مفعّلة بعد.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminText(
                        context,
                        'This page intentionally shows no security claims until a real audit-log source is connected.',
                        'لا تعرض هذه الصفحة أي ادعاءات أمنية حتى يتم ربط مصدر حقيقي لسجلات التدقيق.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
