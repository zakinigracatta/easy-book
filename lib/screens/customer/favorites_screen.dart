import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final favoritesAsync = ref.watch(savedFavoritesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Saved Favorites'))),
      body: user == null
          ? _signedOutState(context)
          : favoritesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _errorState(context, ref),
              data: (favoriteIds) {
                if (favoriteIds.isEmpty) return _emptyState(context);

                final ids = favoriteIds.toList()..sort();
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(savedFavoritesProvider);
                    await ref.read(savedFavoritesProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
                    itemCount: ids.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final businessId = ids[index];
                      final businessAsync = ref.watch(businessDetailProvider(businessId));

                      return businessAsync.when(
                        loading: () => const GlassCard(
                          child: SizedBox(
                            height: 84,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                        error: (error, stackTrace) => GlassCard(
                          child: ListTile(
                            leading: const Icon(Icons.storefront_outlined),
                            title: Text(context.tr('Could not load this business')),
                            trailing: IconButton(
                              tooltip: context.tr('Retry'),
                              icon: const Icon(Icons.refresh_rounded),
                              onPressed: () => ref.invalidate(businessDetailProvider(businessId)),
                            ),
                          ),
                        ),
                        data: (business) {
                          if (business == null) {
                            return GlassCard(
                              child: ListTile(
                                leading: const Icon(Icons.storefront_outlined),
                                title: Text(context.tr('Business no longer available')),
                                trailing: IconButton(
                                  tooltip: context.tr('Remove from favorites'),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  onPressed: () => _removeFavorite(
                                    context,
                                    ref,
                                    user.id,
                                    businessId,
                                  ),
                                ),
                              ),
                            );
                          }

                          return _businessCard(context, ref, user.id, business);
                        },
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }

  Widget _businessCard(
    BuildContext context,
    WidgetRef ref,
    String userId,
    BusinessModel business,
  ) {
    final imageUrl = business.imageUrl.trim();

    return GlassCard(
      onTap: () => context.push('/salon/${business.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  business.address.isEmpty ? business.category : business.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingStars(rating: business.rating),
                    const SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        business.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('Remove from favorites'),
            icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
            onPressed: () => _removeFavorite(context, ref, userId, business.id),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavorite(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String businessId,
  ) async {
    try {
      await ref.read(favoritesRepositoryProvider).setFavorite(
            userId: userId,
            businessId: businessId,
            isFavorite: false,
          );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Could not update favorites. Please try again.'))),
      );
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 32),
    );
  }

  Widget _signedOutState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 56),
            const SizedBox(height: 16),
            Text(
              context.tr('Sign in to save favorites'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Your favorite salons and businesses will stay synced with your account.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMutedDark),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: Text(context.tr('Sign In')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.favorite_border_rounded, size: 56),
        const SizedBox(height: 16),
        Text(
          context.tr('No favorites yet'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('Tap the heart on a business to save it here.'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMutedDark),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: Text(context.tr('Explore Businesses')),
          ),
        ),
      ],
    );
  }

  Widget _errorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              context.tr('Could not load favorites'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ref.invalidate(savedFavoritesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('Try Again')),
            ),
          ],
        ),
      ),
    );
  }
}
