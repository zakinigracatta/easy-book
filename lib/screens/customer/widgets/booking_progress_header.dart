import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class BookingProgressHeader extends StatelessWidget {
  final int currentStep; // 1 = Specialist, 2 = Date & Time, 3 = Summary

  BookingProgressHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ['Specialist', 'Date & Time', 'Summary'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final stepNum = index + 1;
          final isDone = stepNum < currentStep;
          final isCurrent = stepNum == currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isCurrent || isDone
                        ? AppColors.primary
                        : Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent || isDone
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isDone
                      ? Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? Colors.white
                          : (isDone
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
