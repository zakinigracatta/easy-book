import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Barbershops', 'icon': Icons.content_cut_rounded, 'count': '142 Salons', 'color': AppColors.primary},
      {'name': 'Hair Salons', 'icon': Icons.face_rounded, 'count': '98 Salons', 'color': AppColors.accent},
      {'name': 'Spa & Massage', 'icon': Icons.spa_rounded, 'count': '65 Centers', 'color': AppColors.success},
      {'name': 'Nail Care & Beauty', 'icon': Icons.brush_rounded, 'count': '45 Studios', 'color': AppColors.gold},
      {'name': 'Skin & Facial Clinics', 'icon': Icons.clean_hands_rounded, 'count': '38 Clinics', 'color': AppColors.info},
      {'name': 'Tattoo & Piercing', 'icon': Icons.design_services_rounded, 'count': '22 Parlors', 'color': AppColors.error},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('All Service Categories')),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = category['color'] as Color;
            return GlassCard(
              onTap: () => context.push('/salon-list'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(category['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(category['name'] as String),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(category['count'] as String),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
