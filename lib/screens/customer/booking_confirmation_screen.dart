import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain_exceptions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../services/navigation_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _isCreating = false;

  Color get _mutedColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.textMutedDark
      : AppColors.textMutedLight;

  Future<void> _confirmBooking() async {
    if (_isCreating) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      NavigationService().setPendingRoute('/booking-confirmation');
      _showMessage('Please sign in to complete your booking.');
      context.push('/login');
      return;
    }

    await currentUser.reload();
    if (!mounted) return;
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser == null) {
      _showMessage('Your session expired. Please sign in again.');
      context.push('/login');
      return;
    }

    if (!refreshedUser.emailVerified) {
      _showMessage('Please verify your email address to complete the booking.');
      context.push('/verify-email');
      return;
    }

    final draft = ref.read(bookingDraftProvider);
    if (!draft.isComplete || draft.date == null || draft.timeSlot == null) {
      _showMessage('Please complete all booking details before confirming.');
      return;
    }

    final staffId = _resolvedStaffId(draft);
    final staffName = _resolvedStaffName(draft);
    if (staffId.isEmpty) {
      _showMessage('No available specialist was resolved for this time slot.');
      return;
    }

    final serviceId = draft.serviceId?.trim() ?? '';
    final serviceName = draft.serviceName?.trim() ?? '';
    final businessId = draft.businessId?.trim() ?? '';
    final businessName = draft.businessName?.trim() ?? '';
    if (serviceId.isEmpty || businessId.isEmpty) {
      _showMessage('The selected service or business is no longer valid.');
      return;
    }

    final startDateTime = _parseStartDateTime(draft.date!, draft.timeSlot!);
    if (startDateTime == null) {
      _showMessage(
        'The selected appointment time is invalid. Please choose it again.',
      );
      return;
    }

    if (!startDateTime.isAfter(DateTime.now())) {
      _showMessage('Please select a future appointment time.');
      return;
    }

    final durationMinutes = draft.totalDurationMinutes;
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    final slotLockId =
        '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';

    final booking = BookingModel(
      id: '',
      customerId: refreshedUser.uid,
      customerName: refreshedUser.displayName?.trim().isNotEmpty == true
          ? refreshedUser.displayName!.trim()
          : refreshedUser.email ?? 'Valued Customer',
      customerPhone: refreshedUser.phoneNumber,
      businessId: businessId,
      businessName: businessName.isEmpty ? 'Business' : businessName,
      serviceId: serviceId,
      serviceName: serviceName.isEmpty ? 'Service' : serviceName,
      servicePrice: draft.totalPrice,
      staffId: staffId,
      staffName: staffName,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      status: BookingStatus.pending,
      slotLockId: slotLockId,
    );

    setState(() => _isCreating = true);
    try {
      await ref.read(appointmentsProvider.notifier).createBooking(booking);
      if (!mounted) return;
      ref.read(bookingDraftProvider.notifier).state = BookingDraft();
      context.go('/booking-success');
    } on DomainException catch (e) {
      if (mounted) _showMessage(e.message, isError: true);
    } on FirebaseException {
      if (mounted) {
        _showMessage(
          'We could not complete the booking. Check your connection and try again.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'We could not complete the booking. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  DateTime? _parseStartDateTime(DateTime date, String rawTime) {
    try {
      final normalized = rawTime.trim().toUpperCase();
      final parts = normalized.split(RegExp(r'\s+'));
      final timeParts = parts.first.split(':');
      if (timeParts.length < 2) return null;

      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (minute < 0 || minute > 59) return null;

      final period = parts.length > 1 ? parts[1] : '';
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      if (hour < 0 || hour > 23) return null;

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  String _resolvedStaffId(BookingDraft draft) {
    final resolved = draft.resolvedStaffId?.trim() ?? '';
    if (resolved.isNotEmpty) return resolved;
    return draft.staffId?.trim() ?? '';
  }

  String _resolvedStaffName(BookingDraft draft) {
    final resolved = draft.resolvedStaffName?.trim() ?? '';
    if (resolved.isNotEmpty) return resolved;
    final selected = draft.staffName?.trim() ?? '';
    if (selected == 'Any Available Specialist') return context.tr(selected);
    return selected.isNotEmpty ? selected : context.tr('Specialist');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(message)),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final dateStr = draft.date == null
        ? context.tr('Not selected')
        : MaterialLocalizations.of(context).formatFullDate(draft.date!);
    final staffName = _resolvedStaffName(draft);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Confirm Booking')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      draft.businessName ?? context.tr('Business'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _row(
                      'Service',
                      draft.serviceName ?? context.tr('Not selected'),
                    ),
                    _row(
                      'Duration',
                      '${draft.totalDurationMinutes} ${context.tr('minutes')}',
                    ),
                    _row('Specialist', staffName),
                    _row(
                      'Date & Time',
                      '$dateStr • ${draft.timeSlot ?? context.tr('Not selected')}',
                    ),
                    const Divider(height: 24),
                    _row(
                      'Total Price',
                      CurrencyFormatter.format(draft.totalPrice),
                      isBold: true,
                      forceLtr: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(
                  'Your appointment is created only after this confirmation succeeds.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _mutedColor),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Confirm Booking',
                isLoading: _isCreating,
                onPressed: _isCreating ? null : _confirmBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    bool isBold = false,
    bool forceLtr = false,
  }) {
    final valueWidget = Text(
      value,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        fontSize: isBold ? 17 : 14,
        color: isBold ? AppColors.primary : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: TextStyle(color: _mutedColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: forceLtr
                  ? Directionality(
                      textDirection: TextDirection.ltr,
                      child: valueWidget,
                    )
                  : valueWidget,
            ),
          ),
        ],
      ),
    );
  }
}
