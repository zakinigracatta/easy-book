import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain_exceptions.dart';
import '../../core/utils/business_clock.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/available_slot.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class RescheduleBookingScreen extends ConsumerStatefulWidget {
  final String? bookingId;
  final BookingModel? booking;

  const RescheduleBookingScreen({super.key, this.bookingId, this.booking});

  @override
  ConsumerState<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState
    extends ConsumerState<RescheduleBookingScreen> {
  BookingModel? _resolveBooking() {
    if (widget.booking != null) return widget.booking;
    final targetId = widget.bookingId?.trim() ?? '';
    if (targetId.isEmpty) return null;
    final bookings = ref.read(appointmentsProvider).value ?? const <BookingModel>[];
    for (final item in bookings) {
      if (item.id == targetId) return item;
    }
    return null;
  }

  late DateTime _selectedDate;
  AvailableSlot? _selectedSlot;
  bool _isLoading = false;
  bool _hasUserSelectedDate = false;

  @override
  void initState() {
    super.initState();
    final nextDate = widget.booking?.startDateTime.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(nextDate.year, nextDate.month, nextDate.day);
  }

  Future<void> _handleConfirmReschedule() async {
    final targetId = widget.bookingId?.trim() ?? '';
    final directBooking = targetId.isEmpty
        ? null
        : ref.read(customerBookingByIdProvider(targetId)).value;
    final booking = _resolveBooking() ?? directBooking;
    final slot = _selectedSlot;
    if (booking == null || slot == null) return;

    final newStartDateTime = slot.startAt;
    final String? newStaffId =
        booking.anySpecialist ? null : booking.staffId;

    if (newStaffId != null && newStaffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('No available specialist was resolved for this time slot.'),
          ),
        ),
      );
      return;
    }

    if (booking.startDateTime.millisecondsSinceEpoch ==
            newStartDateTime.millisecondsSinceEpoch &&
        (booking.anySpecialist || booking.staffId == newStaffId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Please select a different date or time.'),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentsProvider.notifier).rescheduleAppointment(
            bookingId: booking.id,
            newStartDateTime: newStartDateTime,
            newStaffId: newStaffId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Your appointment has been rescheduled successfully.'),
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/my-bookings');
    } on DomainException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(e.message)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Unable to reschedule this appointment. Please try again.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(appointmentsProvider);
    final targetId = widget.bookingId?.trim() ?? '';
    final directBookingAsync =
        widget.booking == null && targetId.isNotEmpty
            ? ref.watch(customerBookingByIdProvider(targetId))
            : null;
    final booking =
        widget.booking ?? _resolveBooking() ?? directBookingAsync?.value;

    if (booking == null &&
        (appointmentsState.isLoading ||
            (directBookingAsync?.isLoading ?? false))) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Reschedule Booking'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Reschedule Booking'))),
        body: Center(child: Text(context.tr('No booking details provided.'))),
      );
    }

    final businessState =
        ref.watch(businessDetailProvider(booking.businessId));
    final business = businessState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final timeZone = business?.timeZone ?? 'Asia/Dubai';
    final today = BusinessClock.calendarToday(timeZone);
    final bookingInBusinessTime =
        BusinessClock.inTimeZone(booking.startDateTime, timeZone);
    final nextBookingDate = DateTime(
      bookingInBusinessTime.year,
      bookingInBusinessTime.month,
      bookingInBusinessTime.day,
    ).add(const Duration(days: 1));
    final defaultDate =
        nextBookingDate.isBefore(today) ? today : nextBookingDate;
    final effectiveSelectedDate = _hasUserSelectedDate
        ? (_selectedDate.isBefore(today) ? today : _selectedDate)
        : defaultDate;

    final slotsState = ref.watch(
      rescheduleSlotsProvider((
        businessId: booking.businessId,
        serviceId: booking.serviceId,
        staffId: booking.staffId,
        anySpecialist: booking.anySpecialist,
        date: effectiveSelectedDate,
        bookingId: booking.id,
      )),
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Reschedule Booking'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.businessName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.anySpecialist
                          ? '${booking.serviceName} • ${context.tr('Specialist')}: ${context.tr('Any Available Specialist')}'
                          : '${booking.serviceName} • ${context.tr('Specialist')}: ${booking.staffName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${context.tr('Current')}: ${Formatters.formatDateTime(bookingInBusinessTime)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Select New Date'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 120,
              child: CalendarDatePicker(
                initialDate: effectiveSelectedDate,
                firstDate: today,
                lastDate: today.add(const Duration(days: 60)),
                onDateChanged: (date) => setState(() {
                  _selectedDate = date;
                  _hasUserSelectedDate = true;
                  _selectedSlot = null;
                }),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Select New Time'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: slotsState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(
                    context.tr(
                      'Unable to load time slots. Please try again.',
                    ),
                  ),
                ),
                data: (availableSlots) {
                  if (availableSlots.isEmpty) {
                    return Center(
                      child: Text(
                        context.tr('No available time slots for this date.'),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      final isSelected =
                          _selectedSlot?.startAt.millisecondsSinceEpoch ==
                              slot.startAt.millisecondsSinceEpoch;
                      return GlassCard(
                        onTap: () => setState(() => _selectedSlot = slot),
                        borderColor:
                            isSelected ? AppColors.primary : null,
                        backgroundColor: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : null,
                        child: Center(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              slot.timeString,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: context.tr(
                _isLoading ? 'Processing...' : 'Confirm Reschedule',
              ),
              onPressed: _isLoading || _selectedSlot == null
                  ? null
                  : _handleConfirmReschedule,
            ),
          ],
        ),
      ),
    );
  }
}
