import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/service_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class SelectedServicesSummary extends StatelessWidget {
  final List<ServiceModel> services;
  final VoidCallback? onEditTap;

  const SelectedServicesSummary({
    super.key,
    required this.services,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    final totalPrice = services.fold<double>(
      0,
      (sum, service) => sum + (service.discountPrice ?? service.price),
    );
    final totalDuration = services.fold<int>(
      0,
      (sum, service) => sum + service.durationMinutes,
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Selected Services'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onEditTap != null)
                GestureDetector(
                  onTap: onEditTap,
                  child: Text(
                    context.tr('Change'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: services.map((service) {
              final price = service.discountPrice ?? service.price;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          service.duration,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            CurrencyFormatter.format(
                              price,
                              currency: service.currency,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(color: AppColors.glassBorderDark, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.tr('Total Duration')}: $totalDuration ${context.tr('min')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMutedDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${context.tr('Subtotal')}: ${CurrencyFormatter.format(totalPrice)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
