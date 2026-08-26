import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_booking_card.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/app_localizations.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  ConsumerState<BookingCalendarScreen> createState() =>
      _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);

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
          title: Text(context.tr('Owner Booking Calendar')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Booking for Date',
              onPressed: () => context.push('/quick-walk-in'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Calendar Month & Day DatePicker Container
            GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now().add(const Duration(days: 180)),
                onDateChanged: (d) {
                  setState(() => _selectedDate = d);
                },
              ),
            ),

            // Date Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('Bookings for {date}', params: {'date': DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/quick-walk-in'),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(context.tr('New Booking'),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Bookings List for Selected Date
            Expanded(
              child: bookingsAsync.when(
                data: (allBookings) {
                  final dateBookings = allBookings.where((b) {
                    return b.startDateTime.year == _selectedDate.year &&
                        b.startDateTime.month == _selectedDate.month &&
                        b.startDateTime.day == _selectedDate.day;
                  }).toList();

                  if (dateBookings.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.event_available_rounded,
                      title: 'No Bookings on this Date',
                      description:
                          'Schedule is clear for ${DateFormat('MMM d').format(_selectedDate)}.',
                      actionLabel: 'Create Booking',
                      onActionTap: () => context.push('/quick-walk-in'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dateBookings.length,
                    itemBuilder: (context, index) {
                      final b = dateBookings[index];
                      return OwnerBookingCard(
                        booking: b,
                        onStatusChanged: (newStatus) {
                          ref
                              .read(ownerBookingsProvider.notifier)
                              .updateStatus(b.id, newStatus);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Calendar',
                  description:
                      'Could not fetch schedule data for selected date.',
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 2),
      ),
    );
  }
}
