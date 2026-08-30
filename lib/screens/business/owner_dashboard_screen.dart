import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_text.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/welcome');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بوابة مالك الصالون'),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: const AppDrawer(portalType: 'business'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Overview
              GlassCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي إيرادات هذا الشهر',
                        style: TextStyle(
                            color: AppColors.textMutedDark, fontSize: 13)),
                    SizedBox(height: 4),
                    GradientText('\$14,250.00',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('نمو +18% عن الشهر الماضي',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Metrics Grid
              Row(
                children: [
                  Expanded(
                      child: _metricCard('الحجوزات', '142',
                          Icons.calendar_month_rounded, AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _metricCard('الموظفون النشطون', '8',
                          Icons.people_rounded, AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _metricCard('التقييم', '4.9 ★', Icons.star_rounded,
                          AppColors.gold)),
                ],
              ),

              const SizedBox(height: 24),
              const Text('العمليات السريعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _quickActionTile(context, 'ملف الصالون وساعات العمل',
                  Icons.storefront_rounded, '/salon-management'),
              _quickActionTile(context, 'قائمة الخدمات',
                  Icons.design_services_rounded, '/services-management'),
              _quickActionTile(context, 'الموظفون والمختصون',
                  Icons.badge_rounded, '/employee-management'),
              _quickActionTile(context, 'جداول الموظفين والورديات',
                  Icons.calendar_month_rounded, '/employee-schedule'),
              _quickActionTile(context, 'تقويم الحجوزات',
                  Icons.event_available_rounded, '/booking-calendar'),
              _quickActionTile(context, 'قاعدة بيانات العملاء',
                  Icons.people_alt_rounded, '/customer-management'),
              _quickActionTile(context, 'التقارير المالية والأداء',
                  Icons.assessment_rounded, '/sales-report'),
              _quickActionTile(context, 'العروض والخصومات',
                  Icons.campaign_rounded, '/promotion-management'),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _metricCard(String label, String val, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(val,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMutedDark)),
        ],
      ),
    );
  }

  Widget _quickActionTile(
      BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMutedDark),
        ),
      ),
    );
  }
}
