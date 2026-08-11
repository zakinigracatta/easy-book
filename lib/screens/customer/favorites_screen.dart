import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/rating_stars.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = [
      {
        'id': 'b1',
        'name': 'Executive Barber Lounge',
        'address': '142 Luxury Blvd',
        'rating': 4.9,
        'img':
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80'
      },
      {
        'id': 'b2',
        'name': 'Royal Spa & Wellness',
        'address': '88 Grand Ave',
        'rating': 4.8,
        'img':
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Favorites'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        itemCount: favs.length,
        itemBuilder: (context, index) {
          final f = favs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              onTap: () => context.push('/salon/${f['id']}'),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(f['img'] as String,
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['name'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(f['address'] as String,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        RatingStars(rating: f['rating'] as double),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite_rounded, color: Colors.red),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }
}
