import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'أليكس جونسون',
        'comment': 'قصة شعر وعلاج بالمنشفة الساخنة بمستوى ممتاز!',
        'rating': 5.0,
        'date': 'قبل يومين'
      },
      {
        'name': 'إيميلي ديفيس',
        'comment': 'أجواء مريحة جدًا وطاقم ودود.',
        'rating': 4.8,
        'date': 'قبل أسبوع'
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
          title: const Text('تقييمات العملاء'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final r = reviews[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r['name'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        RatingStars(rating: r['rating'] as double),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r['comment'] as String),
                    const SizedBox(height: 4),
                    Text(r['date'] as String,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
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
