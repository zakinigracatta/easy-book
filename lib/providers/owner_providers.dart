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
import '../core/utils/business_clock.dart';
import 'auth_provider.dart';

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepositoryImpl();
});

// Objective 21: Real Owner Business ID Resolution
final currentBusinessIdProvider = FutureProvider<String>((ref) async {
  final authUser = ref.watch(authProvider);
  final uid = authUser?.id ?? '';
  if (uid.isEmpty) return '';

  // Resolve ownership through an owner-scoped query first. Reading
  // businesses/{uid} before we know it exists can be rejected by Firestore
  // rules for legacy owners whose business document uses a different ID.
  // Querying by the ownership field works for both deterministic and legacy
  // document IDs without broadening read permissions.
  final canonicalSnap = await FirebaseFirestore.instance
      .collection('businesses')
      .where('owner_id', isEqualTo: uid)
      .limit(1)
      .get();

  if (canonicalSnap.docs.isNotEmpty) {
    return canonicalSnap.docs.first.id;
  }

  // Legacy fallback is used only when canonical owner_id records are absent.
  final legacySnap = await FirebaseFirestore.instance
      .collection('businesses')
      .where('ownerId', isEqualTo: uid)
      .limit(1)
      .get();

  if (legacySnap.docs.isNotEmpty) {
    return legacySnap.docs.first.id;
  }

  return '';
});

// Owner Business Notifier
class OwnerBusinessNotifier extends StateNotifier<AsyncValue<BusinessModel>> {
  final OwnerRepository _repo;
  final String _businessId;
  final bool _resolvingBusinessId;

  OwnerBusinessNotifier(
    this._repo,
    this._businessId, {
    bool resolvingBusinessId = false,
  })  : _resolvingBusinessId = resolvingBusinessId,
        super(
          resolvingBusinessId
              ? const AsyncValue.loading()
              : _businessId.isEmpty
                  ? AsyncValue.error(
                      StateError(
                        'No business is linked to this owner account.',
                      ),
                      StackTrace.current,
                    )
                  : const AsyncValue.loading(),
        ) {
    if (!resolvingBusinessId && _businessId.isNotEmpty) {
      loadBusiness();
    }
  }

  Future<void> loadBusiness() async {
    if (_resolvingBusinessId) {
      state = const AsyncValue.loading();
      return;
    }
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
    await _repo.updateOwnerBusiness(updated);
    state = AsyncValue.data(updated);
  }

  Future<bool> toggleAcceptingBookings(bool accepts) async {
    final current = state.value;
    if (current == null) return false;

    final updated = current.copyWith(acceptingBookings: accepts);
    try {
      await updateBusiness(updated);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final ownerBusinessProvider =
    StateNotifierProvider<OwnerBusinessNotifier, AsyncValue<BusinessModel>>(
        (ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizIdAsync = ref.watch(currentBusinessIdProvider);
  final bizId = bizIdAsync.value ?? '';
  return OwnerBusinessNotifier(
    repo,
    bizId,
    resolvingBusinessId: bizIdAsync.isLoading,
  );
});

// Owner Bookings Notifier
class OwnerBookingsNotifier
    extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final OwnerRepository _repo;
  final String _businessId;
  final bool _resolvingBusinessId;

  OwnerBookingsNotifier(
    this._repo,
    this._businessId, {
    bool resolvingBusinessId = false,
  })  : _resolvingBusinessId = resolvingBusinessId,
        super(
          resolvingBusinessId
              ? const AsyncValue.loading()
              : _businessId.isEmpty
                  ? const AsyncValue.data(<BookingModel>[])
                  : const AsyncValue.loading(),
        ) {
    if (!resolvingBusinessId && _businessId.isNotEmpty) {
      loadBookings();
    }
  }

  Future<void> loadBookings() async {
    if (_resolvingBusinessId) {
      state = const AsyncValue.loading();
      return;
    }
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
  final bizIdAsync = ref.watch(currentBusinessIdProvider);
  final bizId = bizIdAsync.value ?? '';
  return OwnerBookingsNotifier(
    repo,
    bizId,
    resolvingBusinessId: bizIdAsync.isLoading,
  );
});

// Filter & Search Providers for Owner Bookings
final ownerBookingFilterProvider = StateProvider<String>((ref) => 'All');
final ownerBookingSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredOwnerBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookingsAsync = ref.watch(ownerBookingsProvider);
  final filter = ref.watch(ownerBookingFilterProvider);
  final query = ref.watch(ownerBookingSearchQueryProvider).toLowerCase();
  final timeZone =
      ref.watch(ownerBusinessProvider).value?.timeZone ?? 'Asia/Dubai';

  return bookingsAsync.maybeWhen(
    data: (list) {
      final now = BusinessClock.now(timeZone);
      var result = list;

      if (filter == 'Today') {
        result = result.where((b) {
          final localStart =
              BusinessClock.inTimeZone(b.startDateTime, timeZone);
          return localStart.year == now.year &&
              localStart.month == now.month &&
              localStart.day == now.day;
        }).toList();
      } else if (filter == 'Upcoming') {
        result = result
            .where((b) =>
                b.startDateTime.isAfter(now) &&
                b.status != BookingStatus.cancelled &&
                b.status != BookingStatus.completed &&
                b.status != BookingStatus.noShow)
            .toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
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
  final bool _resolvingBusinessId;

  OwnerServicesNotifier(
    this._repo,
    this._businessId, {
    bool resolvingBusinessId = false,
  })  : _resolvingBusinessId = resolvingBusinessId,
        super(
          resolvingBusinessId
              ? const AsyncValue.loading()
              : _businessId.isEmpty
                  ? const AsyncValue.data(<ServiceModel>[])
                  : const AsyncValue.loading(),
        ) {
    if (!resolvingBusinessId && _businessId.isNotEmpty) {
      loadServices();
    }
  }

  Future<void> loadServices() async {
    if (_resolvingBusinessId) {
      state = const AsyncValue.loading();
      return;
    }
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
    final nextAvailable = !(service.isActive && service.isBookable);
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
      isActive: nextAvailable,
      isBookable: nextAvailable,
      currency: service.currency,
    );
    await saveService(updated);
  }
}

final ownerServicesProvider = StateNotifierProvider<OwnerServicesNotifier,
    AsyncValue<List<ServiceModel>>>((ref) {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizIdAsync = ref.watch(currentBusinessIdProvider);
  final bizId = bizIdAsync.value ?? '';
  return OwnerServicesNotifier(
    repo,
    bizId,
    resolvingBusinessId: bizIdAsync.isLoading,
  );
});

// Owner Employees Notifier
class OwnerEmployeesNotifier
    extends StateNotifier<AsyncValue<List<StaffModel>>> {
  final OwnerRepository _repo;
  final String _businessId;
  final bool _resolvingBusinessId;

  OwnerEmployeesNotifier(
    this._repo,
    this._businessId, {
    bool resolvingBusinessId = false,
  })  : _resolvingBusinessId = resolvingBusinessId,
        super(
          resolvingBusinessId
              ? const AsyncValue.loading()
              : _businessId.isEmpty
                  ? const AsyncValue.data(<StaffModel>[])
                  : const AsyncValue.loading(),
        ) {
    if (!resolvingBusinessId && _businessId.isNotEmpty) {
      loadEmployees();
    }
  }

  Future<void> loadEmployees() async {
    if (_resolvingBusinessId) {
      state = const AsyncValue.loading();
      return;
    }
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
  final bizIdAsync = ref.watch(currentBusinessIdProvider);
  final bizId = bizIdAsync.value ?? '';
  return OwnerEmployeesNotifier(
    repo,
    bizId,
    resolvingBusinessId: bizIdAsync.isLoading,
  );
});

// Owner Time Offs Provider
final ownerTimeOffsProvider =
    FutureProvider<List<EmployeeTimeOffModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = await ref.watch(currentBusinessIdProvider.future);
  if (bizId.isEmpty) return [];
  return repo.fetchEmployeeTimeOffs(bizId);
});

// Owner Gallery Notifier
class OwnerGalleryNotifier
    extends StateNotifier<AsyncValue<List<GalleryImageModel>>> {
  final OwnerRepository _repo;
  final String _businessId;
  final bool _resolvingBusinessId;

  OwnerGalleryNotifier(
    this._repo,
    this._businessId, {
    bool resolvingBusinessId = false,
  })  : _resolvingBusinessId = resolvingBusinessId,
        super(
          resolvingBusinessId
              ? const AsyncValue.loading()
              : _businessId.isEmpty
                  ? const AsyncValue.data(<GalleryImageModel>[])
                  : const AsyncValue.loading(),
        ) {
    if (!resolvingBusinessId && _businessId.isNotEmpty) {
      loadGallery();
    }
  }

  Future<void> loadGallery() async {
    if (_resolvingBusinessId) {
      state = const AsyncValue.loading();
      return;
    }
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
  final bizIdAsync = ref.watch(currentBusinessIdProvider);
  final bizId = bizIdAsync.value ?? '';
  return OwnerGalleryNotifier(
    repo,
    bizId,
    resolvingBusinessId: bizIdAsync.isLoading,
  );
});

// Owner Reviews Provider
final ownerReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = await ref.watch(currentBusinessIdProvider.future);
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerReviews(bizId);
});

// Owner Offers Provider
final ownerOffersProvider = FutureProvider<List<OfferModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = await ref.watch(currentBusinessIdProvider.future);
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerOffers(bizId);
});

// Owner Customers Provider
final ownerCustomersProvider =
    FutureProvider<List<CustomerProfileModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = await ref.watch(currentBusinessIdProvider.future);
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerCustomers(bizId);
});

// Owner Notifications Provider
final ownerNotificationsProvider =
    FutureProvider<List<OwnerNotificationModel>>((ref) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final bizId = await ref.watch(currentBusinessIdProvider.future);
  if (bizId.isEmpty) return [];
  return repo.fetchOwnerNotifications(bizId);
});
