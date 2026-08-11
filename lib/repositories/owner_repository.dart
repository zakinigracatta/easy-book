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

abstract class OwnerRepository {
  Future<BusinessModel> fetchOwnerBusiness(String businessId);
  Future<void> updateOwnerBusiness(BusinessModel business);
  Future<List<BookingModel>> fetchOwnerBookings(String businessId);
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
    try {
      await _firestore
          .collection('businesses')
          .doc(business.id)
          .set(business.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw DomainException(
          'Failed to update business profile: ${e.message ?? e.code}');
    }
  }

  @override
  Future<List<BookingModel>> fetchOwnerBookings(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: businessId)
          .get();

      final list = snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return BookingModel.fromJson(m);
      }).toList();
      list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return list;
    } on FirebaseException catch (e) {
      throw DomainException('Failed to fetch bookings: ${e.message ?? e.code}');
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
          .update({'isActive': false, 'is_active': false});
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
    try {
      await _firestore
          .collection('businesses')
          .doc(bizId)
          .collection('timeOffs')
          .doc(timeOff.id)
          .set(timeOff.toJson(), SetOptions(merge: true));
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

      final bookings = await fetchOwnerBookings(businessId);
      final customerMap = <String, CustomerProfileModel>{};

      for (final b in bookings) {
        if (!customerMap.containsKey(b.customerId)) {
          customerMap[b.customerId] = CustomerProfileModel(
            id: b.customerId,
            name: b.customerName,
            phone: b.customerPhone ?? '',
            totalBookings: 1,
            completedVisits: b.status == BookingStatus.completed ? 1 : 0,
            noShowCount: b.status == BookingStatus.noShow ? 1 : 0,
            totalSpent:
                b.status == BookingStatus.completed ? b.servicePrice : 0.0,
            lastVisit: b.startDateTime,
            favoriteServices: [b.serviceName],
            ownerNotes: notesMap[b.customerId],
          );
        } else {
          final old = customerMap[b.customerId]!;
          customerMap[b.customerId] = CustomerProfileModel(
            id: old.id,
            name: old.name,
            phone: old.phone.isNotEmpty ? old.phone : (b.customerPhone ?? ''),
            totalBookings: old.totalBookings + 1,
            completedVisits: old.completedVisits +
                (b.status == BookingStatus.completed ? 1 : 0),
            noShowCount:
                old.noShowCount + (b.status == BookingStatus.noShow ? 1 : 0),
            totalSpent: old.totalSpent +
                (b.status == BookingStatus.completed ? b.servicePrice : 0.0),
            lastVisit: (old.lastVisit != null &&
                    b.startDateTime.isAfter(old.lastVisit!))
                ? b.startDateTime
                : (old.lastVisit ?? b.startDateTime),
            favoriteServices: {...old.favoriteServices, b.serviceName}.toList(),
            ownerNotes: notesMap[b.customerId] ?? old.ownerNotes,
          );
        }
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
