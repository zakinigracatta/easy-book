import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../models/profit_and_loss_summary.dart';
import '../../providers/owner_finance_providers.dart';
import '../../providers/owner_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../widgets/business/owner_stat_card.dart';
import '../../widgets/business/quick_action_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  OwnerDashboardScreen({super.key});

  Color _mutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;
  }

  Color _cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : AppColors.cardLight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(ownerBusinessProvider);
    final bookingsAsync = ref.watch(ownerBookingsProvider);
    final notificationsAsync = ref.watch(ownerNotificationsProvider);
    final todayFinanceAsync = ref.watch(ownerTodayProfitAndLossProvider);

    final unreadNotificationsCount = notificationsAsync.maybeWhen(
      data: (notifications) =>
          notifications.where((notification) => !notification.isRead).length,
      orElse: () => 0,
    );

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.canPop() ? context.pop() : context.go('/welcome');
      },
      child: Scaffold(
        drawer: AppDrawer(portalType: 'business'),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ownerBusinessProvider);
              ref.invalidate(ownerBookingsProvider);
              ref.invalidate(ownerNotificationsProvider);
              ref.invalidate(ownerTodayProfitAndLossProvider);
              await Future<void>.delayed(Duration.zero);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  businessAsync.when(
                    data: (business) => _buildHeader(
                      context,
                      ref,
                      business,
                      unreadNotificationsCount,
                    ),
                    loading: () => _buildHeaderSkeleton(context),
                    error: (_, __) => _buildHeaderSkeleton(context),
                  ),
                  SizedBox(height: 20),
                  _buildMetricsSection(
                    context,
                    bookingsAsync,
                    todayFinanceAsync,
                  ),
                  SizedBox(height: 24),
                  Text(
                    context.tr('Quick Actions'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildQuickActions(context),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('Upcoming Bookings'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/owner-bookings'),
                        icon: Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          context.tr('View All'),
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

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic business,
    int unreadNotificationsCount,
  ) {
    final acceptingBookings = business.acceptingBookings == true;

    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Builder(
            builder: (drawerContext) => GestureDetector(
              onTap: () => Scaffold.of(drawerContext).openDrawer(),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    backgroundImage: business.imageUrl != null &&
                            business.imageUrl.toString().isNotEmpty
                        ? NetworkImage(business.imageUrl.toString())
                        : null,
                    child: business.imageUrl == null ||
                            business.imageUrl.toString().isEmpty
                        ? Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _cardColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${business.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ref
                          .read(ownerBusinessProvider.notifier)
                          .toggleAcceptingBookings(!acceptingBookings),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (acceptingBookings
                                  ? AppColors.success
                                  : AppColors.error)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (acceptingBookings
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: acceptingBookings
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              context.tr(
                                acceptingBookings ? 'OPEN' : 'CLOSED',
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: acceptingBookings
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
          IconButton(
            tooltip: context.tr('Notifications'),
            icon: Badge(
              isLabelVisible: unreadNotificationsCount > 0,
              label: Text('$unreadNotificationsCount'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/owner-notifications'),
          ),
          IconButton(
            tooltip: context.tr('Settings'),
            icon: Icon(Icons.settings_outlined),
            onPressed: () => context.push('/salon-management'),
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
            backgroundColor: _mutedColor(context).withValues(alpha: 0.2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Easy Book Business'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  context.tr('Loading business details...'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _mutedColor(context),
                  ),
                ),
              ],
            ),
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
            bookings.where((booking) => booking.status == BookingStatus.pending).length;
        final customerIdsToday =
            todayBookings.map((booking) => booking.customerId).toSet().length;

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
          orElse: () => _mutedColor(context),
        );

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OwnerStatCard(
                    label: "Today's Bookings",
                    value: '${todayBookings.length}',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primary,
                    subtitle: 'TODAY',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: 'Recognized Revenue',
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
                    label: "Today's Expenses",
                    value: expenseText,
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.error,
                    subtitle: 'COSTS',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: "Today's Net Profit",
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
                    label: 'Customers Today',
                    value: '$customerIdsToday',
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.accent,
                    subtitle: 'CLIENTS',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OwnerStatCard(
                    label: 'Pending Bookings',
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
      loading: () => Center(child: CircularProgressIndicator()),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: OwnerStatCard(
              label: "Today's Bookings",
              value: '—',
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OwnerStatCard(
              label: 'Recognized Revenue',
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
            title: 'Walk-in',
            icon: Icons.directions_walk_rounded,
            color: AppColors.gold,
            onTap: () => context.push('/quick-walk-in'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: 'Finance',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            onTap: () => context.push('/sales-report'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: 'Add Service',
            icon: Icons.add_business_rounded,
            color: AppColors.accent,
            onTap: () => context.push('/add-service'),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: 'Add Employee',
            icon: Icons.person_add_alt_1_rounded,
            color: AppColors.success,
            onTap: () => context.push('/add-employee'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookingsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookingModel>> bookingsAsync,
  ) {
    return bookingsAsync.when(
      data: (bookings) {
        final upcoming = bookings
            .where(
              (booking) =>
                  booking.status != BookingStatus.cancelled &&
                  booking.status != BookingStatus.completed,
            )
            .take(3)
            .toList();

        if (upcoming.isEmpty) {
          return OwnerEmptyStateWidget(
            icon: Icons.event_available_rounded,
            title: 'No Bookings Today',
            description:
                "You're all clear for now. New bookings will appear here.",
            actionLabel: 'Create Walk-in',
            onActionTap: () => context.push('/quick-walk-in'),
          );
        }

        return Column(
          children: upcoming.map((booking) {
            return OwnerBookingCard(
              booking: booking,
              onStatusChanged: (newStatus) {
                ref
                    .read(ownerBookingsProvider.notifier)
                    .updateStatus(booking.id, newStatus);
                ref.invalidate(ownerTodayProfitAndLossProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'Booking status updated to {status}',
                        params: {'status': newStatus.name.toUpperCase()},
                      ),
                    ),
                  ),
                );
              },
              onRescheduleTap: () => context.push('/booking-calendar'),
            );
          }).toList(),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (_, __) => OwnerEmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Unable to Load Bookings',
        description: 'Please check your connection and try again.',
      ),
    );
  }
}
