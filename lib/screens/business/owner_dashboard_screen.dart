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
          title: const Text('Salon Owner Portal'),
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
                    Text('Total Revenue (This Month)', style: TextStyle(color: AppColors.textMutedDark, fontSize: 13)),
                    SizedBox(height: 4),
                    GradientText('\$14,250.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('+18% growth from last month', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Metrics Grid
              Row(
                children: [
                  Expanded(child: _metricCard('Bookings', '142', Icons.calendar_month_rounded, AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('Active Staff', '8', Icons.people_rounded, AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('Rating', '4.9 ★', Icons.star_rounded, AppColors.gold)),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Quick Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _quickActionTile(context, 'Salon Profile & Hours', Icons.storefront_rounded, '/salon-management'),
              _quickActionTile(context, 'Services Menu', Icons.design_services_rounded, '/services-management'),
              _quickActionTile(context, 'Staff & Specialists', Icons.badge_rounded, '/employee-management'),
              _quickActionTile(context, 'Employee Rosters & Schedule', Icons.calendar_month_rounded, '/employee-schedule'),
              _quickActionTile(context, 'Booking Calendar', Icons.event_available_rounded, '/booking-calendar'),
              _quickActionTile(context, 'Customer Database', Icons.people_alt_rounded, '/customer-management'),
              _quickActionTile(context, 'Sales & Performance Reports', Icons.assessment_rounded, '/sales-report'),
              _quickActionTile(context, 'Promotions & Discounts', Icons.campaign_rounded, '/promotion-management'),
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
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
        ],
      ),
    );
  }

  Widget _quickActionTile(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedDark),
        ),
      ),
    );
  }
}
