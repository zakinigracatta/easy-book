import 'package:flutter/material.dart';
import '../../../models/business_model.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/l10n.dart';

class BusinessSummary extends StatelessWidget {
  final BusinessModel business;
  final String? distanceText;

  const BusinessSummary({
    super.key,
    required this.business,
    this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = business.workingHours.getStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Verified Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                business.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (business.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      l10nOf(context).verified,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        // Category Tag
        Text(
          business.category,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 12),

        // Rating & Review Count
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    business.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10nOf(context).reviewsCount(business.reviewCount),
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Address & Location & Distance
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.textMutedDark, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                business.address,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (distanceText != null && distanceText!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.glassBgDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  distanceText!,
                  style: const TextStyle(
                    color: AppColors.textMutedDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Open/Closed Dynamic Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (statusInfo.isOpen ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (statusInfo.isOpen ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      statusInfo.isOpen ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusInfo.statusText,
                style: TextStyle(
                  color:
                      statusInfo.isOpen ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
