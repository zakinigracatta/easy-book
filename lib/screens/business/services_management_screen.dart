import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../theme/app_colors.dart';

class ServicesManagementScreen extends StatelessWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Royal Haircut & Beard Sculpting', 'price': '\$65.00', 'duration': '45 mins'},
      {'name': 'Hot Towel Shave', 'price': '\$45.00', 'duration': '30 mins'},
      {'name': 'Deep Facial Spa Treatment', 'price': '\$90.00', 'duration': '60 mins'},
    ];

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
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
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Services Menu Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () => context.push('/add-service'),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s['duration']!),
                  trailing: Text(s['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 2),
      ),
    );
  }
}
