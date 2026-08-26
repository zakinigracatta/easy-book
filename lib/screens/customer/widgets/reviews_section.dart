import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/review_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/rating_stars.dart';
import '../../../l10n/app_localizations.dart';

class ReviewsSection extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  ReviewsSection({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined,
                size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(height: 12),
            Text(context.tr('No reviews yet.\nBe the first to review after your appointment.'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Rating breakdown percentages
    final totalCount = reviews.length;
    final count5 = reviews.where((r) => r.rating >= 4.5).length;
    final count4 =
        reviews.where((r) => r.rating >= 3.5 && r.rating < 4.5).length;
    final count3 =
        reviews.where((r) => r.rating >= 2.5 && r.rating < 3.5).length;
    final count2 =
        reviews.where((r) => r.rating >= 1.5 && r.rating < 2.5).length;
    final count1 = reviews.where((r) => r.rating < 1.5).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breakdown Header Card
        GlassCard(
          child: Row(
            children: [
              // Rating Number Overview
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  RatingStars(rating: averageRating, size: 16),
                  SizedBox(height: 6),
                  Text(
                    '$totalReviews reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Container(width: 1, height: 70, color: Theme.of(context).dividerColor),
              SizedBox(width: 20),

              // Rating Distribution Progress Bars
              Expanded(
                child: Column(
                  children: [
                    _barRow('5 ★', count5 / totalCount),
                    _barRow('4 ★', count4 / totalCount),
                    _barRow('3 ★', count3 / totalCount),
                    _barRow('2 ★', count2 / totalCount),
                    _barRow('1 ★', count1 / totalCount),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
        Text(context.tr('Customer Reviews'),
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 12),

        // List of Reviews
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final r = reviews[index];
            const defaultAvatar =
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80';
            final avatarUrl =
                r.userAvatar.isNotEmpty ? r.userAvatar : defaultAvatar;
            final dateStr = DateFormat('MMM dd, yyyy').format(r.createdAt);

            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, err) => Image.network(
                              defaultAvatar,
                              width: 40,
                              height: 40),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            if (r.serviceName != null &&
                                r.serviceName!.isNotEmpty)
                              Text(
                                r.serviceName!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryLight),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  RatingStars(rating: r.rating, size: 14),
                  SizedBox(height: 8),
                  Text(
                    r.comment,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _barRow(String label, double pct) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
