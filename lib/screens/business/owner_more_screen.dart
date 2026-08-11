import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../providers/owner_providers.dart';

class OwnerMoreScreen extends ConsumerWidget {
  const OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(ownerBusinessProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Business Management Menu'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Profile Summary Card Header
              businessAsync.when(
                data: (biz) => GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        backgroundImage: (biz.imageUrl.isNotEmpty)
                            ? NetworkImage(biz.imageUrl)
                            : null,
                        child: biz.imageUrl.isEmpty
                            ? const Icon(Icons.storefront_rounded,
                                color: Colors.white, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              biz.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              biz.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMutedDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded,
                            color: AppColors.accent),
                        onPressed: () => context.push('/salon-management'),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // BUSINESS SECTION
              _sectionHeader('BUSINESS'),
              _menuTile(context, 'Business Profile', Icons.storefront_rounded,
                  '/salon-management'),
              _menuTile(context, 'Photos & Gallery', Icons.photo_library_rounded,
                  '/owner-gallery'),
              _menuTile(context, 'Business Hours', Icons.access_time_filled_rounded,
                  '/business-hours'),
              _menuTile(context, 'Services Menu', Icons.design_services_rounded,
                  '/services-management'),

              const SizedBox(height: 20),

              // TEAM SECTION
              _sectionHeader('TEAM'),
              _menuTile(context, 'Employees & Specialists', Icons.badge_rounded,
                  '/employee-management'),
              _menuTile(context, 'Employee Rosters & Time Off',
                  Icons.calendar_month_rounded, '/employee-schedule'),

              const SizedBox(height: 20),

              // CUSTOMERS SECTION
              _sectionHeader('CUSTOMERS'),
              _menuTile(context, 'Customer Database & CRM',
                  Icons.people_alt_rounded, '/customer-management'),
              _menuTile(context, 'Customer Reviews & Ratings',
                  Icons.star_rounded, '/owner-reviews'),

              const SizedBox(height: 20),

              // MARKETING SECTION
              _sectionHeader('MARKETING'),
              _menuTile(context, 'Offers & Promotions', Icons.campaign_rounded,
                  '/promotion-management'),

              const SizedBox(height: 20),

              // INSIGHTS SECTION
              _sectionHeader('INSIGHTS'),
              _menuTile(context, 'Sales & Performance Reports',
                  Icons.assessment_rounded, '/sales-report'),

              const SizedBox(height: 20),

              // ACCOUNT SECTION
              _sectionHeader('ACCOUNT'),
              _menuTile(context, 'Notifications', Icons.notifications_rounded,
                  '/owner-notifications'),
              _menuTile(
                  context, 'System Settings', Icons.settings_rounded, '/settings'),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textMutedDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menuTile(
      BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: AppColors.primaryLight, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimaryDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMutedDark),
        ),
      ),
    );
  }
}
