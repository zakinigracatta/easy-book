import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/l10n.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, this.booking});

  final BookingModel? booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10nOf(context).bookingDetails)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10nOf(context).bookingDetailsUnavailable),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/my-bookings'),
                child: Text(l10nOf(context).backToMyBookings),
              ),
            ],
          ),
        ),
      );
    }

    final dateText = DateFormat(
      'EEEE, dd MMMM yyyy • hh:mm a',
      l10nOf(context).localeName,
    ).format(b.startDateTime);
    final statusText = switch (b.status) {
      BookingStatus.pending => l10nOf(context).pending,
      BookingStatus.confirmed => l10nOf(context).confirmed,
      BookingStatus.arrived => l10nOf(context).arrived,
      BookingStatus.inProgress => l10nOf(context).inProgress,
      BookingStatus.completed => l10nOf(context).completed,
      BookingStatus.cancelled => l10nOf(context).cancelled,
      BookingStatus.noShow => l10nOf(context).noShow,
    };
    final statusColor = b.status == BookingStatus.cancelled
        ? AppColors.error
        : b.status == BookingStatus.completed
            ? AppColors.success
            : AppColors.primary;

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
          title: Text(l10nOf(context).bookingDetails),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        size: 120, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(l10nOf(context).bookingReference(b.id),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(l10nOf(context).showReferenceAtCheckIn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMutedDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.businessName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    const Divider(height: 24),
                    _row(l10nOf(context).service, b.serviceName),
                    const SizedBox(height: 8),
                    _row(l10nOf(context).specialist, b.staffName),
                    const SizedBox(height: 8),
                    _row(l10nOf(context).time, dateText),
                    const SizedBox(height: 8),
                    _row(l10nOf(context).price,
                        '${b.servicePrice.toStringAsFixed(2)} AED'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 88,
                          child: Text(l10nOf(context).status,
                              style: const TextStyle(
                                  color: AppColors.textMutedDark,
                                  fontSize: 12)),
                        ),
                        Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textMutedDark, fontSize: 12)),
        ),
        Expanded(
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
