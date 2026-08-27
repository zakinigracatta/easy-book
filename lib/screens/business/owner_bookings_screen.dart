import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/l10n.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = l10nOf(context);
    final activeFilter = ref.watch(ownerBookingFilterProvider);
    final searchQuery = ref.watch(ownerBookingSearchQueryProvider);
    final filteredBookings = ref.watch(filteredOwnerBookingsProvider);
    final bookingsAsync = ref.watch(ownerBookingsProvider);

    final filters = [
      'All',
      'Today',
      'Upcoming',
      'Pending',
      'Completed',
      'Cancelled'
    ];
    final filterLabels = {
      'All': l10n.all,
      'Today': l10n.today,
      'Upcoming': l10n.upcoming,
      'Pending': l10n.pending,
      'Completed': l10n.completed,
      'Cancelled': l10n.cancelled,
    };

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
          title: Text(l10n.bookingsManagement),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              tooltip: l10n.newWalkIn,
              onPressed: () => context.push('/quick-walk-in'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => ref
                    .read(ownerBookingSearchQueryProvider.notifier)
                    .state = val,
                decoration: InputDecoration(
                  hintText: l10n.bookingSearchHint,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => ref
                              .read(ownerBookingSearchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: filters.map((f) {
                  final isSelected = activeFilter == f;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filterLabels[f] ?? f),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                      selectedColor: colors.primary,
                      backgroundColor: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.outline,
                        ),
                      ),
                      onSelected: (_) {
                        ref.read(ownerBookingFilterProvider.notifier).state = f;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: bookingsAsync.when(
                data: (_) {
                  if (filteredBookings.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.calendar_today_rounded,
                      title: l10n.noBookingsFound,
                      description: l10n.noBookingsMatch,
                      actionLabel: l10n.newWalkInBooking,
                      onActionTap: () => context.push('/quick-walk-in'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(ownerBookingsProvider.notifier).loadBookings(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return OwnerBookingCard(
                          booking: booking,
                          onStatusChanged: (newStatus) async {
                            try {
                              await ref
                                  .read(ownerBookingsProvider.notifier)
                                  .updateStatus(booking.id, newStatus);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.bookingStatusUpdated),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.bookingStatusUpdateFailed),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          onRescheduleTap: () =>
                              context.push('/booking-calendar'),
                        );
                      },
                    ),
                  );
                },
                loading: () => Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: l10n.unableToLoadBookings,
                  description: l10n.bookingLoadError,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 1),
      ),
    );
  }
}
