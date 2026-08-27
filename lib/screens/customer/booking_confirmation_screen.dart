import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/booking_model.dart';
import '../../services/navigation_service.dart';
import '../../l10n/l10n.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _isCreating = false;

  Future<void> _confirmBooking() async {
    debugPrint('BOOKING_CONFIRM_PRESSED');
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      NavigationService().setPendingRoute('/booking-confirmation');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nOf(context).signInToCompleteBooking)),
      );
      context.push('/login');
      return;
    }

    if (!currentUser.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nOf(context).verifyEmailToBook)),
      );
      context.push('/verify-email');
      return;
    }

    final draft = ref.read(bookingDraftProvider);
    if (!draft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nOf(context).completeBookingDetails)),
      );
      return;
    }

    // Parse timeSlot into startDateTime
    int hour = 10;
    int minute = 0;
    try {
      final parts = draft.timeSlot!.split(' ');
      final timeParts = parts[0].split(':');
      hour = int.parse(timeParts[0]);
      minute = int.parse(timeParts[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }
    } catch (e) {
      debugPrint('Error parsing time slot: $e');
    }

    final int durationMinutes = draft.serviceDurationMinutes ?? 30;

    final date = draft.date!;
    final startDateTime =
        DateTime(date.year, date.month, date.day, hour, minute);
    final startTimestamp = startDateTime.millisecondsSinceEpoch;
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    final slotLockId = '${draft.businessId}_${draft.staffId}_$startTimestamp';

    if (kDebugMode) {
      debugPrint('BOOKING_CREATE_START');
    }

    final booking = BookingModel(
      id: '',
      customerId: currentUser.uid,
      customerName: currentUser.displayName ?? l10nOf(context).dearCustomer,
      businessId: draft.businessId!,
      businessName: draft.businessName!,
      serviceId: draft.serviceId!,
      serviceName: draft.serviceName!,
      servicePrice: draft.servicePrice!,
      staffId: draft.staffId!,
      staffName: draft.staffName!,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      status: BookingStatus.pending,
      slotLockId: slotLockId,
    );

    setState(() => _isCreating = true);

    try {
      final result =
          await ref.read(appointmentsProvider.notifier).createBooking(booking);

      debugPrint('BOOKING_CREATE_SUCCESS: ${result.id}');

      if (mounted) {
        context.push('/booking-success');
      }
    } catch (e, st) {
      debugPrint('BOOKING_CREATE_ERROR: $e\n$st');
      if (mounted) {
        final errText = e is FirebaseException
            ? '[${e.code}] ${e.message}'
            : e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errText),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final dateStr = draft.date != null
        ? '${draft.date!.year}-${draft.date!.month.toString().padLeft(2, '0')}-${draft.date!.day.toString().padLeft(2, '0')}'
        : l10nOf(context).notSpecified;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
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
                context.go('/home');
              }
            },
          ),
          title: Text(l10nOf(context).confirmBookingStep),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(draft.businessName ?? l10nOf(context).salon,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Divider(height: 24),
                    _row(l10nOf(context).service,
                        draft.serviceName ?? l10nOf(context).notSpecified),
                    _row(l10nOf(context).duration,
                        draft.serviceDuration ?? l10nOf(context).notSpecified),
                    _row(l10nOf(context).specialist,
                        draft.staffName ?? l10nOf(context).notSpecified),
                    _row(
                        l10nOf(context).dateAndTime,
                        l10nOf(context).dateAtTime(dateStr,
                            draft.timeSlot ?? l10nOf(context).notSpecified)),
                    const Divider(height: 24),
                    _row(l10nOf(context).totalPrice,
                        '\$${(draft.servicePrice ?? 0.0).toStringAsFixed(2)}',
                        isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: l10nOf(context).confirmBooking,
                isLoading: _isCreating,
                onPressed: _confirmBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textMutedDark)),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 17 : 14,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
