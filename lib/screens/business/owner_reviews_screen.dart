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
import '../../l10n/app_localizations.dart';

class OwnerReviewsScreen extends ConsumerWidget {
  const OwnerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(ownerReviewsProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Customer Reviews & Ratings')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
        ),
        body: reviewsAsync.when(
          data: (reviews) => _buildContent(context, ref, reviews),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => OwnerEmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Unable to Load Reviews',
            description: error.toString(),
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ReviewModel> reviews,
  ) {
    if (reviews.isEmpty) {
      return const OwnerEmptyStateWidget(
        icon: Icons.rate_review_rounded,
        title: 'No Reviews Yet',
        description: 'Customer reviews will appear here once submitted.',
      );
    }

    final average = reviews.fold<double>(0, (sum, r) => sum + r.rating) /
        reviews.length;
    final distribution = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    for (final review in reviews) {
      final star = review.rating.round().clamp(1, 5).toInt();
      distribution[star] = (distribution[star] ?? 0) + 1;
    }
    final repliedCount = reviews
        .where((review) => review.businessReply?.trim().isNotEmpty == true)
        .length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ownerReviewsProvider);
        await ref.read(ownerReviewsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(
            context: context,
            average: average,
            total: reviews.length,
            replied: repliedCount,
            distribution: distribution,
          ),
          const SizedBox(height: 18),
          Text(context.tr('Client Feedback'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...reviews.map(
            (review) => _buildReviewCard(context, ref, review),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required double average,
    required int total,
    required int replied,
    required Map<int, int> distribution,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 42,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      final filled = index + 1 <= average.round();
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 17,
                        color: AppColors.gold,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('{count} reviews', params: {'count': total}),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    for (var star = 5; star >= 1; star--)
                      _ratingBar(
                        context,
                        star,
                        total == 0 ? 0 : (distribution[star] ?? 0) / total,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          Row(
            children: [
              const Icon(Icons.reply_all_rounded,
                  size: 18, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(
                context.tr('{replied} of {total} reviews replied to', params: {'replied': replied, 'total': total}),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingBar(BuildContext context, int star, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '$star',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
          const SizedBox(width: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review,
  ) {
    final reply = review.businessReply?.trim();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: review.userAvatar.isNotEmpty
                    ? NetworkImage(review.userAvatar)
                    : null,
                child: review.userAvatar.isEmpty
                    ? Text(
                        review.userName.isEmpty
                            ? '?'
                            : review.userName[0].toUpperCase(),
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
                      review.userName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      [
                        if (review.serviceName?.isNotEmpty == true)
                          review.serviceName!,
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.gold),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded,
                          size: 15, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Text(context.tr('Business reply'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const Spacer(),
                      if (review.businessReplyAt != null)
                        Text(
                          DateFormat('MMM d').format(review.businessReplyAt!),
                          style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reply,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showReplyDialog(context, ref, review),
              icon: Icon(
                reply == null || reply.isEmpty
                    ? Icons.reply_rounded
                    : Icons.edit_note_rounded,
                size: 16,
              ),
              label: Text(
                reply == null || reply.isEmpty ? 'Reply' : 'Edit Reply',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReplyDialog(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review,
  ) async {
    final controller = TextEditingController(text: review.businessReply ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Reply to {name}', params: {'name': review.userName})),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Write an official business response…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(dialogContext, text);
            },
            child: Text(context.tr('Save Reply')),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reply == null || !context.mounted) return;

    try {
      final businessId = await ref.read(currentBusinessIdProvider.future);
      if (businessId.isEmpty) throw StateError('Business ID is not available.');

      await ref.read(ownerRepositoryProvider).replyToReview(
            businessId,
            review.id,
            reply,
          );
      ref.invalidate(ownerReviewsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Reply saved successfully.')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Failed to save reply. Please try again.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
