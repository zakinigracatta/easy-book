import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../l10n/l10n.dart';

class AppDrawer extends StatelessWidget {
  final String portalType; // 'business' or 'admin'

  const AppDrawer({super.key, required this.portalType});

  @override
  Widget build(BuildContext context) {
    final isBusiness = portalType == 'business';
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

    final adminItems = [
      {
        'title': l10n.adminPortal,
        'icon': Icons.admin_panel_settings_rounded,
        'route': '/admin-dashboard'
      },
      {
        'title': l10n.manageUsers,
        'icon': Icons.group_rounded,
        'route': '/users-management'
      },
      {
        'title': l10n.salonApprovals,
        'icon': Icons.verified_user_rounded,
        'route': '/salon-approval'
      },
      {
        'title': l10n.paymentManagement,
        'icon': Icons.payments_rounded,
        'route': '/payment-management'
      },
      {
        'title': l10n.platformAnalytics,
        'icon': Icons.bar_chart_rounded,
        'route': '/analytics'
      },
      {
        'title': l10n.reportsAndLogs,
        'icon': Icons.summarize_rounded,
        'route': '/reports'
      },
    ];

    final items = isBusiness ? businessItems : adminItems;

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
                isBusiness
                    ? l10n.salonManagementCenter
                    : l10n.platformSuperAdmin,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              accountEmail: Text(
                isBusiness
                    ? 'easybook.business@portal.com'
                    : 'admin@easybook.com',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    isBusiness ? AppColors.primary : AppColors.error,
                child: Icon(
                  isBusiness
                      ? Icons.storefront_rounded
                      : Icons.security_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...items.map((item) => ListTile(
                        leading: Icon(
                          item['icon'] as IconData,
                          color: isBusiness ? colors.primary : colors.error,
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
