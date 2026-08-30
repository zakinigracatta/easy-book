import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_models.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider =
    Provider<AdminRepository>((ref) => AdminRepository());

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) {
  return ref.watch(adminRepositoryProvider).dashboard();
});

final adminCollectionProvider =
    FutureProvider.family<List<AdminRecord>, String>((ref, collection) {
  return ref.watch(adminRepositoryProvider).listCollection(collection);
});

final adminBusinessesProvider =
    FutureProvider.family<List<AdminRecord>, bool?>((ref, verified) {
  return ref.watch(adminRepositoryProvider).listBusinesses(verified: verified);
});

final adminCustomersProvider = FutureProvider<List<AdminRecord>>((ref) {
  return ref.watch(adminRepositoryProvider).listCustomers();
});

final adminBusinessDetailsProvider =
    FutureProvider.family<AdminBusinessDetails, String>((ref, id) {
  return ref.watch(adminRepositoryProvider).businessDetails(id);
});
