import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final categories = [
      {
        'name': l10n.barberSalons,
        'icon': Icons.content_cut_rounded,
        'count': l10n.salonsCount(142),
        'color': AppColors.primary
      },
      {
        'name': l10n.hairSalons,
        'icon': Icons.face_rounded,
        'count': l10n.salonsCount(98),
        'color': AppColors.accent
      },
      {
        'name': l10n.spaAndMassage,
        'icon': Icons.spa_rounded,
        'count': l10n.centersCount(65),
        'color': AppColors.success
      },
      {
        'name': l10n.nailAndBeautyCare,
        'icon': Icons.brush_rounded,
        'count': l10n.studiosCount(45),
        'color': AppColors.gold
      },
      {
        'name': l10n.skinAndFacialClinics,
        'icon': Icons.clean_hands_rounded,
        'count': l10n.clinicsCount(38),
        'color': AppColors.info
      },
      {
        'name': l10n.tattooAndPiercing,
        'icon': Icons.design_services_rounded,
        'count': l10n.shopsCount(22),
        'color': AppColors.error
      },
    ];

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
          title: Text(l10n.allServiceCategories),
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
            final cat = categories[index];
            final color = cat['color'] as Color;
            return GlassCard(
              onTap: () => context.push('/salon-list'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child:
                        Icon(cat['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(cat['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(cat['count'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMutedDark)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
