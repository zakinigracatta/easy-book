import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRecord {
  const AdminRecord({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;

  String text(List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  DateTime? date(List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  num number(List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value;
    }
    return 0;
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.totalCustomers,
    required this.totalBusinesses,
    required this.totalBookings,
    required this.recentBookings,
    required this.pendingBusinesses,
  });
  final int totalCustomers;
  final int totalBusinesses;
  final int totalBookings;
  final List<AdminRecord> recentBookings;
  final List<AdminRecord> pendingBusinesses;
}

class AdminBusinessDetails {
  const AdminBusinessDetails({
    required this.business,
    required this.owner,
    required this.services,
    required this.staff,
    required this.reviews,
    required this.bookings,
  });

  final AdminRecord business;
  final AdminRecord? owner;
  final List<AdminRecord> services;
  final List<AdminRecord> staff;
  final List<AdminRecord> reviews;
  final List<AdminRecord> bookings;
}
