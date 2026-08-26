import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Booking Confirmed!',
        'desc': 'Your haircut at Executive Barber Lounge is scheduled for tomorrow at 10 AM.',
        'time': '2 hours ago',
      },
      {
        'title': 'Earned 150 Loyalty Points',
        'desc': 'Thank you for reviewing Royal Spa & Wellness.',
        'time': '1 day ago',
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Notifications')),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    context.tr(notification['title']!),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(context.tr(notification['desc']!)),
                      SizedBox(height: 4),
                      Text(
                        context.tr(notification['time']!),
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
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
