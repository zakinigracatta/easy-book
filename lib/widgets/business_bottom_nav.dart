import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class BusinessBottomNav extends StatelessWidget {
  final int currentIndex;

  const BusinessBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routes = [
      '/owner-dashboard',
      '/owner-bookings',
      '/booking-calendar',
      '/services-management',
      '/owner-more',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 64,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.cardLight)
            .withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 0, Icons.home_rounded, 'Home', routes[0]),
          _navItem(
            context,
            1,
            Icons.assignment_turned_in_rounded,
            'Bookings',
            routes[1],
          ),
          _navItem(
            context,
            2,
            Icons.calendar_month_rounded,
            'Calendar',
            routes[2],
          ),
          _navItem(
            context,
            3,
            Icons.design_services_rounded,
            'Services',
            routes[3],
          ),
          _navItem(context, 4, Icons.grid_view_rounded, 'More', routes[4]),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    String route,
  ) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return GestureDetector(
      onTap: () {
        if (!isSelected) context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.12)
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
              context.tr(label),
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
