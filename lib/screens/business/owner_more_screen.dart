import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/l10n.dart';

class OwnerMoreScreen extends ConsumerWidget {
  const OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(ownerBusinessProvider);
    final l10n = l10nOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.textPrimaryLight;
    final mutedTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;

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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(l10n.businessManagementMenu),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              businessAsync.when(
                data: (biz) => GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        backgroundImage: (biz.imageUrl.isNotEmpty)
                            ? NetworkImage(biz.imageUrl)
                            : null,
                        child: biz.imageUrl.isEmpty
                            ? Icon(Icons.storefront_rounded,
                                color: Colors.white, size: 24)
                            : null,
                      ),
                      SizedBox(width: 14),
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
                            SizedBox(height: 2),
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
              _sectionHeader(context, l10n.business),
              _menuTile(context, l10n.businessProfile, Icons.storefront_rounded,
                  '/salon-management'),
              _menuTile(context, l10n.photosAndGallery,
                  Icons.photo_library_rounded, '/owner-gallery'),
              _menuTile(context, l10n.businessHours,
                  Icons.access_time_filled_rounded, '/business-hours'),
              _menuTile(context, l10n.servicesMenu,
                  Icons.design_services_rounded, '/services-management'),
              SizedBox(height: 20),
              _sectionHeader(context, l10n.team),
              _menuTile(context, l10n.employeesAndSpecialists,
                  Icons.badge_rounded, '/employee-management'),
              _menuTile(context, l10n.employeeRostersAndTimeOff,
                  Icons.calendar_month_rounded, '/employee-schedule'),
              SizedBox(height: 20),
              _sectionHeader(context, l10n.customers),
              _menuTile(context, l10n.customerDatabaseCrm,
                  Icons.people_alt_rounded, '/customer-management'),
              _menuTile(context, l10n.customerReviewsAndRatings,
                  Icons.star_rounded, '/owner-reviews'),
              SizedBox(height: 20),
              _sectionHeader(context, l10n.marketing),
              _menuTile(context, l10n.offersAndPromotions,
                  Icons.campaign_rounded, '/promotion-management'),
              SizedBox(height: 20),
              _sectionHeader(context, l10n.finance),
              _menuTile(
                context,
                l10n.financeExpensesAndProfit,
                Icons.account_balance_wallet_rounded,
                '/sales-report',
              ),
              SizedBox(height: 20),
              _sectionHeader(context, l10n.account),
              _menuTile(context, l10n.notifications,
                  Icons.notifications_rounded, '/owner-notifications'),
              _menuTile(context, l10n.systemSettings, Icons.settings_rounded,
                  '/settings'),
            ],
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
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
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.textPrimaryLight;
    final mutedTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
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
