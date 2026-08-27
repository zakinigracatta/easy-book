import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/l10n.dart';

class RescheduleBookingScreen extends ConsumerStatefulWidget {
  final BookingModel? booking;

  const RescheduleBookingScreen({super.key, this.booking});

  @override
  ConsumerState<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState
    extends ConsumerState<RescheduleBookingScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.booking?.startDateTime.add(const Duration(days: 1)) ??
            DateTime.now().add(const Duration(days: 1));
  }

  int _parseSlotHour(String slotStr) {
    // Format: "09:00 AM" or "02:30 PM"
    final parts = slotStr.split(' ');
    final timeParts = parts[0].split(':');
    int h = int.parse(timeParts[0]);
    final isPm = parts[1].toUpperCase() == 'PM';
    if (isPm && h < 12) h += 12;
    if (!isPm && h == 12) h = 0;
    return h;
  }

  int _parseSlotMinute(String slotStr) {
    final parts = slotStr.split(' ');
    final timeParts = parts[0].split(':');
    return int.parse(timeParts[1]);
  }

  Future<void> _handleConfirmReschedule() async {
    final booking = widget.booking;
    if (booking == null || _selectedSlot == null) return;

    final hour = _parseSlotHour(_selectedSlot!);
    final min = _parseSlotMinute(_selectedSlot!);
    final newStartDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, hour, min);

    final durationMinutes =
        booking.endDateTime.difference(booking.startDateTime).inMinutes;
    final calcDuration = durationMinutes > 0 ? durationMinutes : 30;
    final newEndDateTime =
        newStartDateTime.add(Duration(minutes: calcDuration));

    // Check if new time equals old time
    if (booking.startDateTime.millisecondsSinceEpoch ==
        newStartDateTime.millisecondsSinceEpoch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nOf(context).chooseDifferentDateOrTime)),
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
          content: Text(l10nOf(context).rescheduledSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/my-bookings');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10nOf(context).rescheduleBooking)),
        body: Center(
          child: Text(l10nOf(context).bookingDetailsNotProvided),
        ),
      );
    }

    final durationMinutes =
        booking.endDateTime.difference(booking.startDateTime).inMinutes;
    final calcDuration = durationMinutes > 0 ? durationMinutes : 30;

    final slotsState = ref.watch(availableSlotsProvider((
      businessId: booking.businessId,
      staffId: booking.staffId,
      durationMinutes: calcDuration,
      date: _selectedDate,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10nOf(context).rescheduleBooking),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Booking Summary Card
            Card(
              color: Colors.white.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.businessName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10nOf(context).serviceAndSpecialist(
                        booking.serviceName,
                        booking.staffName,
                      ),
                      style: const TextStyle(
                          color: AppColors.textMutedDark, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10nOf(context).currentAppointment(
                            Formatters.formatDateTime(booking.startDateTime),
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Date Picker Header
            Text(l10nOf(context).selectNewDate,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SizedBox(
              height: 120,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (d) => setState(() {
                  _selectedDate = d;
                  _selectedSlot = null;
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Available Time Slots Header
            Text(l10nOf(context).selectNewTime,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Expanded(
              child: slotsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                    child: Text(l10nOf(context).slotsLoadFailed('$err'))),
                data: (availableSlots) {
                  if (availableSlots.isEmpty) {
                    return Center(
                      child: Text(l10nOf(context).noSlotsOnDate),
                    );
                  }

                  _selectedSlot ??= availableSlots.first;

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
                      final s = availableSlots[index];
                      final isSel = _selectedSlot == s;
                      return GlassCard(
                        onTap: () => setState(() => _selectedSlot = s),
                        borderColor: isSel ? AppColors.primary : null,
                        backgroundColor: isSel
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : null,
                        child: Center(
                          child: Text(
                            s,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSel ? AppColors.primary : Colors.white,
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
              text: _isLoading
                  ? l10nOf(context).processing
                  : l10nOf(context).confirmReschedule,
              onPressed: _isLoading ? null : _handleConfirmReschedule,
            ),
          ],
        ),
      ),
    );
  }
}
