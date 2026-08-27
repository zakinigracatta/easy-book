import 'package:flutter/material.dart';
import '../../../models/available_slot.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../l10n/l10n.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<AvailableSlot> slots;
  final String? selectedSlotTime;
  final ValueChanged<AvailableSlot> onSlotSelected;
  final bool isLoading;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlotTime,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              l10nOf(context).checkingAvailableSlots,
              style:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderDark),
        ),
        child: Column(
          children: [
            const Icon(Icons.event_busy_rounded,
                size: 44, color: AppColors.textMutedDark),
            const SizedBox(height: 12),
            Text(
              l10nOf(context).noSlotsOnDate,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              l10nOf(context).chooseAnotherDateOrSpecialist,
              style:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group slots by period
    final morningSlots =
        slots.where((s) => s.period == SlotPeriod.morning).toList();
    final afternoonSlots =
        slots.where((s) => s.period == SlotPeriod.afternoon).toList();
    final eveningSlots =
        slots.where((s) => s.period == SlotPeriod.evening).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morningSlots.isNotEmpty) ...[
          _periodHeader(
              Icons.wb_sunny_outlined, l10nOf(context).morningAppointments),
          _slotGrid(morningSlots),
          const SizedBox(height: 18),
        ],
        if (afternoonSlots.isNotEmpty) ...[
          _periodHeader(
              Icons.wb_cloudy_outlined, l10nOf(context).afternoonAppointments),
          _slotGrid(afternoonSlots),
          const SizedBox(height: 18),
        ],
        if (eveningSlots.isNotEmpty) ...[
          _periodHeader(
              Icons.nights_stay_outlined, l10nOf(context).eveningAppointments),
          _slotGrid(eveningSlots),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _periodHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotGrid(List<AvailableSlot> periodSlots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: periodSlots.length,
      itemBuilder: (context, index) {
        final slot = periodSlots[index];
        final isSel = selectedSlotTime == slot.timeString;

        return GlassCard(
          onTap: () => onSlotSelected(slot),
          borderColor: isSel ? AppColors.primary : null,
          backgroundColor:
              isSel ? AppColors.primary.withValues(alpha: 0.25) : null,
          child: Center(
            child: Text(
              slot.timeString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSel ? AppColors.primaryLight : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
