import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/business_model.dart';
import '../../models/service_model.dart';
import '../../models/staff_model.dart';
import '../../models/review_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_guard.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';

import 'widgets/business_hero.dart';
import 'widgets/business_summary.dart';
import 'widgets/business_quick_actions.dart';
import 'widgets/business_nav_tabs.dart';
import 'widgets/service_category_section.dart';
import 'widgets/specialist_card.dart';
import 'widgets/reviews_section.dart';
import 'widgets/about_section.dart';
import 'widgets/gallery_section.dart';
import 'widgets/booking_bottom_bar.dart';
import 'widgets/salon_details_shimmer.dart';

class SalonDetailsScreen extends ConsumerStatefulWidget {
  final String? businessId;

  const SalonDetailsScreen({super.key, this.businessId});

  @override
  ConsumerState<SalonDetailsScreen> createState() => _SalonDetailsScreenState();
}

class _SalonDetailsScreenState extends ConsumerState<SalonDetailsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _selectedServiceIds = [];

  @override
  Widget build(BuildContext context) {
    final extraId = GoRouterState.of(context).extra as String?;
    final effectiveId =
        (widget.businessId != null && widget.businessId!.isNotEmpty)
            ? widget.businessId!
            : (extraId != null && extraId.isNotEmpty ? extraId : 'b1');

    final businessState = ref.watch(businessDetailProvider(effectiveId));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: businessState.when(
          loading: () => const SalonDetailsShimmer(),
          error: (err, stack) =>
              _buildErrorView(context, ref, effectiveId, err),
          data: (business) {
            if (business == null) {
              return _buildNotFoundView(context);
            }

            final servicesState = ref.watch(servicesProvider(business.id));
            final staffState = ref.watch(staffProvider(business.id));
            final reviewsState = ref.watch(reviewsProvider(business.id));

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Cover Header
                        BusinessHero(business: business),

                        // Inactive Business Banner
                        if (!business.isActive)
                          Container(
                            width: double.infinity,
                            color: AppColors.error.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10nOf(context).inactiveSalonNotice,
                                    style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 2. Business Summary & Actions
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BusinessSummary(
                                  business: business,
                                  distanceText: l10nOf(context)
                                      .distanceKilometers('1.8')),
                              const SizedBox(height: 20),
                              const Divider(
                                  color: AppColors.glassBorderDark, height: 1),
                              const SizedBox(height: 16),
                              BusinessQuickActions(business: business),
                              const SizedBox(height: 20),

                              // 3. Navigation Tabs (Services, Specialists, Reviews, About)
                              BusinessNavTabs(
                                selectedIndex: _selectedTabIndex,
                                onTabSelected: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // 4. Tab Body Contents
                              _buildTabContent(
                                business,
                                servicesState,
                                staffState,
                                reviewsState,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Persistent Bottom Booking Bar
                BookingBottomBar(
                  business: business,
                  onBookNowTap: () async {
                    final servicesList = servicesState.value ?? [];
                    List<ServiceModel> selectedList = [];

                    if (_selectedServiceIds.isNotEmpty) {
                      selectedList = servicesList
                          .where((s) => _selectedServiceIds.contains(s.id))
                          .toList();
                    }

                    // Update draft state
                    final currentDraft = ref.read(bookingDraftProvider);
                    if (selectedList.isNotEmpty) {
                      final first = selectedList.first;
                      ref.read(bookingDraftProvider.notifier).state =
                          currentDraft.copyWith(
                        businessId: business.id,
                        businessName: business.name,
                        serviceId: first.id,
                        serviceName: first.name,
                        servicePrice: first.discountPrice ?? first.price,
                        serviceDuration: first.duration,
                        serviceDurationMinutes: first.durationMinutes,
                        selectedServices: selectedList,
                      );
                    } else {
                      ref.read(bookingDraftProvider.notifier).state =
                          currentDraft.copyWith(
                        businessId: business.id,
                        businessName: business.name,
                      );
                    }

                    // Check Auth requirement
                    final allowed = await requireLogin(context,
                        targetRoute: '/booking-service');
                    if (allowed && context.mounted) {
                      context.push('/booking-service');
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BusinessModel business,
    AsyncValue<List<ServiceModel>> servicesState,
    AsyncValue<List<StaffModel>> staffState,
    AsyncValue<List<ReviewModel>> reviewsState,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        // Services Tab
        return servicesState.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator())),
          error: (err, stack) => Text(l10nOf(context).servicesLoadError('$err'),
              style: const TextStyle(color: AppColors.error)),
          data: (services) => ServiceCategorySection(
            services: services,
            selectedServiceIds: _selectedServiceIds,
            onServiceSelect: (service) {
              setState(() {
                if (_selectedServiceIds.contains(service.id)) {
                  _selectedServiceIds.remove(service.id);
                } else {
                  _selectedServiceIds.add(service.id);
                }
              });

              // Update draft immediately
              final selectedList = services
                  .where((s) => _selectedServiceIds.contains(s.id))
                  .toList();
              final currentDraft = ref.read(bookingDraftProvider);
              if (selectedList.isNotEmpty) {
                final first = selectedList.first;
                ref.read(bookingDraftProvider.notifier).state =
                    currentDraft.copyWith(
                  businessId: business.id,
                  businessName: business.name,
                  serviceId: first.id,
                  serviceName: first.name,
                  servicePrice: first.discountPrice ?? first.price,
                  serviceDuration: first.duration,
                  serviceDurationMinutes: first.durationMinutes,
                  selectedServices: selectedList,
                );
              } else {
                ref.read(bookingDraftProvider.notifier).state =
                    currentDraft.copyWith(
                  businessId: business.id,
                  businessName: business.name,
                  selectedServices: [],
                  serviceId: '',
                  serviceName: '',
                );
              }
            },
          ),
        );

      case 1:
        // Specialists Tab
        return staffState.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator())),
          error: (err, stack) => Text(
              l10nOf(context).specialistsLoadError('$err'),
              style: const TextStyle(color: AppColors.error)),
          data: (staffList) {
            if (staffList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 48, color: AppColors.textMutedDark),
                    const SizedBox(height: 12),
                    Text(
                      l10nOf(context).staffInformationUnavailable,
                      style: const TextStyle(
                          color: AppColors.textMutedDark, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: staffList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return SpecialistCard(
                  staff: staff,
                  onTap: () => context.push('/staff-profile'),
                );
              },
            );
          },
        );

      case 2:
        // Reviews Tab
        return reviewsState.when(
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator())),
          error: (err, stack) => Text(l10nOf(context).errorWithDetails('$err'),
              style: const TextStyle(color: AppColors.error)),
          data: (reviewsList) => ReviewsSection(
            averageRating: business.rating,
            totalReviews: business.reviewCount,
            reviews: reviewsList,
          ),
        );

      case 3:
        // About & Gallery Tab
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GallerySection(galleryUrls: business.galleryUrls),
            AboutSection(business: business),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorView(
      BuildContext context, WidgetRef ref, String businessId, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              l10nOf(context).salonDataLoadFailed,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              l10nOf(context).checkConnection,
              style:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(businessDetailProvider(businessId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10nOf(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront_outlined,
                size: 56, color: AppColors.textMutedDark),
            const SizedBox(height: 16),
            Text(
              l10nOf(context).salonNotFound,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              l10nOf(context).requestedBusinessUnavailable,
              style:
                  const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              child: Text(l10nOf(context).back),
            ),
          ],
        ),
      ),
    );
  }
}
