import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class AppDrawer extends ConsumerWidget {
  final String portalType; // 'business' or 'admin'

  const AppDrawer({super.key, required this.portalType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusiness = portalType == 'business';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    final businessItems = [
      {
        'title': 'لوحة التحكم',
        'icon': Icons.dashboard_rounded,
        'route': '/owner-dashboard'
      },
      {
        'title': 'ملف الصالون',
        'icon': Icons.storefront_rounded,
        'route': '/salon-management'
      },
      {
        'title': 'قائمة الخدمات',
        'icon': Icons.design_services_rounded,
        'route': '/services-management'
      },
      {
        'title': 'الموظفون',
        'icon': Icons.badge_rounded,
        'route': '/employee-management'
      },
      {
        'title': 'جدول الموظفين',
        'icon': Icons.calendar_month_rounded,
        'route': '/employee-schedule'
      },
      {
        'title': 'تقويم الحجوزات',
        'icon': Icons.event_available_rounded,
        'route': '/booking-calendar'
      },
      {
        'title': 'العملاء',
        'icon': Icons.people_alt_rounded,
        'route': '/customer-management'
      },
      {
        'title': 'التقرير المالي',
        'icon': Icons.assessment_rounded,
        'route': '/sales-report'
      },
      {
        'title': 'العروض',
        'icon': Icons.campaign_rounded,
        'route': '/promotion-management'
      },
    ];

    final adminItems = [
      {
        'title': 'بوابة الإدارة',
        'icon': Icons.admin_panel_settings_rounded,
        'route': '/admin-dashboard'
      },
      {
        'title': 'إدارة المستخدمين',
        'icon': Icons.group_rounded,
        'route': '/users-management'
      },
      {
        'title': 'اعتماد الصالونات',
        'icon': Icons.verified_user_rounded,
        'route': '/salon-approval'
      },
      {
        'title': 'إدارة المدفوعات',
        'icon': Icons.payments_rounded,
        'route': '/payment-management'
      },
      {
        'title': 'تحليلات المنصة',
        'icon': Icons.bar_chart_rounded,
        'route': '/analytics'
      },
      {
        'title': 'التقارير والسجلات',
        'icon': Icons.summarize_rounded,
        'route': '/reports'
      },
    ];

    final items = isBusiness ? businessItems : adminItems;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
              ),
              accountName: Text(
                isBusiness ? 'مركز إدارة الصالون' : 'مدير المنصة',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                isBusiness
                    ? 'easybook.business@portal.com'
                    : 'admin@easybook.com',
                style: TextStyle(color: mutedColor, fontSize: 12),
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
                  Divider(
                    color: isDark
                        ? AppColors.glassBorderDark
                        : AppColors.glassBorderLight,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: const Text('الإعدادات'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    title: const Text('تسجيل الخروج',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) return;
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
