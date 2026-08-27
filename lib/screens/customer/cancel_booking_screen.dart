import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../l10n/l10n.dart';

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
        SnackBar(content: Text(l10nOf(context).bookingIdNotFound)),
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
          SnackBar(content: Text(l10nOf(context).bookingCancelledSuccessfully)),
        );
        context.go('/my-bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  l10nOf(context).bookingCancellationFailed(e.toString()))),
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
          title: Text(l10nOf(context).cancelBooking),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                borderColor: AppColors.error,
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 50, color: AppColors.error),
                    SizedBox(height: 12),
                    Text(l10nOf(context).confirmCancellationQuestion,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(l10nOf(context).cancellationDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMutedDark)),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: l10nOf(context).confirmCancellation,
                backgroundColor: AppColors.error,
                isLoading: _isCancelling,
                onPressed: _handleCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
