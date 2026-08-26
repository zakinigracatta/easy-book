import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/auth_guard.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = [
      {
        'name': 'Marcus Vance',
        'title': 'Master Barber & Stylist',
        'rating': 4.9,
        'exp': '8 yrs exp',
        'img': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      },
      {
        'name': 'Elena Rostova',
        'title': 'Senior Hair Colorist',
        'rating': 5.0,
        'exp': '6 yrs exp',
        'img': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      },
      {
        'name': 'David Kim',
        'title': 'Spa Massage Therapist',
        'rating': 4.8,
        'exp': '10 yrs exp',
        'img': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      },
    ];

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
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Staff & Specialists')),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final specialist = staff[index];
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
                      backgroundImage: NetworkImage(specialist['img'] as String),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            specialist['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            context.tr(specialist['title'] as String),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingStars(rating: specialist['rating'] as double),
                              const SizedBox(width: 6),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  '${specialist['rating']} • ${context.tr(specialist['exp'] as String)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(context.tr('Select'), style: const TextStyle(fontSize: 12)),
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
