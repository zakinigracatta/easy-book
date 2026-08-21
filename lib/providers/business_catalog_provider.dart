import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../services/booking_availability_engine.dart';
import 'app_providers.dart';

/// Shared customer-facing business catalog.
///
/// The catalog is fetched once and then reused by Home, Search and Salon List.
/// Filters are derived locally, so changing category/search no longer causes a
/// new Firestore read for the entire businesses collection.
final businessCatalogProvider = FutureProvider<List<BusinessModel>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.fetchBusinesses();
});

List<BusinessModel> filterBusinessCatalog(
  List<BusinessModel> businesses, {
  String category = 'all',
  String query = '',
}) {
  final normalizedCategory = category.trim().toLowerCase();
  final normalizedQuery = query.trim().toLowerCase();

  return businesses.where((business) {
    if (!business.isActive) return false;

    if (normalizedCategory.isNotEmpty && normalizedCategory != 'all') {
      if (!business.category.toLowerCase().contains(normalizedCategory)) {
        return false;
      }
    }

    if (normalizedQuery.isEmpty) return true;

    return business.name.toLowerCase().contains(normalizedQuery) ||
        business.address.toLowerCase().contains(normalizedQuery) ||
        business.category.toLowerCase().contains(normalizedQuery);
  }).toList(growable: false);
}

/// Category/search filtered view of the shared catalog.
final filteredBusinessCatalogProvider =
    Provider<AsyncValue<List<BusinessModel>>>((ref) {
  final catalog = ref.watch(businessCatalogProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);

  return catalog.whenData(
    (businesses) => filterBusinessCatalog(
      businesses,
      category: category,
      query: query,
    ),
  );
});

/// Search results derived in memory from the shared catalog.
final businessSearchResultsProvider =
    Provider.family<AsyncValue<List<BusinessModel>>, String>((ref, query) {
  final catalog = ref.watch(businessCatalogProvider);
  return catalog.whenData(
    (businesses) => filterBusinessCatalog(businesses, query: query),
  );
});

/// Reuses staffProvider's cached staff list during the booking flow instead of
/// issuing another Firestore staff read for eligibility filtering.
final cachedEligibleStaffProvider = FutureProvider.family<
    List<StaffModel>,
    ({
      String businessId,
      List<ServiceModel> selectedServices,
    })>((ref, arg) async {
  if (arg.businessId.trim().isEmpty) return const [];

  final allStaff = await ref.watch(staffProvider(arg.businessId).future);
  return BookingAvailabilityEngine.filterEligibleStaff(
    allStaff,
    arg.selectedServices,
  );
});
