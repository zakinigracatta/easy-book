import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/service_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../l10n/l10n.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onBookTap;
  final VoidCallback? cardTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.isSelected = false,
    required this.onBookTap,
    this.cardTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        service.discountPrice != null && service.discountPrice! < service.price;
    final effectivePrice = hasDiscount ? service.discountPrice! : service.price;

    return GlassCard(
      onTap: cardTap ?? onBookTap,
      borderColor: isSelected ? AppColors.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional Service Image
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: service.imageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.cardDark),
                  errorWidget: (context, url, err) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.cardDark,
                    child: const Icon(Icons.content_cut_rounded,
                        color: AppColors.textMutedDark),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textMutedDark),
                      const SizedBox(width: 4),
                      Text(
                        service.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMutedDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (service.description != null &&
                      service.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Price Display
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(effectivePrice,
                            currency: service.currency),
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(service.price,
                              currency: service.currency),
                          style: const TextStyle(
                            color: AppColors.textMutedDark,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Book / Select Button
            ElevatedButton(
              onPressed: onBookTap,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.accent : AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isSelected
                    ? l10nOf(context).selectedWithCheck
                    : l10nOf(context).book,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
