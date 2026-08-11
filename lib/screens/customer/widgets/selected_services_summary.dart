import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../core/utils/currency_formatter.dart';
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

    final totalPrice =
        services.fold(0.0, (sum, s) => sum + (s.discountPrice ?? s.price));
    final totalDuration = services.fold(0, (sum, s) => sum + s.durationMinutes);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Selected Services',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onEditTap != null)
                GestureDetector(
                  onTap: onEditTap,
                  child: const Text(
                    'Change',
                    style: TextStyle(
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
            children: services.map((s) {
              final price = s.discountPrice ?? s.price;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.name,
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
                          s.duration,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          CurrencyFormatter.format(price, currency: s.currency),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
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
                'Total Duration: $totalDuration min',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMutedDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Subtotal: ${CurrencyFormatter.format(totalPrice)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
