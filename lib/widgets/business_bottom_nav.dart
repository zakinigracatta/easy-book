import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class BusinessBottomNav extends StatelessWidget {
  final int currentIndex;

  const BusinessBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final routes = [
      '/owner-dashboard',
      '/booking-calendar',
      '/services-management',
      '/customer-management',
      '/salon-management',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
              context, 0, Icons.dashboard_rounded, 'لوحة التحكم', routes[0]),
          _navItem(
              context, 1, Icons.calendar_month_rounded, 'الحجوزات', routes[1]),
          _navItem(
              context, 2, Icons.design_services_rounded, 'الخدمات', routes[2]),
          _navItem(context, 3, Icons.people_alt_rounded, 'العملاء', routes[3]),
          _navItem(context, 4, Icons.storefront_rounded, 'الصالون', routes[4]),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label,
      String route) {
    final isSelected = currentIndex == index;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.accent : mutedColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.accent : mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
