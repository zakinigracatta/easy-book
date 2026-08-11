import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final int totalBookings;
  final int completedVisits;
  final int noShowCount;
  final double totalSpent;
  final DateTime? lastVisit;
  final List<String> favoriteServices;
  final String? ownerNotes;

  CustomerProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.totalBookings = 0,
    this.completedVisits = 0,
    this.noShowCount = 0,
    this.totalSpent = 0.0,
    this.lastVisit,
    this.favoriteServices = const [],
    this.ownerNotes,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d);
      return null;
    }

    List<String> parseFavs(dynamic s) {
      if (s is List) return s.map((e) => e.toString()).toList();
      return [];
    }

    return CustomerProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Valued Client',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      totalBookings:
          json['totalBookings'] as int? ?? json['total_bookings'] as int? ?? 0,
      completedVisits: json['completedVisits'] as int? ??
          json['completed_visits'] as int? ??
          0,
      noShowCount:
          json['noShowCount'] as int? ?? json['no_show_count'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ??
          (json['total_spent'] as num?)?.toDouble() ??
          0.0,
      lastVisit: parseDate(json['lastVisit'] ?? json['last_visit']),
      favoriteServices:
          parseFavs(json['favoriteServices'] ?? json['favorite_services']),
      ownerNotes:
          json['ownerNotes'] as String? ?? json['owner_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'totalBookings': totalBookings,
      'completedVisits': completedVisits,
      'noShowCount': noShowCount,
      'totalSpent': totalSpent,
      if (lastVisit != null) 'lastVisit': lastVisit!.toIso8601String(),
      'favoriteServices': favoriteServices,
      if (ownerNotes != null) 'ownerNotes': ownerNotes,
    };
  }
}
