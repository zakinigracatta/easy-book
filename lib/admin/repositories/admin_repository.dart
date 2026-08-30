import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../models/admin_models.dart';
import '../permissions/admin_permissions.dart';

class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> _count(Query<Map<String, dynamic>> query) async =>
      (await query.count().get()).count ?? 0;

  Future<List<AdminRecord>> listCollection(
    String collection, {
    int limit = 50,
  }) async {
    final snapshot = await _firestore.collection(collection).limit(limit).get();
    return snapshot.docs
        .map((doc) => AdminRecord(id: doc.id, data: doc.data()))
        .toList(growable: false);
  }

  Future<List<AdminRecord>> listBusinesses({
    bool? verified,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('businesses');
    if (verified != null) {
      query = query.where('is_verified', isEqualTo: verified);
    }
    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => AdminRecord(id: doc.id, data: doc.data()))
        .toList(growable: false);
  }

  Future<List<AdminRecord>> listCustomers({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AdminRecord(id: doc.id, data: doc.data()))
        .toList(growable: false);
  }

  Future<AdminBusinessDetails> businessDetails(String businessId) async {
    final reference = _firestore.collection('businesses').doc(businessId);
    final businessSnapshot = await reference.get();
    if (!businessSnapshot.exists || businessSnapshot.data() == null) {
      throw StateError('Business not found.');
    }
    final business =
        AdminRecord(id: businessSnapshot.id, data: businessSnapshot.data()!);
    final ownerId = business.text(['owner_id', 'ownerId'], fallback: '');

    // Related records enrich the page, but a missing index or a denied optional
    // collection must not hide the business document that was loaded correctly.
    Future<T?> optional<T>(Future<T> request) async {
      try {
        return await request;
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait<Object?>([
      ownerId.isEmpty
          ? Future.value(null)
          : optional(_firestore.collection('users').doc(ownerId).get()),
      optional(reference.collection('services').limit(50).get()),
      optional(reference.collection('staff').limit(50).get()),
      optional(reference.collection('reviews').limit(50).get()),
      optional(
        _firestore
            .collection('bookings')
            .where('businessId', isEqualTo: businessId)
            .limit(50)
            .get(),
      ),
      optional(
        _firestore
            .collection('bookings')
            .where('salon_id', isEqualTo: businessId)
            .limit(50)
            .get(),
      ),
    ]);

    AdminRecord? owner;
    final ownerSnapshot = results[0];
    if (ownerSnapshot is DocumentSnapshot<Map<String, dynamic>> &&
        ownerSnapshot.exists &&
        ownerSnapshot.data() != null) {
      owner = AdminRecord(id: ownerSnapshot.id, data: ownerSnapshot.data()!);
    }
    List<AdminRecord> records(Object? value) {
      if (value is! QuerySnapshot<Map<String, dynamic>>) return const [];
      final snapshot = value;
      return snapshot.docs
          .map((doc) => AdminRecord(id: doc.id, data: doc.data()))
          .toList(growable: false);
    }

    final bookingsById = <String, AdminRecord>{
      for (final record in [...records(results[4]), ...records(results[5])])
        record.id: record,
    };

    return AdminBusinessDetails(
      business: business,
      owner: owner,
      services: records(results[1]),
      staff: records(results[2]),
      reviews: records(results[3]),
      bookings: bookingsById.values.toList(growable: false),
    );
  }

  Future<AdminDashboardData> dashboard() async {
    final results = await Future.wait<Object>([
      _count(
          _firestore.collection('users').where('role', isEqualTo: 'customer')),
      _count(_firestore.collection('businesses')),
      _count(_firestore.collection('bookings')),
      listCollection('bookings', limit: 8),
      _pendingBusinesses(),
    ]);
    return AdminDashboardData(
      totalCustomers: results[0] as int,
      totalBusinesses: results[1] as int,
      totalBookings: results[2] as int,
      recentBookings: results[3] as List<AdminRecord>,
      pendingBusinesses: results[4] as List<AdminRecord>,
    );
  }

  Future<List<AdminRecord>> _pendingBusinesses() async {
    final snapshot = await _firestore
        .collection('businesses')
        .where('is_verified', isEqualTo: false)
        .limit(8)
        .get();
    return snapshot.docs
        .map((doc) => AdminRecord(id: doc.id, data: doc.data()))
        .toList(growable: false);
  }

  Future<void> setBusinessVerified({
    required UserRole actorRole,
    required String businessId,
    required bool verified,
  }) async {
    _require(actorRole, AdminPermission.manageBusinesses);
    await _firestore.collection('businesses').doc(businessId).update({
      'is_verified': verified,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserDisabled({
    required UserRole actorRole,
    required String userId,
    required bool disabled,
  }) async {
    _require(actorRole, AdminPermission.manageUsers);
    await _firestore.collection('users').doc(userId).update({
      'disabled': disabled,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  void _require(UserRole role, AdminPermission permission) {
    if (!AdminPermissions.allows(role, permission)) {
      throw StateError('Administrative permission denied.');
    }
  }
}
