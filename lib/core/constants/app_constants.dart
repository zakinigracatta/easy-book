class AppConstants {
  static const String appName = 'Easy Book';
  static const String appTagline =
      'Luxury Booking Experience for Salon, Beauty & Wellness';

  // Categories
  static const List<Map<String, String>> categories = [
    {'id': 'all', 'name': 'All Services', 'icon': 'sparkles'},
    {'id': 'barber', 'name': 'Barbers', 'icon': 'content_cut'},
    {'id': 'hair', 'name': 'Hair Salons', 'icon': 'face'},
    {'id': 'spa', 'name': 'Spa & Massage', 'icon': 'spa'},
    {'id': 'nails', 'name': 'Nail Salons', 'icon': 'brush'},
    {'id': 'beauty', 'name': 'Beauty & Laser', 'icon': 'auto_awesome'},
    {'id': 'makeup', 'name': 'Makeup Artists', 'icon': 'palette'},
  ];

  // Storage Keys
  static const String hiveUserBox = 'userBox';
  static const String hiveFavoritesBox = 'favoritesBox';
  static const String hiveSettingsBox = 'settingsBox';

  // Time Slots
  static const List<String> defaultTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:30 PM',
    '02:00 PM',
    '03:30 PM',
    '05:00 PM',
    '06:30 PM',
    '08:00 PM'
  ];
}
