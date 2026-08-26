import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/business_model.dart';
import '../../../theme/app_colors.dart';

class BusinessSummary extends StatelessWidget {
  final BusinessModel business;
  final String? distanceText;

  BusinessSummary({
    super.key,
    required this.business,
    this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = business.workingHours.getStatus();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textSecondaryLight;
    final mutedColor =
        isDark ? Theme.of(context).colorScheme.onSurfaceVariant : AppColors.textMutedLight;
    final chipColor = isDark ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.35) : AppColors.glassBgLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                business.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (business.isVerified) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      context.tr('VERIFIED'),
                      style: TextStyle(
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
        SizedBox(height: 6),
        Text(
          business.category,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    business.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Text(
              context.tr(
                '{count} reviews',
                params: {'count': business.reviewCount},
              ),
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: mutedColor, size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                business.address,
                style: TextStyle(color: secondaryColor, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (distanceText != null && distanceText!.isNotEmpty) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  distanceText!,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.tr(statusInfo.statusText),
                  style: TextStyle(
                    color: statusInfo.isOpen
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
