import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 140,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('Booking Ref')}: #BK-94821',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('Scan code at salon check-in desk'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMutedDark,
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
                    const Text(
                      'Executive Barber Lounge',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '142 Luxury Blvd, NYC',
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                    const Divider(height: 24),
                    Text('${context.tr('Service')}: Royal Haircut & Beard Trim'),
                    const SizedBox(height: 4),
                    Text('${context.tr('Time')}: ${context.tr('Tomorrow')} 10:00 AM'),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('Status')}: ${context.tr('Confirmed')}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
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
}
