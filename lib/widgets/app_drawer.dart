import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../l10n/l10n.dart';

class AppDrawer extends StatelessWidget {
  final String portalType; // 'business' only (admin drawer is separate for web)

  const AppDrawer({super.key, required this.portalType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = l10nOf(context);

    final businessItems = [
      {
        'title': l10n.dashboard,
        'icon': Icons.dashboard_rounded,
        'route': '/owner-dashboard'
      },
      {
        'title': l10n.salonProfile,
        'icon': Icons.storefront_rounded,
        'route': '/salon-management'
      },
      {
        'title': l10n.servicesMenu,
        'icon': Icons.design_services_rounded,
        'route': '/services-management'
      },
      {
        'title': l10n.employees,
        'icon': Icons.badge_rounded,
        'route': '/employee-management'
      },
      {
        'title': l10n.employeeSchedule,
        'icon': Icons.calendar_month_rounded,
        'route': '/employee-schedule'
      },
      {
        'title': l10n.bookingCalendar,
        'icon': Icons.event_available_rounded,
        'route': '/booking-calendar'
      },
      {
        'title': l10n.customers,
        'icon': Icons.people_alt_rounded,
        'route': '/customer-management'
      },
      {
        'title': l10n.salesReport,
        'icon': Icons.assessment_rounded,
        'route': '/sales-report'
      },
      {
        'title': l10n.promotions,
        'icon': Icons.campaign_rounded,
        'route': '/promotion-management'
      },
    ];

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).colorScheme.surface
                    : colors.surfaceContainerLow,
              ),
              accountName: Text(
                l10n.salonManagementCenter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              accountEmail: Text(
                'easybook.business@portal.com',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              currentAccountPicture: CircleAvatar(
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
                  ...businessItems.map((item) => ListTile(
                        leading: Icon(
                          item['icon'] as IconData,
                          color: colors.primary,
                        ),
                        title: Text(item['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            )),
                        onTap: () {
                          Navigator.pop(context);
                          context.push(item['route'] as String);
                        },
                      )),
                  Divider(color: colors.outline),
                  ListTile(
                    leading: Icon(Icons.settings_rounded,
                        color: colors.onSurfaceVariant),
                    title: Text(l10n.settings,
                        style: TextStyle(color: colors.onSurface)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout_rounded, color: AppColors.error),
                    title: Text(l10n.exitPortal,
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/welcome');
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
