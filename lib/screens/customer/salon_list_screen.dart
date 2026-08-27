import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';
import '../../l10n/l10n.dart';

class SalonListScreen extends ConsumerWidget {
  const SalonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
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
                context.go('/home');
              }
            },
          ),
          title: Text(l10nOf(context).salonsAndSpas),
        ),
        body: businessesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 46,
                    color: AppColors.textMutedDark,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10nOf(context).businessesLoadFailedSentence,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMutedDark),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(businessesProvider),
                    child: Text(l10nOf(context).retry),
                  ),
                ],
              ),
            ),
          ),
          data: (businesses) {
            final visibleBusinesses =
                businesses.where((business) => business.isActive).toList();

            if (visibleBusinesses.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(businessesProvider);
                  await ref.read(businessesProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 120),
                    const Icon(
                      Icons.storefront_outlined,
                      size: 52,
                      color: AppColors.textMutedDark,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10nOf(context).noBusinessesAvailableYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(businessesProvider);
                await ref.read(businessesProvider.future);
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: visibleBusinesses.length,
                itemBuilder: (context, index) {
                  final business = visibleBusinesses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _businessCard(context, business),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _businessCard(
    BuildContext context,
    BusinessModel business,
  ) {
    final address = business.address.trim().isEmpty
        ? business.category
        : business.address.trim();

    return GlassCard(
      onTap: () => context.push('/salon/${business.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _businessImage(business),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: business.rating),
                    const SizedBox(width: 6),
                    Text(
                      '${business.rating.toStringAsFixed(1)} (${business.reviewCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _businessImage(BusinessModel business) {
    if (business.imageUrl.trim().isEmpty) {
      return Container(
        width: 90,
        height: 90,
        color: AppColors.glassBgDark,
        alignment: Alignment.center,
        child: const Icon(
          Icons.storefront_rounded,
          size: 34,
          color: AppColors.textMutedDark,
        ),
      );
    }

    return Image.network(
      business.imageUrl,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 90,
        height: 90,
        color: AppColors.glassBgDark,
        alignment: Alignment.center,
        child: const Icon(
          Icons.storefront_rounded,
          size: 34,
          color: AppColors.textMutedDark,
        ),
      ),
    );
  }
}
