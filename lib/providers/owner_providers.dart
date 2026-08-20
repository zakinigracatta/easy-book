import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../repositories/owner_repository.dart';

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepositoryImpl();
});

String _businessIdOrEmpty(AsyncValue<String> value) {
  return value.maybeWhen(
    data: (businessId) => businessId,
    orElse: () => '',
  );
}

// Objective 21: Real Owner Business ID Resolution
final currentBusinessIdProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.uid.isEmpty) return '';

  // New owner accounts use a deterministic business document ID equal to uid.
  // Checking it first is faster and avoids depending on a query/index.
  final directDoc = await FirebaseFirestore.instance
      .collection('businesses')
      .doc(user.uid)
      .get();
  if (directDoc.exists) {
    return directDoc.id;
  }

  // Keep compatibility with existing records that used camelCase ownerId.
  final snap = await FirebaseFirestore.instance
      .collection('businesses')
      .where('ownerId', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (snap.docs.isNotEmpty) {
    return snap.docs.first.id;
  }

  // Keep compatibility with legacy records that used snake_case owner_id.
  final snapLegacy = await FirebaseFirestore.instance
      .collection('businesses')
      .where('owner_id', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (snapLegacy.docs.isNotEmpty) {
    return snapLegacy.docs.first.id;
  }

  return '';
});

// Owner Business Notifier
class OwnerBusinessNotifier extends StateNotifier<AsyncValue<BusinessModel>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerBusinessNotifier(this._repo, this._businessId)
      : super(_businessId.isEmpty
            ? AsyncValue.error(
                StateError('No business is linked to this owner account.'),
                StackTrace.current,
              )
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadBusiness();
    }
  }

  Future<void> loadBusiness() async {
    if (_businessId.isEmpty) {
      state = AsyncValue.error(
        StateError('No business is linked to this owner account.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final biz = await _repo.fetchOwnerBusiness(_businessId);
      state = AsyncValue.data(biz);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBusiness(BusinessModel updated) async {
    state = AsyncValue.data(updated);
    await _repo.updateOwnerBusiness(updated);
  }

  Future<void> toggleAcceptingBookings(bool accepts) async {
    final current = state.maybeWhen(
      data: (business) => business,
      orElse: () => null,
    );
    if (current != null) {
      final updated = current.copyWith(acceptingBookings: accepts);
      await updateBusiness(updated);
    }
  }
}

final ownerBusinessProvider =
    StateNotifierProvider<OwnerBusinessNotifier, AsyncValue<BusinessModel>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  return OwnerBusinessNotifier(repo, bizId);
});

// Owner Bookings Notifier
class OwnerBookingsNotifier
    extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerBookingsNotifier(this._repo, this._businessId)
      : super(_businessId.isEmpty
            ? const AsyncValue.data(<BookingModel>[])
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadBookings();
    }
  }

  Future<void> loadBookings() async {
    if (_businessId.isEmpty) {
      state = const AsyncValue.data(<BookingModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchOwnerBookings(_businessId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<BookingModel> createWalkIn(BookingModel booking) async {
    final created = await _repo.createWalkInBooking(booking);
    await loadBookings();
    return created;
  }

  Future<void> updateStatus(String bookingId, BookingStatus newStatus) async {
    await _repo.updateBookingStatus(bookingId, newStatus);
    await loadBookings();
  }
}

final ownerBookingsProvider = StateNotifierProvider<OwnerBookingsNotifier,
    AsyncValue<List<BookingModel>>>((ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  return OwnerBookingsNotifier(repo, bizId);
});

// Filter & Search Providers for Owner Bookings
final ownerBookingFilterProvider = StateProvider<String>((ref) => 'All');
final ownerBookingSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredOwnerBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookingsAsync = ref.watch(ownerBookingsProvider);
  final filter = ref.watch(ownerBookingFilterProvider);
  final query = ref.watch(ownerBookingSearchQueryProvider).toLowerCase();

  return bookingsAsync.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      var result = list;

      if (filter == 'Today') {
        result = result.where((b) {
          return b.startDateTime.year == now.year &&
              b.startDateTime.month == now.month &&
              b.startDateTime.day == now.day;
        }).toList();
      } else if (filter == 'Upcoming') {
        result = result
            .where((b) =>
                b.startDateTime.isAfter(now) &&
                b.status != BookingStatus.cancelled &&
                b.status != BookingStatus.completed)
            .toList();
      } else if (filter == 'Pending') {
        result =
            result.where((b) => b.status == BookingStatus.pending).toList();
      } else if (filter == 'Completed') {
        result =
            result.where((b) => b.status == BookingStatus.completed).toList();
      } else if (filter == 'Cancelled') {
        result =
            result.where((b) => b.status == BookingStatus.cancelled).toList();
      }

      if (query.isNotEmpty) {
        result = result.where((b) {
          final cName = b.customerName.toLowerCase();
          final cPhone = (b.customerPhone ?? '').toLowerCase();
          final bId = b.id.toLowerCase();
          final sName = b.serviceName.toLowerCase();
          return cName.contains(query) ||
              cPhone.contains(query) ||
              bId.contains(query) ||
              sName.contains(query);
        }).toList();
      }

      return result;
    },
    orElse: () => [],
  );
});

// Owner Services Notifier
class OwnerServicesNotifier
    extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerServicesNotifier(this._repo, this._businessId)
      : super(_businessId.isEmpty
            ? const AsyncValue.data(<ServiceModel>[])
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadServices();
    }
  }

  Future<void> loadServices() async {
    if (_businessId.isEmpty) {
      state = const AsyncValue.data(<ServiceModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchOwnerServices(_businessId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveService(ServiceModel service) async {
    await _repo.saveService(service);
    await loadServices();
  }

  Future<void> deleteService(String serviceId) async {
    await _repo.deleteService(_businessId, serviceId);
    await loadServices();
  }

  Future<void> toggleServiceActive(ServiceModel service) async {
    final updated = ServiceModel(
      id: service.id,
      salonId: service.salonId,
      name: service.name,
      price: service.price,
      discountPrice: service.discountPrice,
      duration: service.duration,
      durationMinutes: service.durationMinutes,
      imageUrl: service.imageUrl,
      description: service.description,
      categoryId: service.categoryId,
      categoryName: service.categoryName,
      isActive: !service.isActive,
      isBookable: !service.isActive,
      currency: service.currency,
    );
    await saveService(updated);
  }
}

final ownerServicesProvider = StateNotifierProvider<OwnerServicesNotifier,
    AsyncValue<List<ServiceModel>>>((ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  return OwnerServicesNotifier(repo, bizId);
});

// Owner Employees Notifier
class OwnerEmployeesNotifier
    extends StateNotifier<AsyncValue<List<StaffModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerEmployeesNotifier(this._repo, this._businessId)
      : super(_businessId.isEmpty
            ? const AsyncValue.data(<StaffModel>[])
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadEmployees();
    }
  }

  Future<void> loadEmployees() async {
    if (_businessId.isEmpty) {
      state = const AsyncValue.data(<StaffModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchOwnerEmployees(_businessId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveEmployee(StaffModel staff) async {
    await _repo.saveEmployee(staff);
    await loadEmployees();
  }

  Future<void> deleteEmployee(String staffId) async {
    await _repo.deleteEmployee(_businessId, staffId);
    await loadEmployees();
  }
}

final ownerEmployeesProvider =
    StateNotifierProvider<OwnerEmployeesNotifier, AsyncValue<List<StaffModel>>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  return OwnerEmployeesNotifier(repo, bizId);
});

// Owner Time Offs Provider
final ownerTimeOffsProvider =
    FutureProvider<List<EmployeeTimeOffModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  if (bizId.isEmpty) return [];
  return repo.fetchEmployeeTimeOffs(bizId);
});

// Owner Gallery Notifier
class OwnerGalleryNotifier
    extends StateNotifier<AsyncValue<List<GalleryImageModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerGalleryNotifier(this._repo, this._businessId)
      : super(_businessId.isEmpty
            ? const AsyncValue.data(<GalleryImageModel>[])
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadGallery();
    }
  }

  Future<void> loadGallery() async {
    if (_businessId.isEmpty) {
      state = const AsyncValue.data(<GalleryImageModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchGalleryImages(_businessId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGalleryImage(GalleryImageModel image) async {
    await _repo.saveGalleryImage(image);
    await loadGallery();
  }

  Future<void> deleteGalleryImage(String imageId) async {
    await _repo.deleteGalleryImage(_businessId, imageId);
    await loadGallery();
  }
}

final ownerGalleryProvider = StateNotifierProvider<OwnerGalleryNotifier,
    AsyncValue<List<GalleryImageModel>>>((ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  return OwnerGalleryNotifier(repo, bizId);
});

// Owner Reviews Provider
final ownerReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerReviews(bizId);
});

// Owner Offers Provider
final ownerOffersProvider = FutureProvider<List<OfferModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerOffers(bizId);
});

// Owner Customers Provider
final ownerCustomersProvider =
    FutureProvider<List<CustomerProfileModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerCustomers(bizId);
});

// Owner Notifications Provider
final ownerNotificationsProvider =
    FutureProvider<List<OwnerNotificationModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = _businessIdOrEmpty(ref.watch(currentBusinessIdProvider));
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerNotifications(bizId);
});
