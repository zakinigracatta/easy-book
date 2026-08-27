import 'package:flutter/material.dart';
import '../../../models/working_hours_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../l10n/l10n.dart';

class WorkingHoursSection extends StatelessWidget {
  final WorkingHoursModel workingHours;

  const WorkingHoursSection({
    super.key,
    required this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    const dayKeys = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dayLabels = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final currentDayIndex = DateTime.now().weekday - 1;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  color: AppColors.primaryLight, size: 18),
              SizedBox(width: 8),
              Text(
                l10n.businessHours,
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
            children: List.generate(dayKeys.length, (index) {
              final dayKey = dayKeys[index];
              final isToday = index == currentDayIndex;
              final hours = workingHours.schedule[dayKey];
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
                          dayLabels[index],
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
                            child: Text(
                              l10n.today,
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
                                : AppColors.textSecondaryDark),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
