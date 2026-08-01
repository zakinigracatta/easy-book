import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Downtown, NYC 📍', style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                      SizedBox(height: 2),
                      Text('Welcome Back 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Trigger
              GestureDetector(
                onTap: () => context.push('/search'),
                child: const GlassCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.textMutedDark),
                      SizedBox(width: 12),
                      Text('Search salons, spas & services...', style: TextStyle(color: AppColors.textMutedDark)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Categories Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => context.push('/categories'), child: const Text('View All')),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip(context, 'Barber', Icons.content_cut_rounded, AppColors.primary),
                    _categoryChip(context, 'Hair Salon', Icons.face_rounded, AppColors.accent),
                    _categoryChip(context, 'Spa & Relax', Icons.spa_rounded, AppColors.success),
                    _categoryChip(context, 'Nails & Beauty', Icons.brush_rounded, AppColors.gold),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Featured Salons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Businesses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => context.push('/salon-list'), child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 12),
              _salonCard(
                context,
                'Executive Barber Lounge',
                '142 Luxury Blvd • 0.4 mi',
                4.9,
                328,
                'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
              ),
              const SizedBox(height: 14),
              _salonCard(
                context,
                'Royal Spa & Wellness',
                '88 Grand Ave • 1.2 mi',
                4.8,
                210,
                'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _categoryChip(BuildContext context, String name, IconData icon, Color color) {
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
              Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _salonCard(BuildContext context, String name, String loc, double rating, int reviews, String img) {
    return GlassCard(
      onTap: () => context.push('/salon-details'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(img, width: 85, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(loc, style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: rating),
                    const SizedBox(width: 6),
                    Text('$rating ($reviews)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
