import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';
import '../../services/auth_guard.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = [
      {
        'name': 'ماركوس فانس',
        'title': 'حلاق ومصفف محترف',
        'rating': 4.9,
        'exp': 'خبرة 8 سنوات',
        'img':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80'
      },
      {
        'name': 'إيلينا روستوفا',
        'title': 'مختصة ألوان شعر أولى',
        'rating': 5.0,
        'exp': 'خبرة 6 سنوات',
        'img':
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80'
      },
      {
        'name': 'ديفيد كيم',
        'title': 'معالج مساج وسبا',
        'rating': 4.8,
        'exp': 'خبرة 10 سنوات',
        'img':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80'
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
          title: const Text('الموظفون والمختصون'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final s = staff[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                onTap: () async {
                  final allowed = await requireLogin(context);
                  if (allowed && context.mounted) {
                    context.push('/booking-service');
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(s['img'] as String),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(s['title'] as String,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingStars(rating: s['rating'] as double),
                              const SizedBox(width: 6),
                              Text('${s['rating']} • ${s['exp']}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final allowed = await requireLogin(context);
                        if (allowed && context.mounted) {
                          context.push('/booking-service');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8)),
                      child:
                          const Text('اختيار', style: TextStyle(fontSize: 12)),
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
