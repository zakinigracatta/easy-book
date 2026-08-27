import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel? booking;

  const BookingDetailsScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    final currentBooking = booking;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/my-bookings');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/my-bookings'),
          ),
          title: Text(context.tr('Booking Details & QR')),
        ),
        body: currentBooking == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 52,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('No booking details provided.'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.go('/my-bookings'),
                        child: Text(context.tr('My Bookings')),
                      ),
                    ],
                  ),
                ),
              )
            : _BookingDetailsBody(booking: currentBooking),
      ),
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('EEE, MMM d, yyyy • h:mm a', locale)
        .format(booking.startDateTime);
    final statusText = context.tr(_statusKey(booking.status));
    final notes = booking.notes?.trim() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 82,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('Booking Ref'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    '#${booking.id}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.businessName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const Divider(height: 24),
                _detailRow(
                  context,
                  context.tr('Service'),
                  booking.serviceName,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  context.tr('Specialist'),
                  booking.staffName,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  context.tr('Time'),
                  dateText,
                  forceLtr: true,
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  context.tr('Status'),
                  statusText,
                  valueColor: _statusColor(booking.status),
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  context.tr('Price'),
                  CurrencyFormatter.format(booking.servicePrice),
                  forceLtr: true,
                ),
                if (notes.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    context.tr('Notes'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(notes),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool forceLtr = false,
  }) {
    final valueWidget = Text(
      value,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: forceLtr
              ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: valueWidget,
                )
              : valueWidget,
        ),
      ],
    );
  }

  String _statusKey(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => 'Pending',
      BookingStatus.confirmed => 'Confirmed',
      BookingStatus.arrived => 'Arrived',
      BookingStatus.inProgress => 'In Progress',
      BookingStatus.completed => 'Completed',
      BookingStatus.cancelled => 'Cancelled',
      BookingStatus.noShow => 'No Show',
    };
  }

  Color _statusColor(BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed || BookingStatus.completed => AppColors.success,
      BookingStatus.cancelled || BookingStatus.noShow => AppColors.error,
      BookingStatus.pending => AppColors.warning,
      BookingStatus.arrived || BookingStatus.inProgress => AppColors.primary,
    };
  }
}
