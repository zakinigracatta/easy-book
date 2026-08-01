import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      {'title': 'Booking Confirmed!', 'desc': 'Your haircut at Executive Barber Lounge is scheduled for tomorrow at 10 AM.', 'time': '2 hours ago'},
      {'title': 'Earned 150 Loyalty Points', 'desc': 'Thank you for reviewing Royal Spa & Wellness.', 'time': '1 day ago'},
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
          title: const Text('Notifications'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: notifs.length,
          itemBuilder: (context, index) {
            final n = notifs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  ),
                  title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n['desc']!),
                      const SizedBox(height: 4),
                      Text(n['time']!, style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
