import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10nOf(context).myBookings),
        actions: [
          IconButton(
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
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(l10nOf(context).bookingLoadFailedWithError('$err'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMutedDark)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(appointmentsProvider.notifier)
                      .loadAppointments(),
                  child: Text(l10nOf(context).retry),
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
                  const Icon(Icons.calendar_today_rounded,
                      size: 60, color: AppColors.textMutedDark),
                  const SizedBox(height: 16),
                  Text(l10nOf(context).noBookingsFound,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(l10nOf(context).noCustomerBookings,
                      style: TextStyle(color: AppColors.textMutedDark)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text(l10nOf(context).bookNow),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(appointmentsProvider.notifier).loadAppointments(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                final dateStr = DateFormat('dd MMM yyyy • hh:mm a', 'ar')
                    .format(b.startDateTime);
                final isCancelled = b.status == BookingStatus.cancelled;
                final isConfirmed = b.status == BookingStatus.confirmed;
                final isPending = b.status == BookingStatus.pending;
                final canModify = isPending || isConfirmed;

                final statusColor = isCancelled
                    ? AppColors.error
                    : (isConfirmed
                        ? AppColors.success
                        : (isPending ? AppColors.warning : Colors.blue));

                final statusText = switch (b.status) {
                  BookingStatus.pending => l10nOf(context).pending,
                  BookingStatus.confirmed => l10nOf(context).confirmed,
                  BookingStatus.arrived => l10nOf(context).arrived,
                  BookingStatus.inProgress => l10nOf(context).inProgress,
                  BookingStatus.completed => l10nOf(context).completed,
                  BookingStatus.cancelled => l10nOf(context).cancelled,
                  BookingStatus.noShow => l10nOf(context).noShow,
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GlassCard(
                    onTap: () => context.push('/booking-details', extra: b),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                b.businessName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${b.serviceName} • $dateStr',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark)),
                        const SizedBox(height: 4),
                        Text(l10nOf(context).specialistName(b.staffName),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMutedDark)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(b.servicePrice),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary),
                            ),
                            if (canModify)
                              Flexible(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => context.push(
                                          '/reschedule-booking',
                                          extra: b),
                                      child: Text(l10nOf(context).reschedule,
                                          style: const TextStyle(fontSize: 11)),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => context
                                          .push('/cancel-booking', extra: b.id),
                                      child: Text(l10nOf(context).cancel,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }
}
