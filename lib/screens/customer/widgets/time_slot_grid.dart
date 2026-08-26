import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/available_slot.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('Checking available appointment times...'),
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (slots.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 44, color: mutedColor),
            const SizedBox(height: 12),
            Text(
              context.tr('No available times for this date.'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                'Please select another date or choose Any Available Specialist.',
              ),
              style: TextStyle(color: mutedColor, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final morningSlots =
        slots.where((slot) => slot.period == SlotPeriod.morning).toList();
    final afternoonSlots =
        slots.where((slot) => slot.period == SlotPeriod.afternoon).toList();
    final eveningSlots =
        slots.where((slot) => slot.period == SlotPeriod.evening).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morningSlots.isNotEmpty) ...[
          _periodHeader(
            context,
            Icons.wb_sunny_outlined,
            'Morning Slots',
            secondaryColor,
          ),
          _slotGrid(context, morningSlots),
          const SizedBox(height: 18),
        ],
        if (afternoonSlots.isNotEmpty) ...[
          _periodHeader(
            context,
            Icons.wb_cloudy_outlined,
            'Afternoon Slots',
            secondaryColor,
          ),
          _slotGrid(context, afternoonSlots),
          const SizedBox(height: 18),
        ],
        if (eveningSlots.isNotEmpty) ...[
          _periodHeader(
            context,
            Icons.nights_stay_outlined,
            'Evening Slots',
            secondaryColor,
          ),
          _slotGrid(context, eveningSlots),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _periodHeader(
    BuildContext context,
    IconData icon,
    String title,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const SizedBox.shrink(),
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            context.tr(title),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotGrid(BuildContext context, List<AvailableSlot> periodSlots) {
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
        final isSelected = selectedSlotTime == slot.timeString;

        return GlassCard(
          onTap: () => onSlotSelected(slot),
          borderColor: isSelected ? AppColors.primary : null,
          backgroundColor:
              isSelected ? AppColors.primary.withValues(alpha: 0.18) : null,
          child: Center(
            child: Text(
              slot.timeString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
