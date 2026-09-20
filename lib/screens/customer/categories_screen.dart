import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const _categories = [
    ('Barbershops', 'Barber', Icons.content_cut_rounded, AppColors.primary),
    ('Hair Salons', 'Hair', Icons.face_rounded, AppColors.accent),
    ('Spa & Massage', 'Spa', Icons.spa_rounded, AppColors.success),
    ('Nail Care & Beauty', 'Nail', Icons.brush_rounded, AppColors.gold),
    ('Skin & Facial Clinics', 'Skin', Icons.clean_hands_rounded, AppColors.info),
    ('Tattoo & Piercing', 'Tattoo', Icons.design_services_rounded, AppColors.error),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
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
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return GlassCard(
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = category.$2;
                context.push('/salon-list');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: category.$4.withValues(alpha: 0.2),
                    child: Icon(category.$3, color: category.$4, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(category.$1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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
