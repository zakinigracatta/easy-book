import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class SalonApprovalScreen extends StatelessWidget {
  const SalonApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = [
      {'name': 'Elite Grooming Lounge', 'owner': 'Michael Scott', 'location': 'Brooklyn, NYC'},
      {'name': 'Serenity Beauty Studio', 'owner': 'Rachel Green', 'location': 'Manhattan, NYC'},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/admin-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/admin-dashboard'),
          ),
          title: Text(context.tr('Pending Salon Approvals')),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pending.length,
          itemBuilder: (context, index) {
            final partner = pending[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('${context.tr('Owner')}: ${partner['owner']} • ${partner['location']}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            context.tr('Reject'),
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(context.tr('Approve Partner')),
                        ),
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
