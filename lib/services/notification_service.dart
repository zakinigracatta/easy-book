class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  static List<AppNotification> getMockNotifications() {
    return [
      AppNotification(
        id: 'n1',
        title: 'Booking Confirmed! 🎉',
        body: 'Your appointment at Executive Barber Lounge is set for tomorrow at 10:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n2',
        title: 'Special Offer Available',
        body: 'Get 20% off Spa Treatments this weekend at Velvet Glow Beauty Spa.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'n3',
        title: 'Wallet Top-up Successful',
        body: '\$100.00 added to your Easy Book Wallet.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
