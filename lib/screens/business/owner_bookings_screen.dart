import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';

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
          title: const Text('Bookings Management'),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => ref
                    .read(ownerBookingSearchQueryProvider.notifier)
                    .state = val,
                decoration: InputDecoration(
                  hintText: 'Search by customer, phone, or ID...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: AppColors.textMutedDark),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMutedDark),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => ref
                              .read(ownerBookingSearchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardDark,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.glassBorderDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.glassBorderDark),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(f),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : AppColors.textMutedDark,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.glassBorderDark,
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
                      title: 'No Bookings Found',
                      description:
                          'No bookings match your current filter or search criteria.',
                      actionLabel: 'New Walk-in Booking',
                      onActionTap: () => context.push('/quick-walk-in'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(ownerBookingsProvider.notifier)
                        .loadBookings(),
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
                                  content: Text(
                                      'Booking status updated to ${newStatus.name.toUpperCase()}.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Could not update booking status: ${e.toString().replaceFirst('Exception: ', '')}'),
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
