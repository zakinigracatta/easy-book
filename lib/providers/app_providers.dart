import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import '../models/appointment_model.dart';
import '../models/chat_model.dart';
import '../repositories/business_repository.dart';
import '../repositories/booking_repository.dart';
export 'auth_provider.dart';

// Services & Repositories Providers
final businessRepositoryProvider = Provider<BusinessRepository>((ref) => BusinessRepositoryImpl());
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepositoryImpl());


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
final businessDetailProvider = FutureProvider.family<BusinessModel?, String>((ref, id) async {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.fetchBusinessById(id);
});

// Appointments State Notifier
class AppointmentsNotifier extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final BookingRepository _repository;

  AppointmentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchCustomerAppointments('usr_123');
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAppointment({
    required String businessId,
    required String businessName,
    required String serviceName,
    required double servicePrice,
    required String staffName,
    required DateTime dateTime,
  }) async {
    final newApt = await _repository.createAppointment(
      customerId: 'usr_123',
      businessId: businessId,
      businessName: businessName,
      serviceName: serviceName,
      servicePrice: servicePrice,
      staffName: staffName,
      dateTime: dateTime,
    );
    state.whenData((list) {
      state = AsyncValue.data([newApt, ...list]);
    });
  }

  Future<void> cancelAppointment(String id) async {
    await _repository.cancelAppointment(id);
    await loadAppointments();
  }
}

final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, AsyncValue<List<AppointmentModel>>>((ref) {
  return AppointmentsNotifier(ref.read(bookingRepositoryProvider));
});

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Favorites State Provider
final favoritesProvider = StateProvider<Set<String>>((ref) => {'b1', 'b3'});

// Chat State Provider
final chatMessagesProvider = StateProvider<List<ChatMessageModel>>((ref) => [
  ChatMessageModel(
    id: 'm1',
    senderId: 'b1',
    text: 'Hello Alex! Welcome to Executive Barber Lounge. How can we assist you today?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    isFromCustomer: false,
  ),
  ChatMessageModel(
    id: 'm2',
    senderId: 'usr_123',
    text: 'Hi! Do you have any open slots for a hot towel haircut tomorrow at 3 PM?',
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
