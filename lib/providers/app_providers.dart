import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/available_slot.dart';
import '../models/booking_model.dart';
import '../models/business_model.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/business_repository.dart';
import '../services/auth_service.dart';
import '../services/availability_service.dart';
import '../services/booking_availability_engine.dart';

export 'auth_provider.dart';

// Services & Repositories Providers
final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider =
    Provider((ref) => AuthRepositoryImpl(ref.read(authServiceProvider)));

final businessRepositoryProvider =
    Provider<BusinessRepository>((ref) => BusinessRepositoryImpl());
final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => BookingRepositoryImpl());
final availabilityServiceProvider = Provider((ref) => AvailabilityService());
final availabilityEngineProvider =
    Provider((ref) => BookingAvailabilityEngine());

final availableSlotsProvider = FutureProvider.family<
    List<String>,
    ({
      String businessId,
      String staffId,
      int durationMinutes,
      DateTime date
    })>((ref, arg) async {
  final service = ref.watch(availabilityServiceProvider);
  return service.getAvailableSlots(
    businessId: arg.businessId,
    staffId: arg.staffId,
    durationMinutes: arg.durationMinutes,
    date: arg.date,
  );
});

// Engine Powered Available Slots Provider
final availableSlotsEngineProvider = FutureProvider.family<
    List<AvailableSlot>,
    ({
      BusinessModel business,
      List<ServiceModel> selectedServices,
      List<StaffModel> allStaff,
      String? specialistId,
      bool anySpecialist,
      DateTime date,
    })>((ref, arg) async {
  final engine = ref.watch(availabilityEngineProvider);
  List<EmployeeTimeOffModel> timeOffs = [];
  try {
    final snap = await FirebaseFirestore.instance
        .collection('businesses')
        .doc(arg.business.id)
        .collection('timeOffs')
        .get();
    timeOffs =
        snap.docs.map((d) => EmployeeTimeOffModel.fromJson(d.data())).toList();
  } catch (_) {}

  return engine.computeAvailableSlots(
    business: arg.business,
    selectedServices: arg.selectedServices,
    allStaff: arg.allStaff,
    specialistId: arg.specialistId,
    anySpecialist: arg.anySpecialist,
    date: arg.date,
    employeeTimeOffs: timeOffs,
  );
});

// Booking Flow Draft State
class BookingDraft {
  final String? businessId;
  final String? businessName;
  final String? serviceId;
  final String? serviceName;
  final double? servicePrice;
  final String? serviceDuration;
  final int? serviceDurationMinutes;
  final List<ServiceModel> selectedServices;
  final String? staffId;
  final String? staffName;
  final bool anySpecialist;
  final String? resolvedStaffId;
  final String? resolvedStaffName;
  final DateTime? date;
  final String? timeSlot;

  BookingDraft({
    this.businessId,
    this.businessName,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.serviceDuration,
    this.serviceDurationMinutes,
    this.selectedServices = const [],
    this.staffId,
    this.staffName,
    this.anySpecialist = false,
    this.resolvedStaffId,
    this.resolvedStaffName,
    this.date,
    this.timeSlot,
  });

  bool get isComplete {
    final hasServices = selectedServices.isNotEmpty ||
        (serviceId != null && serviceId!.isNotEmpty);
    final hasStaff = (staffId != null && staffId!.isNotEmpty) ||
        anySpecialist ||
        (resolvedStaffId != null && resolvedStaffId!.isNotEmpty);
    return businessId != null &&
        businessId!.isNotEmpty &&
        businessName != null &&
        businessName!.isNotEmpty &&
        hasServices &&
        hasStaff &&
        date != null &&
        timeSlot != null &&
        timeSlot!.isNotEmpty;
  }

  double get totalPrice {
    if (selectedServices.isNotEmpty) {
      return selectedServices.fold(
        0.0,
        (total, service) => total + (service.discountPrice ?? service.price),
      );
    }
    return servicePrice ?? 0.0;
  }

  int get totalDurationMinutes {
    if (selectedServices.isNotEmpty) {
      return selectedServices.fold(
        0,
        (total, service) => total + service.durationMinutes,
      );
    }
    return serviceDurationMinutes ?? 30;
  }

  int get selectedServicesCount {
    if (selectedServices.isNotEmpty) return selectedServices.length;
    return (serviceId != null && serviceId!.isNotEmpty) ? 1 : 0;
  }

  BookingDraft copyWith({
    String? businessId,
    String? businessName,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? serviceDuration,
    int? serviceDurationMinutes,
    List<ServiceModel>? selectedServices,
    String? staffId,
    String? staffName,
    bool? anySpecialist,
    String? resolvedStaffId,
    String? resolvedStaffName,
    DateTime? date,
    String? timeSlot,
  }) {
    return BookingDraft(
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      serviceDurationMinutes:
          serviceDurationMinutes ?? this.serviceDurationMinutes,
      selectedServices: selectedServices ?? this.selectedServices,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      anySpecialist: anySpecialist ?? this.anySpecialist,
      resolvedStaffId: resolvedStaffId ?? this.resolvedStaffId,
      resolvedStaffName: resolvedStaffName ?? this.resolvedStaffName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }
}

final bookingDraftProvider =
    StateProvider<BookingDraft>((ref) => BookingDraft());

// Category Filter State
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

// Businesses List Future Provider
final businessesProvider = FutureProvider<List<BusinessModel>>((ref) async {
  final repo = ref.watch(businessRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  return repo.fetchBusinesses(category: category, query: query);
});

// Single Business Detail Provider
final businessDetailProvider =
    FutureProvider.family<BusinessModel?, String>((ref, id) async {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.fetchBusinessById(id);
});

// Services Provider for a Business
final servicesProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, businessId) async {
  if (businessId.isEmpty) return [];
  final repo = ref.watch(businessRepositoryProvider);
  return repo.fetchServices(businessId);
});

// Staff Provider for a Business
final staffProvider =
    FutureProvider.family<List<StaffModel>, String>((ref, businessId) async {
  if (businessId.isEmpty) return [];
  final repo = ref.watch(businessRepositoryProvider);
  return repo.fetchStaff(businessId);
});

// Eligible Staff Filtered Provider for Selected Services
final eligibleStaffProvider = FutureProvider.family<
    List<StaffModel>,
    ({
      String businessId,
      List<ServiceModel> selectedServices
    })>((ref, arg) async {
  if (arg.businessId.isEmpty) return [];
  final repo = ref.watch(businessRepositoryProvider);
  final allStaff = await repo.fetchStaff(arg.businessId);
  return BookingAvailabilityEngine.filterEligibleStaff(
      allStaff, arg.selectedServices);
});

// Reviews Provider for a Business
final reviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, businessId) async {
  if (businessId.isEmpty) return [];
  final repo = ref.watch(businessRepositoryProvider);
  return repo.fetchReviews(businessId);
});

// Appointments State Notifier (Canonical BookingModel)
class AppointmentsNotifier
    extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final BookingRepository _repository;

  AppointmentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final list = await _repository.fetchCustomerBookings(uid);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User must be logged in to create a booking.');
    }
    final saved = await _repository.createBooking(booking);
    await loadAppointments();
    return saved;
  }

  Future<BookingModel> addAppointment({
    required String businessId,
    required String businessName,
    required String serviceName,
    required double servicePrice,
    required String staffName,
    required DateTime dateTime,
    required String serviceId,
    required String staffId,
    int durationMinutes = 45,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('User must be logged in to create a booking.');
    }
    final startDateTime = dateTime;
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    final slotLockId =
        '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';

    final booking = BookingModel(
      id: '',
      customerId: user.uid,
      customerName: user.displayName ?? user.email ?? 'Valued Customer',
      businessId: businessId,
      businessName: businessName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      staffId: staffId,
      staffName: staffName,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      status: BookingStatus.pending,
      slotLockId: slotLockId,
    );

    return createBooking(booking);
  }

  Future<void> cancelAppointment(String id) async {
    await _repository.cancelBooking(id);
    await loadAppointments();
  }

  Future<BookingModel> rescheduleAppointment({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  }) async {
    final updated = await _repository.rescheduleBooking(
      bookingId: bookingId,
      newStartDateTime: newStartDateTime,
      newEndDateTime: newEndDateTime,
    );
    await loadAppointments();
    return updated;
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AsyncValue<List<BookingModel>>>(
        (ref) {
  return AppointmentsNotifier(ref.read(bookingRepositoryProvider));
});

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Legacy in-memory favorites state. New customer UI uses savedFavoritesProvider.
final favoritesProvider = StateProvider<Set<String>>((ref) => <String>{});

// Chat State Provider
final chatMessagesProvider = StateProvider<List<ChatMessageModel>>((ref) => [
      ChatMessageModel(
        id: 'm1',
        senderId: 'b1',
        text:
            'Hello Alex! Welcome to Executive Barber Lounge. How can we assist you today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isFromCustomer: false,
      ),
      ChatMessageModel(
        id: 'm2',
        senderId: 'usr_123',
        text:
            'Hi! Do you have any open slots for a hot towel haircut tomorrow at 3 PM?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isFromCustomer: true,
      ),
      ChatMessageModel(
        id: 'm3',
        senderId: 'b1',
        text: 'Yes! Master Barber Marcus Vance has an opening at 3:30 PM.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isFromCustomer: false,
      ),
    ]);
