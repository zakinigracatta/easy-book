import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<BookingModel>> getBookings(String customerId) async {
    if (customerId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .get();

      final list =
          snap.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return list;
    } catch (_) {
      try {
        final snap = await _firestore
            .collection('bookings')
            .where('customer_id', isEqualTo: customerId)
            .get();
        final list =
            snap.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
        list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
        return list;
      } catch (e) {
        return [];
      }
    }
  }

  static List<String> generateIntervalSlotLockIds(
      String businessId, String staffId, DateTime start, DateTime end) {
    final List<String> ids = [];
    const int bucketMs = 15 * 60 * 1000;
    final int startMs = start.millisecondsSinceEpoch;
    final int endMs = end.millisecondsSinceEpoch;

    for (int t = startMs; t < endMs; t += bucketMs) {
      ids.add('${businessId}_${staffId}_$t');
    }
    if (ids.isEmpty) {
      ids.add('${businessId}_${staffId}_$startMs');
    }
    return ids;
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final primarySlotLockId =
        '${booking.businessId}_${booking.staffId}_${booking.startDateTime.millisecondsSinceEpoch}';
    final intervalLockIds = generateIntervalSlotLockIds(
      booking.businessId,
      booking.staffId,
      booking.startDateTime,
      booking.endDateTime,
    );

    debugPrint('BOOKING_CREATE_START');
    debugPrint('booking businessId: ${booking.businessId}');
    debugPrint('serviceId: ${booking.serviceId}');
    debugPrint('staffId: ${booking.staffId}');
    debugPrint('startDateTime: ${booking.startDateTime.toIso8601String()}');
    debugPrint('primarySlotLockId: $primarySlotLockId');
    debugPrint('intervalLockIds count: ${intervalLockIds.length}');

    final bookingDocRef = booking.id.isNotEmpty
        ? _firestore.collection('bookings').doc(booking.id)
        : _firestore.collection('bookings').doc();

    final now = DateTime.now();
    final toSave = BookingModel(
      id: bookingDocRef.id,
      customerId: booking.customerId,
      customerName: booking.customerName,
      businessId: booking.businessId,
      businessName: booking.businessName,
      serviceId: booking.serviceId,
      serviceName: booking.serviceName,
      servicePrice: booking.servicePrice,
      staffId: booking.staffId,
      staffName: booking.staffName,
      startDateTime: booking.startDateTime,
      endDateTime: booking.endDateTime,
      status: BookingStatus.pending,
      slotLockId: primarySlotLockId,
      createdAt: now,
      updatedAt: now,
    );

    try {
      // Atomic Transaction: Lock All 15-Minute Interval Buckets + Create Booking
      await _firestore.runTransaction((transaction) async {
        for (final lockId in intervalLockIds) {
          final slotSnap = await transaction
              .get(_firestore.collection('booking_slots').doc(lockId));
          if (slotSnap.exists) {
            throw Exception(
                'This time slot is already booked for the selected specialist. Please choose another time.');
          }
        }

        const int bucketMs = 15 * 60 * 1000;
        final startMs = booking.startDateTime.millisecondsSinceEpoch;

        for (int i = 0; i < intervalLockIds.length; i++) {
          final lockId = intervalLockIds[i];
          final currentBucketMs = startMs + (i * bucketMs);
          final currentBucketDateTime =
              DateTime.fromMillisecondsSinceEpoch(currentBucketMs);
          final slotDocRef = _firestore.collection('booking_slots').doc(lockId);

          transaction.set(slotDocRef, {
            'slotId': lockId,
            'bookingId': bookingDocRef.id,
            'businessId': booking.businessId,
            'staffId': booking.staffId,
            'startDateTime': Timestamp.fromDate(currentBucketDateTime),
            'startTimestamp': currentBucketMs,
            'customerId': booking.customerId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.set(bookingDocRef, toSave.toFirestore());
      });

      debugPrint('BOOKING_CREATE_SUCCESS: ${toSave.id}');
      return toSave;
    } catch (e, st) {
      debugPrint('BOOKING_CREATE_ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingDocRef);
        if (!bookingSnap.exists) return;

        final data = bookingSnap.data();
        if (data != null) {
          final booking = BookingModel.fromJson(data);
          final intervalLockIds = generateIntervalSlotLockIds(
            booking.businessId,
            booking.staffId,
            booking.startDateTime,
            booking.endDateTime,
          );

          for (final lockId in intervalLockIds) {
            transaction
                .delete(_firestore.collection('booking_slots').doc(lockId));
          }

          transaction.update(bookingDocRef, {
            'status': BookingStatus.cancelled.name,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  }) async {
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);

    late BookingModel updatedBooking;

    await _firestore.runTransaction((transaction) async {
      final bookingSnap = await transaction.get(bookingDocRef);
      if (!bookingSnap.exists) {
        throw Exception('Booking not found.');
      }

      final data = bookingSnap.data();
      if (data == null) {
        throw Exception('Booking data is empty.');
      }

      final existingBooking = BookingModel.fromJson(data);

      if (existingBooking.status == BookingStatus.cancelled ||
          existingBooking.status == BookingStatus.completed) {
        throw Exception(
            'Cannot reschedule a ${existingBooking.status.name} appointment.');
      }

      // Check if new time equals old time
      if (existingBooking.startDateTime.millisecondsSinceEpoch ==
              newStartDateTime.millisecondsSinceEpoch &&
          existingBooking.endDateTime.millisecondsSinceEpoch ==
              newEndDateTime.millisecondsSinceEpoch) {
        throw Exception('Please select a different date or time.');
      }

      final oldLockIds = generateIntervalSlotLockIds(
        existingBooking.businessId,
        existingBooking.staffId,
        existingBooking.startDateTime,
        existingBooking.endDateTime,
      ).toSet();

      final newLockIds = generateIntervalSlotLockIds(
        existingBooking.businessId,
        existingBooking.staffId,
        newStartDateTime,
        newEndDateTime,
      ).toSet();

      final locksToKeep = oldLockIds.intersection(newLockIds);
      final locksToDelete = oldLockIds.difference(newLockIds);
      final locksToCreate = newLockIds.difference(oldLockIds);

      // Verify that every lock in locksToCreate is available
      for (final lockId in locksToCreate) {
        final lockSnap = await transaction
            .get(_firestore.collection('booking_slots').doc(lockId));
        if (lockSnap.exists) {
          final lockData = lockSnap.data();
          if (lockData != null && lockData['bookingId'] != bookingId) {
            throw Exception(
                'That time slot was just booked by someone else. Please choose another available time.');
          }
        }
      }

      // Delete locks no longer needed
      for (final lockId in locksToDelete) {
        transaction.delete(_firestore.collection('booking_slots').doc(lockId));
      }

      // Create new required locks
      const int bucketMs = 15 * 60 * 1000;
      final startMs = newStartDateTime.millisecondsSinceEpoch;
      final newLockList = generateIntervalSlotLockIds(
        existingBooking.businessId,
        existingBooking.staffId,
        newStartDateTime,
        newEndDateTime,
      );

      for (int i = 0; i < newLockList.length; i++) {
        final lockId = newLockList[i];
        if (locksToKeep.contains(lockId)) continue;

        final currentBucketMs = startMs + (i * bucketMs);
        final currentBucketDateTime =
            DateTime.fromMillisecondsSinceEpoch(currentBucketMs);
        final slotDocRef = _firestore.collection('booking_slots').doc(lockId);

        transaction.set(slotDocRef, {
          'slotId': lockId,
          'bookingId': bookingId,
          'businessId': existingBooking.businessId,
          'staffId': existingBooking.staffId,
          'startDateTime': Timestamp.fromDate(currentBucketDateTime),
          'startTimestamp': currentBucketMs,
          'customerId': existingBooking.customerId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final newPrimarySlotLockId =
          '${existingBooking.businessId}_${existingBooking.staffId}_$startMs';
      final now = DateTime.now();

      updatedBooking = BookingModel(
        id: existingBooking.id,
        customerId: existingBooking.customerId,
        customerName: existingBooking.customerName,
        businessId: existingBooking.businessId,
        businessName: existingBooking.businessName,
        serviceId: existingBooking.serviceId,
        serviceName: existingBooking.serviceName,
        servicePrice: existingBooking.servicePrice,
        staffId: existingBooking.staffId,
        staffName: existingBooking.staffName,
        startDateTime: newStartDateTime,
        endDateTime: newEndDateTime,
        status: BookingStatus.pending,
        slotLockId: newPrimarySlotLockId,
        createdAt: existingBooking.createdAt,
        updatedAt: now,
      );

      transaction.update(bookingDocRef, {
        'startDateTime': Timestamp.fromDate(newStartDateTime),
        'endDateTime': Timestamp.fromDate(newEndDateTime),
        'startTimestamp': startMs,
        'slotLockId': newPrimarySlotLockId,
        'status': BookingStatus.pending.name,
        'updatedAt': Timestamp.fromDate(now),
      });
    });

    return updatedBooking;
  }

  static bool canTransitionBookingStatus({
    required BookingStatus from,
    required BookingStatus to,
    required String actorRole,
  }) {
    if (from == BookingStatus.cancelled || from == BookingStatus.completed) {
      return false;
    }

    if (actorRole == 'customer') {
      if (to == BookingStatus.cancelled) return true;
      return false;
    }

    if (actorRole == 'owner') {
      if (from == BookingStatus.pending && to == BookingStatus.confirmed)
        return true;
      if (from == BookingStatus.confirmed && to == BookingStatus.completed)
        return true;
      if (to == BookingStatus.cancelled) return true;
      return false;
    }

    return false;
  }

  Future<bool> confirmBooking(String bookingId) async {
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(bookingDocRef);
        if (!snap.exists) throw Exception('Booking not found.');
        final data = snap.data();
        if (data == null) throw Exception('Booking data is empty.');
        final currentStatus = data['status'] as String?;
        if (currentStatus != BookingStatus.pending.name) {
          throw Exception('Only pending bookings can be confirmed.');
        }

        transaction.update(bookingDocRef, {
          'status': BookingStatus.confirmed.name,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
      return true;
    } catch (e) {
      debugPrint('confirmBooking error: $e');
      rethrow;
    }
  }

  Future<bool> completeBooking(String bookingId) async {
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(bookingDocRef);
        if (!snap.exists) throw Exception('Booking not found.');
        final data = snap.data();
        if (data == null) throw Exception('Booking data is empty.');
        final currentStatus = data['status'] as String?;
        if (currentStatus != BookingStatus.confirmed.name) {
          throw Exception('Only confirmed bookings can be completed.');
        }

        transaction.update(bookingDocRef, {
          'status': BookingStatus.completed.name,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
      return true;
    } catch (e) {
      debugPrint('completeBooking error: $e');
      rethrow;
    }
  }
}
