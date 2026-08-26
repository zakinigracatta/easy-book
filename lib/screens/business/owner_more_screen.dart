import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/owner_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class OwnerMoreScreen extends ConsumerWidget {
  OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(ownerBusinessProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
          title: Text(context.tr('Business Management Menu')),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              businessAsync.when(
                data: (business) => GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        backgroundImage: business.imageUrl.isNotEmpty
                            ? NetworkImage(business.imageUrl)
                            : null,
                        child: business.imageUrl.isEmpty
                            ? Icon(Icons.storefront_rounded, color: Colors.white, size: 24)
                            : null,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              business.category,
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: AppColors.accent),
                        onPressed: () => context.push('/salon-management'),
                      ),
                    ],
                  ),
                ),
                loading: () => SizedBox.shrink(),
                error: (_, __) => SizedBox.shrink(),
              ),
              SizedBox(height: 20),
              _sectionHeader(context, 'BUSINESS'),
              _menuTile(context, 'Business Profile', Icons.storefront_rounded, '/salon-management'),
              _menuTile(context, 'Photos & Gallery', Icons.photo_library_rounded, '/owner-gallery'),
              _menuTile(context, 'Business Hours', Icons.access_time_filled_rounded, '/business-hours'),
              _menuTile(context, 'Services Menu', Icons.design_services_rounded, '/services-management'),
              SizedBox(height: 20),
              _sectionHeader(context, 'TEAM'),
              _menuTile(context, 'Employees & Specialists', Icons.badge_rounded, '/employee-management'),
              _menuTile(context, 'Employee Rosters & Time Off', Icons.calendar_month_rounded, '/employee-schedule'),
              SizedBox(height: 20),
              _sectionHeader(context, 'CUSTOMERS'),
              _menuTile(context, 'Customer Database & CRM', Icons.people_alt_rounded, '/customer-management'),
              _menuTile(context, 'Customer Reviews & Ratings', Icons.star_rounded, '/owner-reviews'),
              SizedBox(height: 20),
              _sectionHeader(context, 'MARKETING'),
              _menuTile(context, 'Offers & Promotions', Icons.campaign_rounded, '/promotion-management'),
              SizedBox(height: 20),
              _sectionHeader(context, 'FINANCE'),
              _menuTile(
                context,
                'Finance, Expenses & Profit',
                Icons.account_balance_wallet_rounded,
                '/sales-report',
              ),
              SizedBox(height: 20),
              _sectionHeader(context, 'ACCOUNT'),
              _menuTile(context, 'Notifications', Icons.notifications_rounded, '/owner-notifications'),
              _menuTile(context, 'System Settings', Icons.settings_rounded, '/settings'),
            ],
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        context.tr(title),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: AppColors.primaryLight, size: 22),
          title: Text(
            context.tr(title),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
