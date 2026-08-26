import 'package:flutter/material.dart';
import '../../../models/working_hours_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';

class WorkingHoursSection extends StatelessWidget {
  final WorkingHoursModel workingHours;

  const WorkingHoursSection({
    super.key,
    required this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final currentDayIndex = DateTime.now().weekday - 1;
    final todayName = days[currentDayIndex];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.primaryLight, size: 18),
              const SizedBox(width: 8),
              Text(context.tr('Working Hours'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: days.map((day) {
              final isToday = day == todayName;
              final hours = workingHours.schedule[day];
              final hoursText =
                  hours != null ? hours.toString() : '09:00 AM – 10:00 PM';
              final isClosed = hours?.isClosed ?? false;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.w500,
                            color:
                                isToday ? AppColors.primaryLight : Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(context.tr('TODAY'),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      hoursText,
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isClosed
                            ? AppColors.error
                            : (isToday
                                ? AppColors.primaryLight
                                : Theme.of(context).colorScheme.onSurfaceVariant),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
