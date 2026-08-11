import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

final currentBusinessIdProvider = StateProvider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? 'b1';
});

// Owner Business Notifier
class OwnerBusinessNotifier extends StateNotifier<AsyncValue<BusinessModel>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerBusinessNotifier(this._repo, this._businessId)
      : super(const AsyncValue.loading()) {
    loadBusiness();
  }

  Future<void> loadBusiness() async {
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
    final current = state.value;
    if (current != null) {
      final updated = BusinessModel(
        id: current.id,
        name: current.name,
        category: current.category,
        address: current.address,
        rating: current.rating,
        reviewCount: current.reviewCount,
        imageUrl: current.imageUrl,
        isVerified: current.isVerified,
        description: current.description,
        ownerId: current.ownerId,
        phone: current.phone,
        website: current.website,
        galleryUrls: current.galleryUrls,
        isActive: accepts,
        workingHours: current.workingHours,
      );
      await updateBusiness(updated);
    }
  }
}

final ownerBusinessProvider =
    StateNotifierProvider<OwnerBusinessNotifier, AsyncValue<BusinessModel>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return OwnerBusinessNotifier(repo, bizId);
});

// Owner Bookings Notifier
class OwnerBookingsNotifier
    extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerBookingsNotifier(this._repo, this._businessId)
      : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
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

final ownerBookingsProvider =
    StateNotifierProvider<OwnerBookingsNotifier, AsyncValue<List<BookingModel>>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
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

      // Status filter
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
        result = result
            .where((b) => b.status == BookingStatus.pending)
            .toList();
      } else if (filter == 'Completed') {
        result = result
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      } else if (filter == 'Cancelled') {
        result = result
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      }

      // Search query
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
      : super(const AsyncValue.loading()) {
    loadServices();
  }

  Future<void> loadServices() async {
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
    await _repo.deleteService(serviceId);
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

final ownerServicesProvider =
    StateNotifierProvider<OwnerServicesNotifier, AsyncValue<List<ServiceModel>>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return OwnerServicesNotifier(repo, bizId);
});

// Owner Employees Notifier
class OwnerEmployeesNotifier
    extends StateNotifier<AsyncValue<List<StaffModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerEmployeesNotifier(this._repo, this._businessId)
      : super(const AsyncValue.loading()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
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
    await _repo.deleteEmployee(staffId);
    await loadEmployees();
  }
}

final ownerEmployeesProvider =
    StateNotifierProvider<OwnerEmployeesNotifier, AsyncValue<List<StaffModel>>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return OwnerEmployeesNotifier(repo, bizId);
});

// Owner Time Offs Provider
final ownerTimeOffsProvider =
    FutureProvider<List<EmployeeTimeOffModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return repo.fetchEmployeeTimeOffs(bizId);
});

// Owner Gallery Notifier
class OwnerGalleryNotifier
    extends StateNotifier<AsyncValue<List<GalleryImageModel>>> {
  final OwnerRepository _repo;
  final String _businessId;

  OwnerGalleryNotifier(this._repo, this._businessId)
      : super(const AsyncValue.loading()) {
    loadGallery();
  }

  Future<void> loadGallery() async {
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
    await _repo.deleteGalleryImage(imageId);
    await loadGallery();
  }
}

final ownerGalleryProvider = StateNotifierProvider<OwnerGalleryNotifier,
    AsyncValue<List<GalleryImageModel>>>((ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return OwnerGalleryNotifier(repo, bizId);
});

// Owner Reviews Provider
final ownerReviewsProvider =
    FutureProvider<List<ReviewModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return repo.fetchOwnerReviews(bizId);
});

// Owner Offers Provider
final ownerOffersProvider = FutureProvider<List<OfferModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return repo.fetchOwnerOffers(bizId);
});

// Owner Customers Provider
final ownerCustomersProvider =
    FutureProvider<List<CustomerProfileModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return repo.fetchOwnerCustomers(bizId);
});

// Owner Notifications Provider
final ownerNotificationsProvider =
    FutureProvider<List<OwnerNotificationModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = ref.watch(currentBusinessIdProvider);
  return repo.fetchOwnerNotifications(bizId);
});
