import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class SalonListScreen extends ConsumerStatefulWidget {
  SalonListScreen({super.key});

  @override
  ConsumerState<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends ConsumerState<SalonListScreen> {
  Color get _mutedColor => Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : AppColors.textMutedLight;

  @override
  void dispose() {
    ref.read(selectedCategoryProvider.notifier).state = 'all';
    ref.read(searchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final businessesAsync = ref.watch(businessesProvider);
    final title = selectedCategory == 'all'
        ? context.tr('Top Salons & Spas')
        : context.tr(
            '{category} Businesses',
            params: {'category': selectedCategory},
          );

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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(title),
        ),
        body: businessesAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _errorState(ref),
          data: (businesses) {
            if (businesses.isEmpty) return _emptyState(selectedCategory);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(businessesProvider);
                await ref.read(businessesProvider.future);
              },
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                itemCount: businesses.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _businessCard(context, businesses[index]),
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
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
          ),
          SizedBox(width: 14),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (business.isVerified)
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  business.address.isEmpty
                      ? business.category
                      : business.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: _mutedColor),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: business.rating),
                    SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${business.rating.toStringAsFixed(1)} (${business.reviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  context.tr(
                    isOpen ? 'Open for booking' : 'Currently unavailable',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOpen ? AppColors.success : _mutedColor,
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
      child: Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 34,
      ),
    );
  }

  Widget _emptyState(String selectedCategory) {
    final title = selectedCategory == 'all'
        ? context.tr('No businesses available yet')
        : context.tr(
            'No {category} businesses available',
            params: {'category': selectedCategory},
          );

    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(24),
      children: [
        SizedBox(height: 120),
        Icon(Icons.storefront_outlined, size: 56),
        SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          context.tr(
            'New businesses will appear here once they are available.',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedColor),
        ),
      ],
    );
  }

  Widget _errorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48),
            SizedBox(height: 12),
            Text(
              context.tr('Could not load businesses'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ref.invalidate(businessesProvider),
              icon: Icon(Icons.refresh_rounded),
              label: Text(context.tr('Try Again')),
            ),
          ],
        ),
      ),
    );
  }
}
