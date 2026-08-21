import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class SalonListScreen extends ConsumerWidget {
  const SalonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final businessesAsync = ref.watch(businessesProvider);
    final title = selectedCategory == 'all'
        ? 'Top Salons & Spas'
        : '$selectedCategory Businesses';

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
          title: Text(title),
        ),
        body: businessesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _errorState(ref),
          data: (businesses) {
            if (businesses.isEmpty) {
              return _emptyState(selectedCategory);
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(businessesProvider);
                await ref.read(businessesProvider.future);
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: businesses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _businessCard(context, businesses[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _businessCard(BuildContext context, BusinessModel business) {
    final imageUrl = business.imageUrl.trim();
    final status = business.businessStatus.toLowerCase();
    final isOpen = status == 'open' && business.acceptingBookings;

    return GlassCard(
      enableBlur: false,
      onTap: () => context.push('/salon/${business.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image.network(
                    imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    cacheWidth: 256,
                    cacheHeight: 256,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (business.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  business.address.isEmpty
                      ? business.category
                      : business.address,
                  maxLines: 1,
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
                const SizedBox(height: 8),
                Text(
                  isOpen ? 'Open for booking' : 'Currently unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isOpen ? AppColors.success : AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 34,
      ),
    );
  }

  Widget _emptyState(String selectedCategory) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.storefront_outlined, size: 56),
        const SizedBox(height: 14),
        Text(
          selectedCategory == 'all'
              ? 'No businesses available yet'
              : 'No $selectedCategory businesses available',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'New businesses will appear here once they are available.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMutedDark),
        ),
      ],
    );
  }

  Widget _errorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load businesses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ref.invalidate(businessesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
