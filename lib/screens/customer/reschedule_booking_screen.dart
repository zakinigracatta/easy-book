import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class RescheduleBookingScreen extends ConsumerStatefulWidget {
  final BookingModel? booking;

  const RescheduleBookingScreen({super.key, this.booking});

  @override
  ConsumerState<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends ConsumerState<RescheduleBookingScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.booking?.startDateTime.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));
  }

  int _parseSlotHour(String slotStr) {
    final parts = slotStr.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final isPm = parts[1].toUpperCase() == 'PM';
    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return hour;
  }

  int _parseSlotMinute(String slotStr) {
    final parts = slotStr.split(' ');
    return int.parse(parts[0].split(':')[1]);
  }

  Future<void> _handleConfirmReschedule() async {
    final booking = widget.booking;
    if (booking == null || _selectedSlot == null) return;

    final hour = _parseSlotHour(_selectedSlot!);
    final minute = _parseSlotMinute(_selectedSlot!);
    final newStartDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    final durationMinutes = booking.endDateTime.difference(booking.startDateTime).inMinutes;
    final effectiveDuration = durationMinutes > 0 ? durationMinutes : 30;
    final newEndDateTime = newStartDateTime.add(Duration(minutes: effectiveDuration));

    if (booking.startDateTime.millisecondsSinceEpoch ==
        newStartDateTime.millisecondsSinceEpoch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Please select a different date or time.'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(appointmentsProvider.notifier).rescheduleAppointment(
            bookingId: booking.id,
            newStartDateTime: newStartDateTime,
            newEndDateTime: newEndDateTime,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Your appointment has been rescheduled successfully.')),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/my-bookings');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Unable to reschedule this appointment. Please try again.')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('Reschedule Booking'))),
        body: Center(child: Text(context.tr('No booking details provided.'))),
      );
    }

    final durationMinutes = booking.endDateTime.difference(booking.startDateTime).inMinutes;
    final effectiveDuration = durationMinutes > 0 ? durationMinutes : 30;

    final slotsState = ref.watch(availableSlotsProvider((
      businessId: booking.businessId,
      staffId: booking.staffId,
      durationMinutes: effectiveDuration,
      date: _selectedDate,
    )));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Reschedule Booking'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.serviceName} • ${context.tr('Specialist')}: ${booking.staffName}',
                      style: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${context.tr('Current')}: ${Formatters.formatDateTime(booking.startDateTime)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 120,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (date) => setState(() {
                  _selectedDate = date;
                  _selectedSlot = null;
                }),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Select New Time'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: slotsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(context.tr('Unable to load time slots. Please try again.')),
                ),
                data: (availableSlots) {
                  if (availableSlots.isEmpty) {
                    return Center(
                      child: Text(context.tr('No available time slots for this date.')),
                    );
                  }

                  _selectedSlot ??= availableSlots.first;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      final isSelected = _selectedSlot == slot;
                      return GlassCard(
                        onTap: () => setState(() => _selectedSlot = slot),
                        borderColor: isSelected ? AppColors.primary : null,
                        backgroundColor: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : null,
                        child: Center(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : Colors.white,
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
              text: context.tr(_isLoading ? 'Processing...' : 'Confirm Reschedule'),
              onPressed: _isLoading ? null : _handleConfirmReschedule,
            ),
          ],
        ),
      ),
    );
  }
}
