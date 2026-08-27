import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// App drawer for Business Owner / Partner screens.
/// Admin Portal is web-only and separate.
class AppDrawer extends StatelessWidget {
  final String portalType;

  const AppDrawer({super.key, required this.portalType});

  @override
  Widget build(BuildContext context) {
    final signedInEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    final businessItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_rounded, 'route': '/owner-dashboard'},
      {'title': 'Salon Profile', 'icon': Icons.storefront_rounded, 'route': '/salon-management'},
      {'title': 'Services Menu', 'icon': Icons.design_services_rounded, 'route': '/services-management'},
      {'title': 'Employees', 'icon': Icons.badge_rounded, 'route': '/employee-management'},
      {'title': 'Employee Schedule', 'icon': Icons.calendar_month_rounded, 'route': '/employee-schedule'},
      {'title': 'Booking Calendar', 'icon': Icons.event_available_rounded, 'route': '/booking-calendar'},
      {'title': 'Customers', 'icon': Icons.people_alt_rounded, 'route': '/customer-management'},
      {'title': 'Sales Report', 'icon': Icons.assessment_rounded, 'route': '/sales-report'},
      {'title': 'Promotions', 'icon': Icons.campaign_rounded, 'route': '/promotion-management'},
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
              accountName: Text(
                context.tr('Salon Management Center'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                signedInEmail,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...businessItems.map(
                    (item) => ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        context.tr(item['title'] as String),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(item['route'] as String);
                      },
                    ),
                  ),
                  Divider(color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: Icon(
                      Icons.settings_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(context.tr('Settings')),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: Text(
                      context.tr('Exit Portal'),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) context.go('/welcome');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
