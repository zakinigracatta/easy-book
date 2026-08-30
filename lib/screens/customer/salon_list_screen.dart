import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class SalonListScreen extends StatelessWidget {
  const SalonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salons = [
      {
        'name': 'صالون إكزكيوتيف للحلاقة',
        'address': '142 شارع لاكجري',
        'rating': 4.9,
        'reviews': 328,
        'img':
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80'
      },
      {
        'name': 'رويال سبا والعافية',
        'address': '88 شارع غراند',
        'rating': 4.8,
        'reviews': 210,
        'img':
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80'
      },
      {
        'name': 'صالون إليغانس للشعر',
        'address': '45 شارع فاشن',
        'rating': 4.7,
        'reviews': 185,
        'img':
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80'
      },
    ];

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
          title: const Text('أفضل الصالونات والسبا'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: salons.length,
          itemBuilder: (context, index) {
            final s = salons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                onTap: () => context.push('/salon-details'),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(s['img'] as String,
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(s['address'] as String,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingStars(rating: s['rating'] as double),
                              const SizedBox(width: 6),
                              Text('${s['rating']} (${s['reviews']})',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
