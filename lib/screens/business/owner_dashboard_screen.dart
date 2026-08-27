import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_stat_card.dart';
import '../../widgets/business/quick_action_card.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../providers/owner_finance_providers.dart';
import '../../models/booking_model.dart';
import '../../models/profit_and_loss_summary.dart';
import '../../l10n/l10n.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    if (kDebugMode) {
      debugPrint('[OWNER] dashboard initialized');
    }

    final businessAsync = ref.watch(ownerBusinessProvider);
    final bookingsAsync = ref.watch(ownerBookingsProvider);
    final notificationsAsync = ref.watch(ownerNotificationsProvider);
    final todayFinanceAsync = ref.watch(ownerTodayProfitAndLossProvider);

    final unreadNotificationsCount = notificationsAsync.maybeWhen(
      data: (nList) => nList.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

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
        drawer: AppDrawer(portalType: 'business'),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentBusinessIdProvider);
              ref.invalidate(ownerBusinessProvider);
              ref.invalidate(ownerBookingsProvider);
              ref.invalidate(ownerNotificationsProvider);
              ref.invalidate(ownerTodayProfitAndLossProvider);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER SECTION
                  businessAsync.when(
                    data: (biz) => _buildHeader(
                        context, ref, biz, unreadNotificationsCount),
                    loading: () => _buildHeaderSkeleton(context),
                    error: (err, __) => _buildHeaderError(context, ref, err),
                  ),

                  SizedBox(height: 20),

                  // 2. TODAY METRICS GRID
                  _buildMetricsSection(
                      context, bookingsAsync, todayFinanceAsync),

                  SizedBox(height: 24),

                  // 3. QUICK ACTIONS
                  Text(
                    l10n.quickActions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildQuickActions(context),

                  SizedBox(height: 24),

                  // 4. UPCOMING BOOKINGS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.upcomingBookings,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/owner-bookings'),
                        icon: Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          l10n.viewAll,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  _buildUpcomingBookingsList(context, ref, bookingsAsync),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic biz,
      int unreadNotificationsCount) {
    final isOpen =
        biz.isActive && biz.businessStatus == 'open' && biz.acceptingBookings;

    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Drawer menu trigger & Business Avatar
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        (biz.imageUrl != null && biz.imageUrl.isNotEmpty)
                            ? NetworkImage(biz.imageUrl)
                            : null,
                    child: (biz.imageUrl == null || biz.imageUrl.isEmpty)
                        ? Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 24)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.menu_rounded,
                          size: 14, color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12),

          // Business Name, Rating & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biz.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                    SizedBox(width: 4),
                    Text(
                      '${biz.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4, width: 8),
                    // Open / Closed Status Badge
                    GestureDetector(
                      onTap: () => ref
                          .read(ownerBusinessProvider.notifier)
                          .toggleAcceptingBookings(!biz.acceptingBookings),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isOpen
                                ? AppColors.success.withValues(alpha: 0.5)
                                : AppColors.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              isOpen
                                  ? l10nOf(context).open
                                  : l10nOf(context).closed,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isOpen
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Icons Shortcuts: Notifications & Settings
          Row(
            children: [
              IconButton(
                icon: Badge(
                  isLabelVisible: unreadNotificationsCount > 0,
                  label: Text('$unreadNotificationsCount'),
                  child: Icon(Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                onPressed: () => context.push('/owner-notifications'),
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => context.push('/salon-management'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10nOf(context).easyBookBusiness,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(l10nOf(context).loadingBusinessDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderError(BuildContext context, WidgetRef ref, Object err) {
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            child:
                Icon(Icons.storefront_rounded, color: AppColors.gold, size: 28),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nOf(context).noBusinessProfileFound,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  l10nOf(context).completeBusinessRegistration,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              ref.invalidate(currentBusinessIdProvider);
              ref.invalidate(ownerBusinessProvider);
              ref.invalidate(ownerBookingsProvider);
              ref.invalidate(ownerTodayProfitAndLossProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    AsyncValue<List<BookingModel>> bookingsAsync,
    AsyncValue<ProfitAndLossSummary> financeAsync,
  ) {
    final now = DateTime.now();

    return bookingsAsync.when(
      data: (bookings) {
        final todayBookings = bookings.where((booking) {
          return booking.startDateTime.year == now.year &&
              booking.startDateTime.month == now.month &&
              booking.startDateTime.day == now.day;
        }).toList();

        final pendingCount =
            bookings.where((b) => b.status == BookingStatus.pending).length;
        final customerIdsToday =
            todayBookings.map((b) => b.customerId).toSet().length;

        final revenueText = financeAsync.when(
          data: (finance) =>
              'AED ${finance.recognizedRevenue.toStringAsFixed(0)}',
          loading: () => '—',
          error: (_, __) => '—',
        );
        final expenseText = financeAsync.when(
          data: (finance) => 'AED ${finance.expenses.toStringAsFixed(0)}',
          loading: () => '—',
          error: (_, __) => '—',
        );
        final profitText = financeAsync.when(
          data: (finance) => 'AED ${finance.netProfit.toStringAsFixed(0)}',
          loading: () => '—',
          error: (_, __) => '—',
        );
        final profitColor = financeAsync.maybeWhen(
          data: (finance) =>
              finance.netProfit >= 0 ? AppColors.success : AppColors.error,
          orElse: () => Theme.of(context).colorScheme.onSurfaceVariant,
        );

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).todaysBookings,
                    value: '${todayBookings.length}',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primaryLight,
                    subtitle: 'TODAY',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).recognizedRevenue,
                    value: revenueText,
                    icon: Icons.payments_rounded,
                    iconColor: AppColors.success,
                    subtitle: 'COMPLETED',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).todaysExpenses,
                    value: expenseText,
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.error,
                    subtitle: 'COSTS',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).todaysNetProfit,
                    value: profitText,
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: profitColor,
                    subtitle: 'PROFIT',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).customersToday,
                    value: '$customerIdsToday',
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.accent,
                    subtitle: 'CLIENTS',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: l10nOf(context).pendingBookings,
                    value: '$pendingCount',
                    icon: Icons.pending_actions_rounded,
                    iconColor: AppColors.gold,
                    subtitle: 'ACTION',
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: OwnerStatCard(
              label: l10nOf(context).todaysBookings,
              value: '—',
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primaryLight,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OwnerStatCard(
              label: l10nOf(context).recognizedRevenue,
              value: '—',
              icon: Icons.payments_rounded,
              iconColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            title: l10nOf(context).walkIn,
            icon: Icons.directions_walk_rounded,
            color: AppColors.gold,
            onTap: () => context.push('/quick-walk-in'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: l10nOf(context).finance,
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primaryLight,
            onTap: () => context.push('/sales-report'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: l10nOf(context).addService,
            icon: Icons.add_business_rounded,
            color: AppColors.accent,
            onTap: () => context.push('/add-service'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: l10nOf(context).addEmployee,
            icon: Icons.person_add_alt_1_rounded,
            color: AppColors.success,
            onTap: () => context.push('/add-employee'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookingsList(BuildContext context, WidgetRef ref,
      AsyncValue<List<BookingModel>> bookingsAsync) {
    return bookingsAsync.when(
      data: (bookings) {
        final upcoming = bookings
            .where((b) =>
                b.status != BookingStatus.cancelled &&
                b.status != BookingStatus.completed)
            .take(3)
            .toList();

        if (upcoming.isEmpty) {
          return OwnerEmptyStateWidget(
            icon: Icons.event_available_rounded,
            title: l10nOf(context).noBookingsToday,
            description: l10nOf(context).noBookingsTodayDescription,
            actionLabel: l10nOf(context).createWalkIn,
            onActionTap: () => context.push('/quick-walk-in'),
          );
        }

        return Column(
          children: upcoming.map((b) {
            return OwnerBookingCard(
              booking: b,
              onStatusChanged: (newStatus) async {
                await ref
                    .read(ownerBookingsProvider.notifier)
                    .updateStatus(b.id, newStatus);
                ref.invalidate(ownerTodayProfitAndLossProvider);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10nOf(context).bookingStatusUpdated),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              onRescheduleTap: () => context.push('/booking-calendar'),
            );
          }).toList(),
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => OwnerEmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: l10nOf(context).unableToLoadBookings,
        description: l10nOf(context).checkConnection,
      ),
    );
  }
}
