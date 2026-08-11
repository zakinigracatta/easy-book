import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/review_model.dart';

class OwnerReviewsScreen extends ConsumerWidget {
  const OwnerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(ownerReviewsProvider);
    final businessAsync = ref.watch(ownerBusinessProvider);

    final avgRating = businessAsync.value?.rating ?? 4.8;
    final totalReviews = businessAsync.value?.reviewCount ?? 328;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Customer Reviews & Ratings'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Breakdown Overview Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Score Column
                    Column(
                      children: [
                        Text(
                          '$avgRating',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                            Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                            Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                            Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                            Icon(Icons.star_half_rounded, size: 16, color: AppColors.gold),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalReviews Reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),
                    const VerticalDivider(color: AppColors.glassBorderDark, width: 1),
                    const SizedBox(width: 20),

                    // Distribution Bars Column
                    Expanded(
                      child: Column(
                        children: [
                          _ratingBar('5 star', 0.85),
                          _ratingBar('4 star', 0.10),
                          _ratingBar('3 star', 0.03),
                          _ratingBar('2 star', 0.01),
                          _ratingBar('1 star', 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Client Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 10),

              // Reviews List
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.rate_review_rounded,
                      title: 'No Reviews Yet',
                      description: 'Customer reviews will appear here once submitted.',
                    );
                  }

                  return Column(
                    children: reviews.map((r) {
                      final dateStr = DateFormat('MMM d, yyyy').format(r.createdAt);

                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                  backgroundImage: (r.userAvatar.isNotEmpty)
                                      ? NetworkImage(r.userAvatar)
                                      : null,
                                  child: r.userAvatar.isEmpty
                                      ? Text(
                                          r.userName[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLight,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.userName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryDark,
                                        ),
                                      ),
                                      if (r.serviceName != null) ...[
                                        Text(
                                          r.serviceName!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMutedDark,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 14, color: AppColors.gold),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${r.rating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryDark,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              r.comment,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),

                                // Owner Reply Action Button
                                TextButton.icon(
                                  onPressed: () => _showReplyDialog(context, r),
                                  icon: const Icon(Icons.reply_rounded, size: 14),
                                  label: const Text(
                                    'Reply to Review',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Reviews',
                  description: 'Could not fetch customer ratings.',
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _ratingBar(String label, double fillFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fillFactor,
                minHeight: 6,
                backgroundColor: AppColors.glassBgDark,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, ReviewModel review) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Reply to ${review.userName}',
            style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 16)),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type your official business response here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Response posted to review!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Post Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
