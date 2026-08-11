import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../core/domain_exceptions.dart';

class BookingService {
  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Verifies that booking start time is strictly aligned to 15-minute intervals.
  static void validateCanonical15MinAlignment(DateTime start) {
    if (start.minute % 15 != 0 || start.second != 0 || start.millisecond != 0) {
      throw InvalidBookingTimeException(
          'Booking start time must be aligned to 15-minute intervals (e.g., 10:00, 10:15, 10:30, 10:45).');
    }
  }

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
    } catch (e) {
      debugPrint('getBookings error: $e');
      throw DomainException('Failed to fetch bookings for customer.');
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

  /// Creates a booking (App or Walk-in) inside an atomic transaction with 15-minute slot locks.
  Future<BookingModel> createBooking(BookingModel booking) async {
    // 1. Enforce 15-Minute Canonical Slot Alignment
    validateCanonical15MinAlignment(booking.startDateTime);

    final bookingDocRef = booking.id.isNotEmpty
        ? _firestore.collection('bookings').doc(booking.id)
        : _firestore.collection('bookings').doc();

    final now = DateTime.now();
    final isWalkIn = booking.bookingSource == 'walkIn';

    try {
      late BookingModel toSave;

      // Atomic Transaction: Validate Authoritative Business, Service, Staff + Slot Locks + Create Booking
      await _firestore.runTransaction((transaction) async {
        // Blocker 5 & 6: Authoritative Business State Check
        final bizSnap = await transaction
            .get(_firestore.collection('businesses').doc(booking.businessId));
        if (!bizSnap.exists || bizSnap.data() == null) {
          throw BusinessClosedException('Business not found or inactive.');
        }

        final bizData = bizSnap.data()!;
        final bizModel = BusinessModel.fromJson(bizData);
        if (!bizModel.isActive ||
            !bizModel.acceptingBookings ||
            bizModel.businessStatus != 'open') {
          throw BusinessClosedException(
              'Business is currently closed or not accepting online bookings.');
        }

        // Authoritative Service Snapshot & Duration Check (Blocker 3 & 4)
        final srvSnap = await transaction.get(_firestore
            .collection('businesses')
            .doc(booking.businessId)
            .collection('services')
            .doc(booking.serviceId));

        double authoritativePrice = booking.servicePrice;
        int durationMinutes = 30;

        if (srvSnap.exists && srvSnap.data() != null) {
          final srvData = srvSnap.data()!;
          final srvModel = ServiceModel.fromJson(srvData);
          if (!srvModel.isActive) {
            throw ServiceUnavailableException(
                'Selected service is currently inactive.');
          }
          authoritativePrice = srvModel.effectivePrice;
          durationMinutes =
              srvModel.durationMinutes > 0 ? srvModel.durationMinutes : 30;
        }

        final calculatedEndDateTime =
            booking.startDateTime.add(Duration(minutes: durationMinutes));

        final primarySlotLockId =
            '${booking.businessId}_${booking.staffId}_${booking.startDateTime.millisecondsSinceEpoch}';
        final intervalLockIds = generateIntervalSlotLockIds(
          booking.businessId,
          booking.staffId,
          booking.startDateTime,
          calculatedEndDateTime,
        );

        // Check Lock Availability
        for (final lockId in intervalLockIds) {
          final slotSnap = await transaction
              .get(_firestore.collection('booking_slots').doc(lockId));
          if (slotSnap.exists) {
            throw SlotConflictException(
                'This time slot was just booked by another customer. Please choose another available time.');
          }
        }

        // Construct Authoritative Booking Document Snapshot
        toSave = BookingModel(
          id: bookingDocRef.id,
          customerId: booking.customerId,
          customerName: booking.customerName,
          customerPhone: booking.customerPhone,
          businessId: booking.businessId,
          businessName: booking.businessName,
          serviceId: booking.serviceId,
          serviceName: booking.serviceName,
          servicePrice: authoritativePrice,
          staffId: booking.staffId,
          staffName: booking.staffName,
          startDateTime: booking.startDateTime,
          endDateTime: calculatedEndDateTime,
          status: isWalkIn ? BookingStatus.confirmed : BookingStatus.pending,
          bookingSource: booking.bookingSource,
          notes: booking.notes,
          slotLockId: primarySlotLockId,
          createdAt: now,
          updatedAt: now,
        );

        // Write non-sensitive slot locks
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
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Write booking document
        transaction.set(bookingDocRef, toSave.toFirestore());
      });

      return toSave;
    } on FirebaseException catch (e) {
      debugPrint('BOOKING_CREATE_FIREBASE_ERROR: ${e.code} - ${e.message}');
      throw DomainException(
          'Booking transaction failed: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('BOOKING_CREATE_ERROR: $e');
      rethrow;
    }
  }

  /// Single canonical cancellation path for both Customer and Owner cancellations.
  Future<bool> cancelBooking({
    required String bookingId,
    required String cancelledBy,
    String? cancelReason,
  }) async {
    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingDocRef);
        if (!bookingSnap.exists) {
          throw DomainException('Booking document not found.');
        }

        final data = bookingSnap.data();
        if (data == null) throw DomainException('Booking data is empty.');

        final booking = BookingModel.fromJson(data);
        if (booking.status == BookingStatus.cancelled) {
          throw DomainException('Booking is already cancelled.');
        }

        final intervalLockIds = generateIntervalSlotLockIds(
          booking.businessId,
          booking.staffId,
          booking.startDateTime,
          booking.endDateTime,
        );

        // Delete occupied future slot locks
        for (final lockId in intervalLockIds) {
          transaction
              .delete(_firestore.collection('booking_slots').doc(lockId));
        }

        final updateData = <String, dynamic>{
          'status': BookingStatus.cancelled.name,
          'cancelledBy': cancelledBy,
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (cancelReason != null && cancelReason.isNotEmpty) {
          updateData['cancelReason'] = cancelReason;
        }

        transaction.update(bookingDocRef, updateData);
      });
      return true;
    } on FirebaseException catch (e) {
      throw DomainException('Failed to cancel booking: ${e.message ?? e.code}');
    } catch (e) {
      rethrow;
    }
  }

  /// Reschedules an existing booking to a new start/end time.
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  }) async {
    validateCanonical15MinAlignment(newStartDateTime);

    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);

    late BookingModel updatedBooking;

    try {
      await _firestore.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingDocRef);
        if (!bookingSnap.exists) {
          throw DomainException('Booking not found.');
        }

        final data = bookingSnap.data();
        if (data == null) {
          throw DomainException('Booking data is empty.');
        }

        final existingBooking = BookingModel.fromJson(data);

        if (existingBooking.status == BookingStatus.cancelled ||
            existingBooking.status == BookingStatus.completed) {
          throw DomainException(
              'Cannot reschedule a ${existingBooking.status.name} appointment.');
        }

        // Check if new time equals old time
        if (existingBooking.startDateTime.millisecondsSinceEpoch ==
                newStartDateTime.millisecondsSinceEpoch &&
            existingBooking.endDateTime.millisecondsSinceEpoch ==
                newEndDateTime.millisecondsSinceEpoch) {
          throw DomainException('Please select a different date or time.');
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
              throw SlotConflictException(
                  'That time slot was just booked by someone else. Please choose another available time.');
            }
          }
        }

        // Delete locks no longer needed
        for (final lockId in locksToDelete) {
          transaction
              .delete(_firestore.collection('booking_slots').doc(lockId));
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
          customerPhone: existingBooking.customerPhone,
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
          bookingSource: existingBooking.bookingSource,
          notes: existingBooking.notes,
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
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return updatedBooking;
    } on FirebaseException catch (e) {
      throw DomainException(
          'Reschedule transaction failed: ${e.message ?? e.code}');
    } catch (e) {
      rethrow;
    }
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
      if (from == BookingStatus.pending && to == BookingStatus.confirmed) {
        return true;
      }
      if (from == BookingStatus.confirmed && to == BookingStatus.arrived) {
        return true;
      }
      if (from == BookingStatus.arrived && to == BookingStatus.inProgress) {
        return true;
      }
      if (from == BookingStatus.inProgress && to == BookingStatus.completed) {
        return true;
      }
      if (to == BookingStatus.cancelled || to == BookingStatus.noShow) {
        return true;
      }
      return false;
    }

    return false;
  }

  Future<bool> updateBookingStatusByOwner({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    if (newStatus == BookingStatus.cancelled) {
      return cancelBooking(
        bookingId: bookingId,
        cancelledBy: 'owner',
        cancelReason: 'Cancelled by business owner',
      );
    }

    final bookingDocRef = _firestore.collection('bookings').doc(bookingId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(bookingDocRef);
        if (!snap.exists) throw DomainException('Booking not found.');

        final data = snap.data();
        if (data == null) throw DomainException('Booking data is empty.');

        final currentStatusStr = data['status'] as String? ?? 'pending';
        final currentStatus = BookingStatus.values.firstWhere(
          (e) => e.name == currentStatusStr,
          orElse: () => BookingStatus.pending,
        );

        if (!canTransitionBookingStatus(
            from: currentStatus, to: newStatus, actorRole: 'owner')) {
          throw DomainException(
              'Invalid booking status transition from ${currentStatus.name} to ${newStatus.name}.');
        }

        transaction.update(bookingDocRef, {
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } on FirebaseException catch (e) {
      throw DomainException('Failed to update status: ${e.message ?? e.code}');
    } catch (e) {
      rethrow;
    }
  }
}
