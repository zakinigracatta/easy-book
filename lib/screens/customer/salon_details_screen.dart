import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_model.dart';
import '../../models/service_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_guard.dart';
import '../../theme/app_colors.dart';
import 'widgets/about_section.dart';
import 'widgets/booking_bottom_bar.dart';
import 'widgets/business_hero.dart';
import 'widgets/business_nav_tabs.dart';
import 'widgets/business_quick_actions.dart';
import 'widgets/business_summary.dart';
import 'widgets/gallery_section.dart';
import 'widgets/reviews_section.dart';
import 'widgets/salon_details_shimmer.dart';
import 'widgets/service_category_section.dart';
import 'widgets/specialist_card.dart';

class SalonDetailsScreen extends ConsumerStatefulWidget {
  final String? businessId;

  const SalonDetailsScreen({super.key, this.businessId});

  @override
  ConsumerState<SalonDetailsScreen> createState() => _SalonDetailsScreenState();
}

class _SalonDetailsScreenState extends ConsumerState<SalonDetailsScreen> {
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  final List<String> _selectedServiceIds = [];

  Color get _mutedColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.textMutedDark
      : AppColors.textMutedLight;

  Color get _dividerColor => Theme.of(context).brightness == Brightness.dark
      ? AppColors.glassBorderDark
      : AppColors.glassBorderLight;

  @override
  void dispose() {
    _selectedTabIndex.dispose();
    super.dispose();
  }

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
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        body: businessState.when(
          loading: () => const SalonDetailsShimmer(),
          error: (err, stack) =>
              _buildErrorView(context, ref, effectiveId, err),
          data: (business) {
            if (business == null) return _buildNotFoundView(context);

            final servicesState = ref.watch(servicesProvider(business.id));
            final canBook = business.isActive &&
                business.acceptingBookings &&
                business.businessStatus == 'open';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BusinessHero(business: business),
                        if (!canBook)
                          Container(
                            width: double.infinity,
                            color: AppColors.error.withValues(alpha: 0.12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.tr(
                                      'This salon is currently inactive or not accepting online bookings.',
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BusinessSummary(
                                business: business,
                                distanceText: context.tr('1.8 km away'),
                              ),
                              const SizedBox(height: 20),
                              Divider(color: _dividerColor, height: 1),
                              const SizedBox(height: 16),
                              BusinessQuickActions(business: business),
                              const SizedBox(height: 20),
                              ValueListenableBuilder<int>(
                                valueListenable: _selectedTabIndex,
                                builder: (context, selectedTabIndex, _) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BusinessNavTabs(
                                        selectedIndex: selectedTabIndex,
                                        onTabSelected: (index) {
                                          if (index == selectedTabIndex) return;
                                          _selectedTabIndex.value = index;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTabContent(
                                        business,
                                        servicesState,
                                        selectedTabIndex,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BookingBottomBar(
                  business: business,
                  onBookNowTap: !canBook
                      ? null
                      : () async {
                          final servicesList = servicesState.value ?? [];
                          ServiceModel? selectedService;

                          if (_selectedServiceIds.isNotEmpty) {
                            final selectedId = _selectedServiceIds.first;
                            for (final service in servicesList) {
                              if (service.id == selectedId) {
                                selectedService = service;
                                break;
                              }
                            }
                          }

                          final currentDraft = ref.read(bookingDraftProvider);
                          if (selectedService != null) {
                            ref.read(bookingDraftProvider.notifier).state =
                                currentDraft.copyWith(
                              businessId: business.id,
                              businessName: business.name,
                              serviceId: selectedService.id,
                              serviceName: selectedService.name,
                              servicePrice: selectedService.discountPrice ??
                                  selectedService.price,
                              serviceDuration: selectedService.duration,
                              serviceDurationMinutes:
                                  selectedService.durationMinutes,
                              selectedServices: [selectedService],
                            );
                          } else {
                            ref.read(bookingDraftProvider.notifier).state =
                                currentDraft.copyWith(
                              businessId: business.id,
                              businessName: business.name,
                              selectedServices: const [],
                              serviceId: '',
                              serviceName: '',
                            );
                          }

                          final allowed = await requireLogin(
                            context,
                            targetRoute: '/booking-service',
                          );
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
    int selectedTabIndex,
  ) {
    switch (selectedTabIndex) {
      case 0:
        return servicesState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Text(
            context.tr('Unable to load services. Please try again.'),
            style: const TextStyle(color: AppColors.error),
          ),
          data: (services) => ServiceCategorySection(
            services: services,
            selectedServiceIds: _selectedServiceIds,
            onServiceSelect: (service) {
              setState(() {
                if (_selectedServiceIds.contains(service.id)) {
                  _selectedServiceIds.clear();
                } else {
                  _selectedServiceIds
                    ..clear()
                    ..add(service.id);
                }
              });

              final currentDraft = ref.read(bookingDraftProvider);
              if (_selectedServiceIds.isNotEmpty) {
                ref.read(bookingDraftProvider.notifier).state =
                    currentDraft.copyWith(
                  businessId: business.id,
                  businessName: business.name,
                  serviceId: service.id,
                  serviceName: service.name,
                  servicePrice: service.discountPrice ?? service.price,
                  serviceDuration: service.duration,
                  serviceDurationMinutes: service.durationMinutes,
                  selectedServices: [service],
                );
              } else {
                ref.read(bookingDraftProvider.notifier).state =
                    currentDraft.copyWith(
                  businessId: business.id,
                  businessName: business.name,
                  selectedServices: const [],
                  serviceId: '',
                  serviceName: '',
                );
              }
            },
          ),
        );

      case 1:
        return Consumer(
          builder: (context, tabRef, _) {
            final staffState = tabRef.watch(staffProvider(business.id));
            return staffState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text(
                context.tr('Unable to load specialists. Please try again.'),
                style: const TextStyle(color: AppColors.error),
              ),
              data: (staffList) {
                if (staffList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 48,
                          color: _mutedColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr(
                            'Specialist information is not available yet.',
                          ),
                          style: TextStyle(
                            color: _mutedColor,
                            fontSize: 14,
                          ),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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
          },
        );

      case 2:
        return Consumer(
          builder: (context, tabRef, _) {
            final reviewsState = tabRef.watch(reviewsProvider(business.id));
            return reviewsState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text(
                context.tr('Unable to load reviews. Please try again.'),
                style: const TextStyle(color: AppColors.error),
              ),
              data: (reviewsList) => ReviewsSection(
                averageRating: business.rating,
                totalReviews: business.reviewCount,
                reviews: reviewsList,
              ),
            );
          },
        );

      case 3:
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
    BuildContext context,
    WidgetRef ref,
    String businessId,
    Object err,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr("We couldn't load this salon."),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Please check your network connection and try again.',
              ),
              style: TextStyle(color: _mutedColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(businessDetailProvider(businessId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('Retry')),
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
            Icon(
              Icons.storefront_outlined,
              size: 56,
              color: _mutedColor,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('Salon Not Found'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'The requested business profile is no longer available.',
              ),
              style: TextStyle(color: _mutedColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
              child: Text(context.tr('Go Back')),
            ),
          ],
        ),
      ),
    );
  }
}
