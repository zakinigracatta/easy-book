import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/review_model.dart';
import '../models/offer_model.dart';
import '../models/gallery_image_model.dart';
import '../models/customer_profile_model.dart';
import '../models/owner_notification_model.dart';
import '../models/employee_time_off_model.dart';
import '../services/booking_service.dart';
import '../core/domain_exceptions.dart';

class OwnerBookingsPage {
  const OwnerBookingsPage({
    required this.items,
    required this.cursorStartDateTime,
    required this.cursorBookingId,
    required this.hasMore,
  });

  final List<BookingModel> items;
  final DateTime? cursorStartDateTime;
  final String? cursorBookingId;
  final bool hasMore;
}

abstract class OwnerRepository {
  Future<BusinessModel> fetchOwnerBusiness(String businessId);
  Future<void> updateOwnerBusiness(BusinessModel business);
  Future<List<BookingModel>> fetchOwnerBookings(String businessId);
  Future<OwnerBookingsPage> fetchOwnerBookingsPage(
    String businessId, {
    DateTime? afterStartDateTime,
    String? afterBookingId,
    int pageSize = 75,
  });
  Future<List<BookingModel>> fetchOwnerBookingsInRange(
    String businessId, {
    required DateTime start,
    required DateTime end,
    String? staffId,
  });
  Future<BookingModel> createWalkInBooking(BookingModel booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<List<ServiceModel>> fetchOwnerServices(String businessId);
  Future<void> saveService(ServiceModel service);
  Future<void> deleteService(String businessId, String serviceId);
  Future<List<StaffModel>> fetchOwnerEmployees(String businessId);
  Future<void> saveEmployee(StaffModel staff);
  Future<void> deleteEmployee(String businessId, String staffId);
  Future<List<EmployeeTimeOffModel>> fetchEmployeeTimeOffs(String businessId);
  Future<void> saveEmployeeTimeOff(EmployeeTimeOffModel timeOff);
  Future<List<GalleryImageModel>> fetchGalleryImages(String businessId);
  Future<void> saveGalleryImage(GalleryImageModel image);
  Future<void> deleteGalleryImage(String businessId, String imageId);
  Future<List<ReviewModel>> fetchOwnerReviews(String businessId);
  Future<void> replyToReview(
      String businessId, String reviewId, String replyText);
  Future<List<OfferModel>> fetchOwnerOffers(String businessId);
  Future<void> saveOffer(OfferModel offer);
  Future<void> deleteOffer(String businessId, String offerId);
  Future<List<CustomerProfileModel>> fetchOwnerCustomers(String businessId);
  Future<void> saveCustomerNotes(
      String businessId, String customerId, String notes);
  Future<List<OwnerNotificationModel>> fetchOwnerNotifications(
      String businessId);
  Future<void> markNotificationRead(String businessId, String notificationId);
}

class OwnerRepositoryImpl implements OwnerRepository {
  final FirebaseFirestore _firestore;
  final BookingService _bookingService;

  OwnerRepositoryImpl(
      {FirebaseFirestore? firestore, BookingService? bookingService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _bookingService =
            bookingService ?? BookingService(firestore: firestore);

  @override
  Future<BusinessModel> fetchOwnerBusiness(String businessId) async {
    if (businessId.isEmpty) {
      throw DomainException('Business ID cannot be empty.');
    }
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();
      if (!doc.exists || doc.data() == null) {
        throw DomainException('Business record not found for ID $businessId.');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return BusinessModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch business details: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> updateOwnerBusiness(BusinessModel business) async {
    if (business.id.trim().isEmpty) {
      throw DomainException('Business ID cannot be empty.');
    }

    try {
      // Only send fields that Firestore explicitly allows a business owner to
      // change. Serializing the entire model can normalize legacy protected
      // fields (owner/verification/activation/rating) and turn an innocent
      // profile edit into a permission-denied write.
      await _firestore.collection('businesses').doc(business.id).update({
        'name': business.name,
        'category': business.category,
        'address': business.address,
        'description': business.description,
        'image_url': business.imageUrl,
        'latitude': business.latitude,
        'longitude': business.longitude,
        'working_hours': business.workingHours.toJson(),
        'amenities': business.amenities,
        'phone': business.phone,
        'website': business.website,
        'gallery_urls': business.galleryUrls,
        'business_status': business.businessStatus,
        'accepting_bookings': business.acceptingBookings,
        'timeZone': business.timeZone,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to update business profile: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<BookingModel>> fetchOwnerBookings(String businessId) async {
    final page = await fetchOwnerBookingsPage(businessId);
    return page.items;
  }

  @override
  Future<OwnerBookingsPage> fetchOwnerBookingsPage(
    String businessId, {
    DateTime? afterStartDateTime,
    String? afterBookingId,
    int pageSize = 75,
  }) async {
    if (businessId.isEmpty) {
      return const OwnerBookingsPage(
        items: <BookingModel>[],
        cursorStartDateTime: null,
        cursorBookingId: null,
        hasMore: false,
      );
    }

    final safePageSize = pageSize.clamp(1, 100);
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: businessId)
          .orderBy('startDateTime', descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(safePageSize);

      final cursorId = afterBookingId?.trim() ?? '';
      if (afterStartDateTime != null && cursorId.isNotEmpty) {
        query = query.startAfter([
          Timestamp.fromDate(afterStartDateTime),
          cursorId,
        ]);
      }

      final snap = await query.get();
      final list = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return BookingModel.fromJson(m);
      }).toList(growable: false);

      final last = list.isEmpty ? null : list.last;
      return OwnerBookingsPage(
        items: list,
        cursorStartDateTime: last?.startDateTime,
        cursorBookingId: last?.id,
        hasMore: snap.docs.length == safePageSize,
      );
    } on FirebaseException catch (e) {
      throw DomainException('Failed to fetch bookings: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<BookingModel>> fetchOwnerBookingsInRange(
    String businessId, {
    required DateTime start,
    required DateTime end,
    String? staffId,
  }) async {
    if (businessId.isEmpty || !end.isAfter(start)) return [];

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: businessId);

      final normalizedStaffId = staffId?.trim() ?? '';
      if (normalizedStaffId.isNotEmpty) {
        query = query.where('staffId', isEqualTo: normalizedStaffId);
      }

      final snap = await query
          .where(
            'startDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'startDateTime',
            isLessThan: Timestamp.fromDate(end),
          )
          .orderBy('startDateTime')
          .get();

      return snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return BookingModel.fromJson(m);
      }).toList(growable: false);
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to fetch booking range: ${e.message ?? e.code}',
      );
    }
  }

  @override
  Future<BookingModel> createWalkInBooking(BookingModel booking) async {
    final walkInBooking = booking.copyWith(
      bookingSource: 'walkIn',
      status: BookingStatus.confirmed,
    );
    // Objective 1: Uses the exact same atomic transaction as customer app bookings
    return _bookingService.createBooking(walkInBooking);
  }

  @override
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    // Objective 2: Uses canonical cancellation/transition path
    await _bookingService.updateBookingStatusByOwner(
      bookingId: bookingId,
      newStatus: newStatus,
    );
  }

  @override
  Future<List<ServiceModel>> fetchOwnerServices(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('services')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return ServiceModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException('Failed to fetch services: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveService(ServiceModel service) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(service.salonId)
          .collection('services')
          .doc(service.id)
          .set(service.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to save service item: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> deleteService(String businessId, String serviceId) async {
    // Objective 22: Soft deletion (isActive = false) to preserve historical references
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('services')
          .doc(serviceId)
          .update({
            'isActive': false,
            'is_active': false,
            'isBookable': false,
            'is_bookable': false,
          });
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to deactivate service: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<StaffModel>> fetchOwnerEmployees(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('staff')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return StaffModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch staff list: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveEmployee(StaffModel staff) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(staff.businessId)
          .collection('staff')
          .doc(staff.id)
          .set(staff.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to save employee profile: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> deleteEmployee(String businessId, String staffId) async {
    // Objective 22: Soft deletion (isActive = false) to preserve historical references
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('staff')
          .doc(staffId)
          .update({'isActive': false, 'is_active': false});
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to deactivate employee: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<EmployeeTimeOffModel>> fetchEmployeeTimeOffs(
      String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('timeOffs')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return EmployeeTimeOffModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch employee time offs: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveEmployeeTimeOff(EmployeeTimeOffModel timeOff) async {
    final bizId = timeOff.businessId;
    if (bizId == null || bizId.isEmpty) {
      throw DomainException('Business ID is required for employee time off.');
    }
    if (!timeOff.endDate.isAfter(timeOff.startDate)) {
      throw DomainException('Leave end time must be after its start time.');
    }

    try {
      // Do not silently create an operational contradiction where an employee
      // is marked on leave while they still have a live appointment.
      final bookings = await fetchOwnerBookingsInRange(
        bizId,
        start: timeOff.startDate.subtract(const Duration(days: 1)),
        end: timeOff.endDate,
        staffId: timeOff.employeeId,
      );
      final conflicts = bookings.where((booking) {
        final blocksLeave = booking.status == BookingStatus.pending ||
            booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.arrived ||
            booking.status == BookingStatus.inProgress;
        if (!blocksLeave || booking.staffId != timeOff.employeeId) return false;
        return booking.startDateTime.isBefore(timeOff.endDate) &&
            booking.endDateTime.isAfter(timeOff.startDate);
      }).toList(growable: false);

      if (conflicts.isNotEmpty) {
        throw DomainException(
          'Employee leave conflicts with ${conflicts.length} existing appointment(s). '
          'Reschedule or cancel those bookings before scheduling leave.',
        );
      }

      await _firestore
          .collection('businesses')
          .doc(bizId)
          .collection('timeOffs')
          .doc(timeOff.id)
          .set(timeOff.toJson(), SetOptions(merge: true));
    } on DomainException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to save time off record: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<GalleryImageModel>> fetchGalleryImages(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('gallery')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return GalleryImageModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch gallery images: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveGalleryImage(GalleryImageModel image) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(image.businessId)
          .collection('gallery')
          .doc(image.id)
          .set(image.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to save gallery image: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> deleteGalleryImage(String businessId, String imageId) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('gallery')
          .doc(imageId)
          .delete();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to delete gallery image: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<ReviewModel>> fetchOwnerReviews(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('reviews')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return ReviewModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch customer reviews: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> replyToReview(
      String businessId, String reviewId, String replyText) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('reviews')
          .doc(reviewId)
          .update({
        'businessReply': replyText,
        'businessReplyAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to post reply to review: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<OfferModel>> fetchOwnerOffers(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('offers')
          .get();

      return snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return OfferModel.fromJson(m);
      }).toList();
    } on FirebaseException catch (e) {
      throw DomainException('Failed to fetch offers: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveOffer(OfferModel offer) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(offer.businessId)
          .collection('offers')
          .doc(offer.id)
          .set(offer.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException('Failed to save offer: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> deleteOffer(String businessId, String offerId) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('offers')
          .doc(offerId)
          .delete();
    } on FirebaseException catch (e) {
      throw DomainException('Failed to delete offer: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<CustomerProfileModel>> fetchOwnerCustomers(
      String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('customerNotes')
          .get();

      final notesMap = <String, String>{};
      for (final doc in snap.docs) {
        final note = doc.data()['notes'] as String?;
        if (note != null) notesMap[doc.id] = note;
      }

      final customerMap = <String, CustomerProfileModel>{};
      DateTime? cursorStartDateTime;
      String? cursorBookingId;
      var hasMoreBookings = true;

      while (hasMoreBookings) {
        final page = await fetchOwnerBookingsPage(
          businessId,
          afterStartDateTime: cursorStartDateTime,
          afterBookingId: cursorBookingId,
          pageSize: 100,
        );

        for (final b in page.items) {
        final rawCustomerId = b.customerId.trim();
        final phone = (b.customerPhone ?? '').trim();
        final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final customerKey = rawCustomerId.isNotEmpty
            ? rawCustomerId
            : phoneDigits.isNotEmpty
                ? 'walkin_phone_$phoneDigits'
                : 'walkin_booking_${b.id}';
        final displayName = b.customerName.trim().isNotEmpty
            ? b.customerName.trim()
            : 'Walk-in Customer';

        if (!customerMap.containsKey(customerKey)) {
          customerMap[customerKey] = CustomerProfileModel(
            id: customerKey,
            name: displayName,
            phone: phone,
            totalBookings: 1,
            completedVisits: b.status == BookingStatus.completed ? 1 : 0,
            noShowCount: b.status == BookingStatus.noShow ? 1 : 0,
            totalSpent:
                b.status == BookingStatus.completed ? b.servicePrice : 0.0,
            lastVisit:
                b.status == BookingStatus.completed ? b.startDateTime : null,
            favoriteServices: [b.serviceName],
            ownerNotes: notesMap[customerKey],
          );
        } else {
          final old = customerMap[customerKey]!;
          customerMap[customerKey] = CustomerProfileModel(
            id: old.id,
            name: old.name,
            phone: old.phone.isNotEmpty ? old.phone : phone,
            totalBookings: old.totalBookings + 1,
            completedVisits: old.completedVisits +
                (b.status == BookingStatus.completed ? 1 : 0),
            noShowCount:
                old.noShowCount + (b.status == BookingStatus.noShow ? 1 : 0),
            totalSpent: old.totalSpent +
                (b.status == BookingStatus.completed ? b.servicePrice : 0.0),
            lastVisit: b.status == BookingStatus.completed
                ? (old.lastVisit == null ||
                        b.startDateTime.isAfter(old.lastVisit!)
                    ? b.startDateTime
                    : old.lastVisit)
                : old.lastVisit,
            favoriteServices: {...old.favoriteServices, b.serviceName}.toList(),
            ownerNotes: notesMap[customerKey] ?? old.ownerNotes,
          );
        }

        hasMoreBookings = page.hasMore;
        cursorStartDateTime = page.cursorStartDateTime;
        cursorBookingId = page.cursorBookingId;
        if (page.items.isEmpty) break;
      }

      return customerMap.values.toList();
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch customers list: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> saveCustomerNotes(
      String businessId, String customerId, String notes) async {
    // Objective 8: Saved under business subcollection `businesses/{businessId}/customerNotes/{customerId}`
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('customerNotes')
          .doc(customerId)
          .set({
        'customerId': customerId,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to save customer notes: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<OwnerNotificationModel>> fetchOwnerNotifications(
      String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('notifications')
          .get();

      final list = snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return OwnerNotificationModel.fromJson(m);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to fetch notifications: ${e.message ?? e.code}');
    }
  }

  @override
  Future<void> markNotificationRead(
      String businessId, String notificationId) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to mark notification read: ${e.message ?? e.code}');
    }
  }
}
