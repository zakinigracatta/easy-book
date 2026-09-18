import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';

class BookingDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime today;
  final int maxDays;

  const BookingDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.today,
    this.maxDays = 60,
  });

  @override
  Widget build(BuildContext context) {
    final calendarToday = DateTime(today.year, today.month, today.day);
    final maxDate = calendarToday.add(Duration(days: maxDays));
    final normalizedSelected = selectedDate.isBefore(calendarToday)
        ? calendarToday
        : selectedDate;
    final daysList = List.generate(
      14,
      (index) => calendarToday.add(Duration(days: index)),
    );
    final material = MaterialLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Theme.of(context).colorScheme.surface : AppColors.cardLight;
    final borderColor =
        isDark ? Theme.of(context).dividerColor : AppColors.glassBorderLight;
    final mutedColor =
        isDark ? Theme.of(context).colorScheme.onSurfaceVariant : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('Select Date'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: normalizedSelected,
                  firstDate: calendarToday,
                  lastDate: maxDate,
                );
                if (picked != null) onDateSelected(picked);
              },
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                material.formatMonthYear(normalizedSelected),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: daysList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = daysList[index];
              final isSelected = DateUtils.isSameDay(date, normalizedSelected);
              final isToday = DateUtils.isSameDay(date, calendarToday);
              final weekday = material.narrowWeekdays[date.weekday % 7];

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : cardColor),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : borderColor),
                      width: isSelected || isToday ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : const [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.primary : mutedColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.formatDecimal(date.day),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
