import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/l10n.dart';

class BookingProgressHeader extends StatelessWidget {
  final int currentStep; // 1 = Specialist, 2 = Date & Time, 3 = Summary

  const BookingProgressHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final steps = [l10n.specialist, l10n.dateAndTime, l10n.bookingSummary];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderDark),
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
                        : AppColors.bgDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent || isDone
                          ? AppColors.primary
                          : AppColors.glassBorderDark,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : AppColors.textMutedDark,
                          ),
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? Colors.white
                          : (isDone
                              ? AppColors.textSecondaryDark
                              : AppColors.textMutedDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.textMutedDark),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
