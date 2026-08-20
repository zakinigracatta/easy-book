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
                      onPressed: () => context.push('/categories'),
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
                        'Barber',
                        Icons.content_cut_rounded,
                        AppColors.primary,
                      ),
                      _categoryChip(
                        context,
                        'Hair Salon',
                        Icons.face_rounded,
                        AppColors.accent,
                      ),
                      _categoryChip(
                        context,
                        'Spa & Relax',
                        Icons.spa_rounded,
                        AppColors.success,
                      ),
                      _categoryChip(
                        context,
                        'Nails & Beauty',
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
                      'Businesses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/salon-list'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                businessesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _errorState(
                    context,
                    error,
                    () => ref.invalidate(businessesProvider),
                  ),
                  data: (businesses) {
                    final visibleBusinesses = businesses
                        .where((business) => business.isActive)
                        .toList();

                    if (visibleBusinesses.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 42,
                                color: AppColors.textMutedDark,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No businesses are available yet.',
                                style: TextStyle(
                                  color: AppColors.textMutedDark,
                                ),
                              ),
                            ],
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

  static Widget _errorState(
    BuildContext context,
    Object error,
    VoidCallback retry,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: AppColors.textMutedDark,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load businesses.',
              style: TextStyle(color: AppColors.textMutedDark),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: retry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _categoryChip(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => context.push('/salon-list'),
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
        width: 85,
        height: 85,
        color: AppColors.glassBgDark,
        alignment: Alignment.center,
        child: const Icon(
          Icons.storefront_rounded,
          size: 32,
          color: AppColors.textMutedDark,
        ),
      );
    }

    return Image.network(
      business.imageUrl,
      width: 85,
      height: 85,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 85,
        height: 85,
        color: AppColors.glassBgDark,
        alignment: Alignment.center,
        child: const Icon(
          Icons.storefront_rounded,
          size: 32,
          color: AppColors.textMutedDark,
        ),
      ),
    );
  }
}
