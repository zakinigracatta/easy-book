import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Barbershops',
        'icon': Icons.content_cut_rounded,
        'count': '142 Salons',
        'color': AppColors.primary
      },
      {
        'name': 'Hair Salons',
        'icon': Icons.face_rounded,
        'count': '98 Salons',
        'color': AppColors.accent
      },
      {
        'name': 'Spa & Massage',
        'icon': Icons.spa_rounded,
        'count': '65 Centers',
        'color': AppColors.success
      },
      {
        'name': 'Nail Care & Beauty',
        'icon': Icons.brush_rounded,
        'count': '45 Studios',
        'color': AppColors.gold
      },
      {
        'name': 'Skin & Facial Clinics',
        'icon': Icons.clean_hands_rounded,
        'count': '38 Clinics',
        'color': AppColors.info
      },
      {
        'name': 'Tattoo & Piercing',
        'icon': Icons.design_services_rounded,
        'count': '22 Parlors',
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
          title: const Text('All Service Categories'),
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
