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
import '../models/working_hours_model.dart';

abstract class OwnerRepository {
  Future<BusinessModel> fetchOwnerBusiness(String businessId);
  Future<void> updateOwnerBusiness(BusinessModel business);
  Future<List<BookingModel>> fetchOwnerBookings(String businessId);
  Future<BookingModel> createWalkInBooking(BookingModel booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<List<ServiceModel>> fetchOwnerServices(String businessId);
  Future<void> saveService(ServiceModel service);
  Future<void> deleteService(String serviceId);
  Future<List<StaffModel>> fetchOwnerEmployees(String businessId);
  Future<void> saveEmployee(StaffModel staff);
  Future<void> deleteEmployee(String staffId);
  Future<List<EmployeeTimeOffModel>> fetchEmployeeTimeOffs(String businessId);
  Future<void> saveEmployeeTimeOff(EmployeeTimeOffModel timeOff);
  Future<List<GalleryImageModel>> fetchGalleryImages(String businessId);
  Future<void> saveGalleryImage(GalleryImageModel image);
  Future<void> deleteGalleryImage(String imageId);
  Future<List<ReviewModel>> fetchOwnerReviews(String businessId);
  Future<void> replyToReview(String reviewId, String replyText);
  Future<List<OfferModel>> fetchOwnerOffers(String businessId);
  Future<void> saveOffer(OfferModel offer);
  Future<void> deleteOffer(String offerId);
  Future<List<CustomerProfileModel>> fetchOwnerCustomers(String businessId);
  Future<void> saveCustomerNotes(String customerId, String notes);
  Future<List<OwnerNotificationModel>> fetchOwnerNotifications(String businessId);
  Future<void> markNotificationRead(String notificationId);
}

class OwnerRepositoryImpl implements OwnerRepository {
  final FirebaseFirestore _firestore;

  OwnerRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // In-memory persistent cache for mock state fallback during session
  static BusinessModel? _cachedBusiness;
  static final List<BookingModel> _mockBookings = [];
  static final List<ServiceModel> _mockServices = [];
  static final List<StaffModel> _mockEmployees = [];
  static final List<EmployeeTimeOffModel> _mockTimeOffs = [];
  static final List<GalleryImageModel> _mockGallery = [];
  static final List<ReviewModel> _mockReviews = [];
  static final List<OfferModel> _mockOffers = [];
  static final List<CustomerProfileModel> _mockCustomers = [];
  static final List<OwnerNotificationModel> _mockNotifications = [];

  void _initMocksIfNeeded(String businessId) {
    if (_cachedBusiness == null) {
      _cachedBusiness = BusinessModel(
        id: businessId.isEmpty ? 'b1' : businessId,
        name: 'Style Barber & Grooming Lounge',
        category: 'Barbershop & Spa Center',
        address: 'Marina Gate 2, Dubai Marina, UAE',
        rating: 4.8,
        reviewCount: 328,
        imageUrl:
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
        isVerified: true,
        description:
            'High-end grooming sanctuary providing luxury haircuts, beard sculpting, facial treatments, and premium espresso.',
        ownerId: 'owner_101',
        phone: '+971 4 399 1234',
        website: 'https://stylebarber.ae',
        galleryUrls: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
        ],
        workingHours: WorkingHoursModel.defaultSchedule(),
      );
    }

    if (_mockServices.isEmpty) {
      _mockServices.addAll([
        ServiceModel(
          id: 's1',
          salonId: businessId,
          name: 'Classic Executive Haircut',
          price: 75.0,
          discountPrice: 60.0,
          duration: '30 min',
          durationMinutes: 30,
          description: 'Precision cut, hair wash, scalp massage & styling.',
          categoryId: 'hair',
          categoryName: 'Hair Services',
          isActive: true,
        ),
        ServiceModel(
          id: 's2',
          salonId: businessId,
          name: 'Beard Sculpting & Hot Towel',
          price: 50.0,
          duration: '20 min',
          durationMinutes: 20,
          description: 'Beard trim, razor shaping, and hot steam towel.',
          categoryId: 'beard',
          categoryName: 'Beard Care',
          isActive: true,
        ),
        ServiceModel(
          id: 's3',
          salonId: businessId,
          name: 'VIP Haircut & Beard Combo',
          price: 110.0,
          discountPrice: 95.0,
          duration: '45 min',
          durationMinutes: 45,
          description: 'Full signature transformation package.',
          categoryId: 'packages',
          categoryName: 'Packages',
          isActive: true,
        ),
        ServiceModel(
          id: 's4',
          salonId: businessId,
          name: 'Deep Cleansing Charcoal Facial',
          price: 130.0,
          duration: '60 min',
          durationMinutes: 60,
          description: 'Pore extraction, blackhead clean out, hydration mask.',
          categoryId: 'facial',
          categoryName: 'Facial Spa',
          isActive: true,
        ),
      ]);
    }

    if (_mockEmployees.isEmpty) {
      _mockEmployees.addAll([
        StaffModel(
          id: 'st1',
          businessId: businessId,
          name: 'Ahmed Hassan',
          roleTitle: 'Senior Stylist & Barber',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
          rating: 4.9,
          reviewCount: 142,
          experienceYears: 7,
          isActive: true,
        ),
        StaffModel(
          id: 'st2',
          businessId: businessId,
          name: 'Marcus Vance',
          roleTitle: 'Master Specialist',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
          rating: 4.8,
          reviewCount: 95,
          experienceYears: 9,
          isActive: true,
        ),
        StaffModel(
          id: 'st3',
          businessId: businessId,
          name: 'Elena Rostova',
          roleTitle: 'Facial & Skin Therapist',
          avatarUrl:
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
          rating: 5.0,
          reviewCount: 88,
          experienceYears: 6,
          isActive: true,
        ),
      ]);
    }

    if (_mockBookings.isEmpty) {
      final now = DateTime.now();
      final todayAt10 = DateTime(now.year, now.month, now.day, 10, 30);
      final todayAt11 = DateTime(now.year, now.month, now.day, 11, 45);
      final todayAt14 = DateTime(now.year, now.month, now.day, 14, 15);
      final todayAt16 = DateTime(now.year, now.month, now.day, 16, 0);

      _mockBookings.addAll([
        BookingModel(
          id: 'bkg_101',
          customerId: 'c1',
          customerName: 'Mohammed Ali',
          customerPhone: '+971 50 123 4567',
          businessId: businessId,
          businessName: _cachedBusiness!.name,
          serviceId: 's1',
          serviceName: 'Classic Executive Haircut',
          servicePrice: 60.0,
          staffId: 'st1',
          staffName: 'Ahmed Hassan',
          startDateTime: todayAt10,
          endDateTime: todayAt10.add(const Duration(minutes: 30)),
          status: BookingStatus.confirmed,
          bookingSource: 'app',
          notes: 'Customer requested low fade side haircut.',
        ),
        BookingModel(
          id: 'bkg_102',
          customerId: 'c2',
          customerName: 'Tariq Al-Mansoor',
          customerPhone: '+971 55 987 6543',
          businessId: businessId,
          businessName: _cachedBusiness!.name,
          serviceId: 's3',
          serviceName: 'VIP Haircut & Beard Combo',
          servicePrice: 95.0,
          staffId: 'st2',
          staffName: 'Marcus Vance',
          startDateTime: todayAt11,
          endDateTime: todayAt11.add(const Duration(minutes: 45)),
          status: BookingStatus.pending,
          bookingSource: 'app',
        ),
        BookingModel(
          id: 'bkg_103',
          customerId: 'c3',
          customerName: 'David Miller',
          customerPhone: '+971 52 444 5566',
          businessId: businessId,
          businessName: _cachedBusiness!.name,
          serviceId: 's2',
          serviceName: 'Beard Sculpting & Hot Towel',
          servicePrice: 50.0,
          staffId: 'st1',
          staffName: 'Ahmed Hassan',
          startDateTime: todayAt14,
          endDateTime: todayAt14.add(const Duration(minutes: 20)),
          status: BookingStatus.arrived,
          bookingSource: 'walkIn',
          notes: 'Walk-in customer created at reception.',
        ),
        BookingModel(
          id: 'bkg_104',
          customerId: 'c4',
          customerName: 'Sami Kabbani',
          customerPhone: '+971 54 333 2211',
          businessId: businessId,
          businessName: _cachedBusiness!.name,
          serviceId: 's4',
          serviceName: 'Deep Cleansing Charcoal Facial',
          servicePrice: 130.0,
          staffId: 'st3',
          staffName: 'Elena Rostova',
          startDateTime: todayAt16,
          endDateTime: todayAt16.add(const Duration(minutes: 60)),
          status: BookingStatus.completed,
          bookingSource: 'app',
        ),
      ]);
    }

    if (_mockGallery.isEmpty) {
      _mockGallery.addAll([
        GalleryImageModel(
          id: 'img1',
          businessId: businessId,
          imageUrl:
              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
          category: 'interior',
          caption: 'Main Salon Floor & Styling Stations',
        ),
        GalleryImageModel(
          id: 'img2',
          businessId: businessId,
          imageUrl:
              'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80',
          category: 'exterior',
          caption: 'Storefront Entrance in Marina Gate',
        ),
        GalleryImageModel(
          id: 'img3',
          businessId: businessId,
          imageUrl:
              'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
          category: 'portfolio',
          caption: 'Master Cut & Beard Trim Result',
        ),
      ]);
    }

    if (_mockReviews.isEmpty) {
      _mockReviews.addAll([
        ReviewModel(
          id: 'r1',
          businessId: businessId,
          userName: 'Tariq Al-Mansoor',
          userAvatar:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
          rating: 5.0,
          comment:
              'Outstanding service! Ahmed pays close attention to detail and the place is spotless.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          serviceName: 'Classic Executive Haircut',
        ),
        ReviewModel(
          id: 'r2',
          businessId: businessId,
          userName: 'Mohammed Ali',
          userAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
          rating: 4.5,
          comment:
              'Great hot towel shave! Highly recommended salon in Dubai Marina.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          serviceName: 'Beard Sculpting & Hot Towel',
        ),
      ]);
    }

    if (_mockOffers.isEmpty) {
      _mockOffers.addAll([
        OfferModel(
          id: 'off1',
          businessId: businessId,
          title: 'Weekend Special Discount',
          description: 'Get 20% OFF on all signature combo packages.',
          discountType: DiscountType.percentage,
          discountValue: 20.0,
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
        ),
      ]);
    }

    if (_mockCustomers.isEmpty) {
      _mockCustomers.addAll([
        CustomerProfileModel(
          id: 'c1',
          name: 'Mohammed Ali',
          phone: '+971 50 123 4567',
          email: 'm.ali@example.com',
          totalBookings: 14,
          completedVisits: 12,
          noShowCount: 0,
          totalSpent: 840.0,
          lastVisit: DateTime.now().subtract(const Duration(days: 7)),
          favoriteServices: ['Classic Executive Haircut'],
          ownerNotes: 'Prefers espresso with no sugar. Likes Ahmed as specialist.',
        ),
        CustomerProfileModel(
          id: 'c2',
          name: 'Tariq Al-Mansoor',
          phone: '+971 55 987 6543',
          email: 'tariq@example.com',
          totalBookings: 8,
          completedVisits: 8,
          noShowCount: 0,
          totalSpent: 760.0,
          lastVisit: DateTime.now().subtract(const Duration(days: 14)),
          favoriteServices: ['VIP Haircut & Beard Combo'],
        ),
      ]);
    }

    if (_mockNotifications.isEmpty) {
      _mockNotifications.addAll([
        OwnerNotificationModel(
          id: 'n1',
          businessId: businessId,
          title: 'New Booking Received',
          body: 'Tariq Al-Mansoor booked VIP Haircut & Beard Combo for 11:45 AM today.',
          type: OwnerNotificationType.newBooking,
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: false,
          relatedBookingId: 'bkg_102',
        ),
        OwnerNotificationModel(
          id: 'n2',
          businessId: businessId,
          title: 'Client Arrived',
          body: 'David Miller has arrived for Beard Sculpting at 02:15 PM.',
          type: OwnerNotificationType.customerArrived,
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
          isRead: true,
          relatedBookingId: 'bkg_103',
        ),
      ]);
    }
  }

  @override
  Future<BusinessModel> fetchOwnerBusiness(String businessId) async {
    _initMocksIfNeeded(businessId);
    final targetId = businessId.isEmpty ? 'b1' : businessId;
    try {
      final doc = await _firestore.collection('businesses').doc(targetId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        _cachedBusiness = BusinessModel.fromJson(data);
        return _cachedBusiness!;
      }
    } catch (_) {}
    return _cachedBusiness!;
  }

  @override
  Future<void> updateOwnerBusiness(BusinessModel business) async {
    _cachedBusiness = business;
    try {
      await _firestore
          .collection('businesses')
          .doc(business.id)
          .set(business.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<List<BookingModel>> fetchOwnerBookings(String businessId) async {
    _initMocksIfNeeded(businessId);
    final targetId = businessId.isEmpty ? 'b1' : businessId;
    try {
      final snap = await _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: targetId)
          .get();
      if (snap.docs.isNotEmpty) {
        final list = snap.docs.map((d) {
          final m = d.data();
          m['id'] = d.id;
          return BookingModel.fromJson(m);
        }).toList();
        list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
        return list;
      }
    } catch (_) {}
    return List.from(_mockBookings);
  }

  @override
  Future<BookingModel> createWalkInBooking(BookingModel booking) async {
    _initMocksIfNeeded(booking.businessId);
    final newId = 'walkin_${DateTime.now().millisecondsSinceEpoch}';
    final saved = booking.copyWith(
      id: newId,
      bookingSource: 'walkIn',
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockBookings.insert(0, saved);

    try {
      await _firestore.collection('bookings').doc(newId).set(saved.toFirestore());
    } catch (_) {}

    return saved;
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _mockBookings[idx] = _mockBookings[idx].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<List<ServiceModel>> fetchOwnerServices(String businessId) async {
    _initMocksIfNeeded(businessId);
    final targetId = businessId.isEmpty ? 'b1' : businessId;
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(targetId)
          .collection('services')
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final m = d.data();
          m['id'] = d.id;
          return ServiceModel.fromJson(m);
        }).toList();
      }
    } catch (_) {}
    return List.from(_mockServices);
  }

  @override
  Future<void> saveService(ServiceModel service) async {
    final idx = _mockServices.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _mockServices[idx] = service;
    } else {
      _mockServices.add(service);
    }
    try {
      await _firestore
          .collection('businesses')
          .doc(service.salonId)
          .collection('services')
          .doc(service.id)
          .set(service.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> deleteService(String serviceId) async {
    _mockServices.removeWhere((s) => s.id == serviceId);
    try {
      final bId = _cachedBusiness?.id ?? 'b1';
      await _firestore
          .collection('businesses')
          .doc(bId)
          .collection('services')
          .doc(serviceId)
          .delete();
    } catch (_) {}
  }

  @override
  Future<List<StaffModel>> fetchOwnerEmployees(String businessId) async {
    _initMocksIfNeeded(businessId);
    final targetId = businessId.isEmpty ? 'b1' : businessId;
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(targetId)
          .collection('staff')
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final m = d.data();
          m['id'] = d.id;
          return StaffModel.fromJson(m);
        }).toList();
      }
    } catch (_) {}
    return List.from(_mockEmployees);
  }

  @override
  Future<void> saveEmployee(StaffModel staff) async {
    final idx = _mockEmployees.indexWhere((e) => e.id == staff.id);
    if (idx != -1) {
      _mockEmployees[idx] = staff;
    } else {
      _mockEmployees.add(staff);
    }
    try {
      await _firestore
          .collection('businesses')
          .doc(staff.businessId)
          .collection('staff')
          .doc(staff.id)
          .set(staff.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> deleteEmployee(String staffId) async {
    _mockEmployees.removeWhere((e) => e.id == staffId);
    try {
      final bId = _cachedBusiness?.id ?? 'b1';
      await _firestore
          .collection('businesses')
          .doc(bId)
          .collection('staff')
          .doc(staffId)
          .delete();
    } catch (_) {}
  }

  @override
  Future<List<EmployeeTimeOffModel>> fetchEmployeeTimeOffs(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockTimeOffs);
  }

  @override
  Future<void> saveEmployeeTimeOff(EmployeeTimeOffModel timeOff) async {
    _mockTimeOffs.add(timeOff);
  }

  @override
  Future<List<GalleryImageModel>> fetchGalleryImages(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockGallery);
  }

  @override
  Future<void> saveGalleryImage(GalleryImageModel image) async {
    _mockGallery.add(image);
  }

  @override
  Future<void> deleteGalleryImage(String imageId) async {
    _mockGallery.removeWhere((g) => g.id == imageId);
  }

  @override
  Future<List<ReviewModel>> fetchOwnerReviews(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockReviews);
  }

  @override
  Future<void> replyToReview(String reviewId, String replyText) async {
    // Reply logic store
  }

  @override
  Future<List<OfferModel>> fetchOwnerOffers(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockOffers);
  }

  @override
  Future<void> saveOffer(OfferModel offer) async {
    final idx = _mockOffers.indexWhere((o) => o.id == offer.id);
    if (idx != -1) {
      _mockOffers[idx] = offer;
    } else {
      _mockOffers.add(offer);
    }
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    _mockOffers.removeWhere((o) => o.id == offerId);
  }

  @override
  Future<List<CustomerProfileModel>> fetchOwnerCustomers(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockCustomers);
  }

  @override
  Future<void> saveCustomerNotes(String customerId, String notes) async {
    final idx = _mockCustomers.indexWhere((c) => c.id == customerId);
    if (idx != -1) {
      final old = _mockCustomers[idx];
      _mockCustomers[idx] = CustomerProfileModel(
        id: old.id,
        name: old.name,
        phone: old.phone,
        email: old.email,
        avatarUrl: old.avatarUrl,
        totalBookings: old.totalBookings,
        completedVisits: old.completedVisits,
        noShowCount: old.noShowCount,
        totalSpent: old.totalSpent,
        lastVisit: old.lastVisit,
        favoriteServices: old.favoriteServices,
        ownerNotes: notes,
      );
    }
  }

  @override
  Future<List<OwnerNotificationModel>> fetchOwnerNotifications(String businessId) async {
    _initMocksIfNeeded(businessId);
    return List.from(_mockNotifications);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    final idx = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final old = _mockNotifications[idx];
      _mockNotifications[idx] = OwnerNotificationModel(
        id: old.id,
        businessId: old.businessId,
        title: old.title,
        body: old.body,
        type: old.type,
        createdAt: old.createdAt,
        readAt: DateTime.now(),
        isRead: true,
        relatedBookingId: old.relatedBookingId,
      );
    }
  }
}
