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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              biz.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedTextColor,
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
              _sectionHeader(context, 'BUSINESS'),
              _menuTile(context, 'Business Profile', Icons.storefront_rounded,
                  '/salon-management'),
              _menuTile(context, 'Photos & Gallery',
                  Icons.photo_library_rounded, '/owner-gallery'),
              _menuTile(context, 'Business Hours',
                  Icons.access_time_filled_rounded, '/business-hours'),
              _menuTile(context, 'Services Menu', Icons.design_services_rounded,
                  '/services-management'),
              const SizedBox(height: 20),
              _sectionHeader(context, 'TEAM'),
              _menuTile(context, 'Employees & Specialists', Icons.badge_rounded,
                  '/employee-management'),
              _menuTile(context, 'Employee Rosters & Time Off',
                  Icons.calendar_month_rounded, '/employee-schedule'),
              const SizedBox(height: 20),
              _sectionHeader(context, 'CUSTOMERS'),
              _menuTile(context, 'Customer Database & CRM',
                  Icons.people_alt_rounded, '/customer-management'),
              _menuTile(context, 'Customer Reviews & Ratings',
                  Icons.star_rounded, '/owner-reviews'),
              const SizedBox(height: 20),
              _sectionHeader(context, 'MARKETING'),
              _menuTile(context, 'Offers & Promotions', Icons.campaign_rounded,
                  '/promotion-management'),
              const SizedBox(height: 20),
              _sectionHeader(context, 'FINANCE'),
              _menuTile(
                context,
                'Finance, Expenses & Profit',
                Icons.account_balance_wallet_rounded,
                '/sales-report',
              ),
              const SizedBox(height: 20),
              _sectionHeader(context, 'ACCOUNT'),
              _menuTile(context, 'Notifications', Icons.notifications_rounded,
                  '/owner-notifications'),
              _menuTile(context, 'System Settings', Icons.settings_rounded,
                  '/settings'),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: mutedTextColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menuTile(
      BuildContext context, String title, IconData icon, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: AppColors.primary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: primaryTextColor,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: mutedTextColor),
        ),
      ),
    );
  }
}
