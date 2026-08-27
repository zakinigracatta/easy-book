import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class CancelBookingScreen extends ConsumerStatefulWidget {
  final String? bookingId;

  const CancelBookingScreen({super.key, this.bookingId});

  @override
  ConsumerState<CancelBookingScreen> createState() =>
      _CancelBookingScreenState();
}

class _CancelBookingScreenState extends ConsumerState<CancelBookingScreen> {
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    final extraId = GoRouterState.of(context).extra as String?;
    final idToCancel = widget.bookingId ?? extraId ?? '';

    if (idToCancel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Unable to find booking ID to cancel.')),
        ),
      );
      context.go('/my-bookings');
      return;
    }

    setState(() => _isCancelling = true);
    try {
      await ref
          .read(appointmentsProvider.notifier)
          .cancelAppointment(idToCancel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Booking cancelled successfully.')),
          ),
        );
        context.go('/my-bookings');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Unable to cancel this booking. Please try again.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/my-bookings');
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
                context.go('/my-bookings');
              }
            },
          ),
          title: Text(context.tr('Cancel Booking')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                borderColor: AppColors.error,
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 50,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('Are you sure you want to cancel?'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'This will cancel the appointment and release the reserved time slot.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: context.tr('Confirm Cancellation'),
                backgroundColor: AppColors.error,
                isLoading: _isCancelling,
                onPressed: _isCancelling ? null : _handleCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
