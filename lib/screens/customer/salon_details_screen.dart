import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';
import '../../services/auth_guard.dart';

class SalonDetailsScreen extends StatelessWidget {
  const SalonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Executive Barber Lounge', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('VERIFIED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('142 Luxury Blvd, Downtown NYC', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        RatingStars(rating: 4.9),
                        SizedBox(width: 8),
                        Text('4.9 (328 reviews)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickBtn(context, Icons.info_outline_rounded, 'Info', () => context.push('/service-details')),
                        _quickBtn(context, Icons.badge_outlined, 'Staff', () => context.push('/staff-profile')),
                        _quickBtn(context, Icons.photo_library_outlined, 'Gallery', () => context.push('/gallery')),
                        _quickBtn(context, Icons.star_border_rounded, 'Reviews', () => context.push('/reviews')),
                        _quickBtn(context, Icons.location_on_outlined, 'Map', () => context.push('/location')),
                      ],
                    ),

                    const Divider(height: 36),
                    const Text('Services Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),

                    _serviceTile(context, 'Royal Haircut & Beard Trim', '45 mins', '\$65.00'),
                    _serviceTile(context, 'Hot Towel Shave', '30 mins', '\$45.00'),
                    _serviceTile(context, 'Deep Facial Spa Treatment', '60 mins', '\$90.00'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _serviceTile(BuildContext context, String title, String duration, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push('/service-details'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(price, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final allowed = await requireLogin(context);
                if (allowed && context.mounted) {
                  context.push('/booking-service');
                }
              },
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }
}
