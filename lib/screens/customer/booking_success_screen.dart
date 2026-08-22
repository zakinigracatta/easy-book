import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, this.booking});

  final BookingModel? booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final dateText = b == null
        ? null
        : DateFormat('EEE, dd MMM yyyy • hh:mm a').format(b.startDateTime);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Booking Created!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  b == null
                      ? 'Your appointment was created successfully.'
                      : 'Your request at ${b.businessName} is now pending confirmation.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMutedDark),
                ),
                if (b != null) ...[
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('Booking ID', b.id),
                        const Divider(height: 20),
                        _row('Business', b.businessName),
                        const SizedBox(height: 8),
                        _row('Service', b.serviceName),
                        const SizedBox(height: 8),
                        _row('Specialist', b.staffName),
                        const SizedBox(height: 8),
                        _row('Appointment', dateText ?? ''),
                        const SizedBox(height: 8),
                        _row('Status', 'Pending'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                CustomButton(
                  text: 'View My Bookings',
                  onPressed: () => context.go('/my-bookings'),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Back to Home',
                  isOutlined: true,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
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
          width: 94,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMutedDark)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
