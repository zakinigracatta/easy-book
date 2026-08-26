import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  Color _mutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
  }

  Color _secondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsProvider);
    final mutedColor = _mutedColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('My Bookings')),
        actions: [
          IconButton(
            tooltip: context.tr('Refresh'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(appointmentsProvider.notifier).loadAppointments(),
          ),
        ],
      ),
      body: appointmentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('Unable to load bookings. Please try again.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(appointmentsProvider.notifier)
                      .loadAppointments(),
                  child: Text(context.tr('Retry')),
                ),
              ],
            ),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 60,
                    color: mutedColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('No Bookings Found'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(
                      'You have not scheduled any appointments yet.',
                    ),
                    style: TextStyle(color: mutedColor),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text(context.tr('Book Now')),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final dateStr =
                  '${booking.startDateTime.day}/${booking.startDateTime.month}/${booking.startDateTime.year} '
                  '${booking.startDateTime.hour}:${booking.startDateTime.minute.toString().padLeft(2, '0')}';
              final isCancelled = booking.status == BookingStatus.cancelled;
              final isConfirmed = booking.status == BookingStatus.confirmed;
              final isPending = booking.status == BookingStatus.pending;
              final canModify = (isPending || isConfirmed) &&
                  booking.startDateTime.isAfter(DateTime.now());

              final statusColor = isCancelled
                  ? AppColors.error
                  : (isConfirmed
                      ? AppColors.success
                      : (isPending ? AppColors.warning : Colors.blue));
              final statusKey = booking.status.name[0].toUpperCase() +
                  booking.status.name.substring(1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  onTap: () =>
                      context.push('/booking-details', extra: booking),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.businessName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.tr(statusKey),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${booking.serviceName} • $dateStr',
                          style: TextStyle(
                            fontSize: 13,
                            color: _secondaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.tr('Specialist')}: ${booking.staffName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              CurrencyFormatter.format(booking.servicePrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (canModify)
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => context.push(
                                    '/reschedule-booking',
                                    extra: booking,
                                  ),
                                  child: Text(
                                    context.tr('Reschedule'),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => context.push(
                                    '/cancel-booking',
                                    extra: booking.id,
                                  ),
                                  child: Text(
                                    context.tr('Cancel'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }
}
