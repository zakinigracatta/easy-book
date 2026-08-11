import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final String portalType; // 'business' or 'admin'

  const AppDrawer({super.key, required this.portalType});

  @override
  Widget build(BuildContext context) {
    final isBusiness = portalType == 'business';

    final businessItems = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard_rounded,
        'route': '/owner-dashboard'
      },
      {
        'title': 'Salon Profile',
        'icon': Icons.storefront_rounded,
        'route': '/salon-management'
      },
      {
        'title': 'Services Menu',
        'icon': Icons.design_services_rounded,
        'route': '/services-management'
      },
      {
        'title': 'Employees',
        'icon': Icons.badge_rounded,
        'route': '/employee-management'
      },
      {
        'title': 'Employee Schedule',
        'icon': Icons.calendar_month_rounded,
        'route': '/employee-schedule'
      },
      {
        'title': 'Booking Calendar',
        'icon': Icons.event_available_rounded,
        'route': '/booking-calendar'
      },
      {
        'title': 'Customers',
        'icon': Icons.people_alt_rounded,
        'route': '/customer-management'
      },
      {
        'title': 'Sales Report',
        'icon': Icons.assessment_rounded,
        'route': '/sales-report'
      },
      {
        'title': 'Promotions',
        'icon': Icons.campaign_rounded,
        'route': '/promotion-management'
      },
    ];

    final adminItems = [
      {
        'title': 'Admin Portal',
        'icon': Icons.admin_panel_settings_rounded,
        'route': '/admin-dashboard'
      },
      {
        'title': 'Manage Users',
        'icon': Icons.group_rounded,
        'route': '/users-management'
      },
      {
        'title': 'Salon Approvals',
        'icon': Icons.verified_user_rounded,
        'route': '/salon-approval'
      },
      {
        'title': 'Payment Management',
        'icon': Icons.payments_rounded,
        'route': '/payment-management'
      },
      {
        'title': 'Platform Analytics',
        'icon': Icons.bar_chart_rounded,
        'route': '/analytics'
      },
      {
        'title': 'Reports & Logs',
        'icon': Icons.summarize_rounded,
        'route': '/reports'
      },
    ];

    final items = isBusiness ? businessItems : adminItems;

    return Drawer(
      backgroundColor: AppColors.bgDark,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.cardDark),
              accountName: Text(
                isBusiness ? 'Salon Management Center' : 'Platform Super Admin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                isBusiness
                    ? 'easybook.business@portal.com'
                    : 'admin@easybook.com',
                style: const TextStyle(
                    color: AppColors.textMutedDark, fontSize: 12),
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
                        leading: Icon(item['icon'] as IconData,
                            color: isBusiness
                                ? AppColors.primary
                                : AppColors.accent),
                        title: Text(item['title'] as String,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(context);
                          context.push(item['route'] as String);
                        },
                      )),
                  const Divider(color: AppColors.glassBorderDark),
                  ListTile(
                    leading: const Icon(Icons.settings_rounded,
                        color: AppColors.textSecondaryDark),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    title: const Text('Exit Portal',
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
