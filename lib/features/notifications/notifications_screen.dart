import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const notifications = [
      (
        title: 'Booking Confirmed',
        body: 'Your latest appointment has been confirmed.'
      ),
      (
        title: 'Easy Book',
        body: 'Live booking updates will appear here when available.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF6C3EF4),
                child: Icon(Icons.notifications, color: Colors.white, size: 20),
              ),
              title: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notification.body),
            ),
          );
        },
      ),
    );
  }
}
