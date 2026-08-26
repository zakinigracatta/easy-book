import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/service_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onBookTap;
  final VoidCallback? cardTap;

  ServiceCard({
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
        padding: EdgeInsets.all(4),
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
                      Container(color: Theme.of(context).colorScheme.surface),
                  errorWidget: (context, url, err) => Container(
                    width: 70,
                    height: 70,
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(Icons.content_cut_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              SizedBox(width: 12),
            ],

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(width: 4),
                      Text(
                        service.duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (service.description != null &&
                      service.description!.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      service.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 10),

                  // Price Display
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(effectivePrice,
                            currency: service.currency),
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(service.price,
                              currency: service.currency),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

            SizedBox(width: 8),

            // Book / Select Button
            ElevatedButton(
              onPressed: onBookTap,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.accent : AppColors.primary,
                padding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isSelected ? 'Selected ✓' : 'Book',
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
