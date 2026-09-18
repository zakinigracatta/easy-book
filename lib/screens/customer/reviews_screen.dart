import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key, this.businessId});

  final String? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = businessId?.trim() ?? '';
    final reviewsState = ref.watch(reviewsProvider(id));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Customer Reviews')),
        ),
        body: id.isEmpty
            ? Center(child: Text(context.tr('Business no longer available')))
            : reviewsState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(context.tr('Unable to load reviews. Please try again.')),
                ),
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Center(child: Text(context.tr('No reviews yet')));
                  }

                  final locale =
                      Localizations.localeOf(context).toLanguageTag();
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (review.rating > 0)
                                  RatingStars(rating: review.rating),
                              ],
                            ),
                            if (review.serviceName?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                review.serviceName!.trim(),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (review.comment.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(review.comment),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              DateFormat.yMMMd(locale).format(review.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            if (review.businessReply?.trim().isNotEmpty ==
                                true) ...[
                              const Divider(height: 22),
                              Text(
                                review.businessReply!.trim(),
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
