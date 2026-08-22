import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, this.booking});

  final BookingModel? booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Booking details are unavailable.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/my-bookings'),
                child: const Text('Back to My Bookings'),
              ),
            ],
          ),
        ),
      );
    }

    final dateText =
        DateFormat('EEEE, dd MMMM yyyy • hh:mm a').format(b.startDateTime);
    final statusText =
        b.status.name[0].toUpperCase() + b.status.name.substring(1);
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
          title: const Text('Booking Details'),
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
                    Text('Booking Ref: ${b.id}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Show this booking reference at check-in',
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
                    _row('Service', b.serviceName),
                    const SizedBox(height: 8),
                    _row('Specialist', b.staffName),
                    const SizedBox(height: 8),
                    _row('Time', dateText),
                    const SizedBox(height: 8),
                    _row('Price', '${b.servicePrice.toStringAsFixed(2)} AED'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 88,
                          child: Text('Status',
                              style: TextStyle(
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
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
