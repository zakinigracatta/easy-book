import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n.dart';

class BusinessBottomNav extends StatelessWidget {
  final int currentIndex;

  const BusinessBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    const routes = [
      '/owner-dashboard',
      '/owner-bookings',
      '/booking-calendar',
      '/services-management',
      '/owner-more',
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: NavigationBar(
          height: 62,
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index != currentIndex) context.go(routes[index]);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.assignment_outlined),
              selectedIcon: const Icon(Icons.assignment_turned_in_rounded),
              label: l10n.bookings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: l10n.calendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.design_services_outlined),
              selectedIcon: const Icon(Icons.design_services_rounded),
              label: l10n.services,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: l10n.more,
            ),
          ],
        ),
      ),
    );
  }
}
