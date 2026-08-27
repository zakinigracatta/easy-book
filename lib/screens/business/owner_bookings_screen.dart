import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../providers/owner_finance_providers.dart';
import '../../l10n/app_localizations.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title: Text(context.tr('Bookings Management')),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              tooltip: 'New Walk-in',
              onPressed: () => context.push('/quick-walk-in'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => ref
                    .read(ownerBookingSearchQueryProvider.notifier)
                    .state = val,
                decoration: InputDecoration(
                  hintText: 'Search by customer, phone, or ID...',
                  hintStyle: TextStyle(
                      fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => ref
                              .read(ownerBookingSearchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: filters.map((f) {
                  final isSelected = activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(f),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
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

            // Bookings List View
            Expanded(
              child: bookingsAsync.when(
                data: (_) {
                  if (filteredBookings.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.calendar_today_rounded,
                      title: 'No Bookings Found',
                      description:
                          'No bookings match your current filter or search criteria.',
                      actionLabel: 'New Walk-in Booking',
                      onActionTap: () => context.push('/quick-walk-in'),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            ref.invalidate(ownerTodayProfitAndLossProvider);
                            ref.invalidate(ownerProfitAndLossProvider);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr(
                                    'Updated booking status to {status}',
                                    params: {
                                      'status': newStatus.name.toUpperCase(),
                                    },
                                  ),
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('Something went wrong')),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        onRescheduleTap: () =>
                            context.push('/booking-calendar'),
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Bookings',
                  description: 'An error occurred while retrieving bookings.',
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 1),
      ),
    );
  }
}
