import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(businessesProvider);
            await ref.read(businessesProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dubai, UAE 📍',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Welcome Back 👋',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/customer-profile'),
                          child: const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person_rounded),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.push('/search'),
                  child: const GlassCard(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textMutedDark,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Search salons, spas & services...',
                          style: TextStyle(color: AppColors.textMutedDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(selectedCategoryProvider.notifier).state = 'all';
                        context.push('/categories');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryChip(
                        context,
                        ref,
                        'Barber',
                        'Barber',
                        Icons.content_cut_rounded,
                        AppColors.primary,
                      ),
                      _categoryChip(
                        context,
                        ref,
                        'Hair Salon',
                        'Hair',
                        Icons.face_rounded,
                        AppColors.accent,
                      ),
                      _categoryChip(
                        context,
                        ref,
                        'Spa & Relax',
                        'Spa',
                        Icons.spa_rounded,
                        AppColors.success,
                      ),
                      _categoryChip(
                        context,
                        ref,
                        'Nails & Beauty',
                        'Beauty',
                        Icons.brush_rounded,
                        AppColors.gold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Businesses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(selectedCategoryProvider.notifier).state = 'all';
                        context.push('/salon-list');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                businessesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => _errorState(ref),
                  data: (businesses) {
                    final visibleBusinesses = businesses
                        .where((business) => business.isActive)
                        .take(3)
                        .toList();

                    if (visibleBusinesses.isEmpty) {
                      return const GlassCard(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined, size: 36),
                                SizedBox(height: 10),
                                Text(
                                  'No businesses available yet',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'New salons and services will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (var index = 0;
                            index < visibleBusinesses.length;
                            index++) ...[
                          _businessCard(context, visibleBusinesses[index]),
                          if (index != visibleBusinesses.length - 1)
                            const SizedBox(height: 14),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _categoryChip(
    BuildContext context,
    WidgetRef ref,
    String name,
    String categoryFilter,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedCategoryProvider.notifier).state = categoryFilter;
          context.push('/salon-list');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
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
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
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
                  business.address.isEmpty ? business.category : business.address,
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
                    Expanded(
                      child: Text(
                        '${business.rating.toStringAsFixed(1)} (${business.reviewCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOpen ? AppColors.success : AppColors.textMutedDark)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isOpen ? 'Open for booking' : 'Currently unavailable',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOpen ? AppColors.success : AppColors.textMutedDark,
                    ),
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
      width: 88,
      height: 88,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Icon(
        Icons.storefront_rounded,
        size: 34,
        color: AppColors.primary,
      ),
    );
  }

  Widget _errorState(WidgetRef ref) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 34),
            const SizedBox(height: 10),
            const Text(
              'Could not load businesses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
