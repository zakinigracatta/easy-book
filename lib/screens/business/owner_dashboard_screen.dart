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

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        drawer: const AppDrawer(portalType: 'business'),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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

                  const SizedBox(height: 20),

                  // 2. TODAY METRICS GRID
                  _buildMetricsSection(bookingsAsync, todayFinanceAsync),

                  const SizedBox(height: 24),

                  // 3. QUICK ACTIONS
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // 4. UPCOMING BOOKINGS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Bookings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/owner-bookings'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _buildUpcomingBookingsList(context, ref, bookingsAsync),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic biz,
      int unreadNotificationsCount) {
    final isOpen = biz.isActive &&
        biz.businessStatus == 'open' &&
        biz.acceptingBookings;

    return GlassCard(
      padding: const EdgeInsets.all(16),
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
                        ? const Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 24)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.cardDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_rounded,
                          size: 14, color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Business Name, Rating & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biz.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      '${biz.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4, width: 8),
                    // Open / Closed Status Badge
                    GestureDetector(
                      onTap: () => ref
                          .read(ownerBusinessProvider.notifier)
                          .toggleAcceptingBookings(!biz.acceptingBookings),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                            const SizedBox(width: 4),
                            Text(
                              isOpen ? 'OPEN' : 'CLOSED',
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
                  child: const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimaryDark),
                ),
                onPressed: () => context.push('/owner-notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textPrimaryDark),
                onPressed: () => context.push('/salon-management'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return const GlassCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: AppColors.glassBorderDark),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Easy Book Business',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Loading business details...',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMutedDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderError(BuildContext context, WidgetRef ref, Object err) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.glassBorderDark,
            child: Icon(Icons.storefront_rounded, color: AppColors.gold, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Business Profile Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete your business registration to manage bookings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
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
          orElse: () => AppColors.textMutedDark,
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
                    iconColor: AppColors.primaryLight,
                    subtitle: 'TODAY',
                  ),
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
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
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => const Row(
        children: [
          Expanded(
            child: OwnerStatCard(
              label: "Today's Bookings",
              value: '—',
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primaryLight,
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
        const SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: 'Finance',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primaryLight,
            onTap: () => context.push('/sales-report'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            title: 'Add Service',
            icon: Icons.add_business_rounded,
            color: AppColors.accent,
            onTap: () => context.push('/add-service'),
          ),
        ),
        const SizedBox(width: 10),
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
            title: 'No Bookings Today',
            description:
                "You're all clear for now. New bookings will appear here.",
            actionLabel: 'Create Walk-in',
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
                    content: Text(
                        'Booking status updated to ${newStatus.name.toUpperCase()}'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              onRescheduleTap: () => context.push('/booking-calendar'),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => const OwnerEmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Unable to Load Bookings',
        description: 'Please check your connection and try again.',
      ),
    );
  }
}
