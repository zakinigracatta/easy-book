import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/staff_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_guard.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key, this.staff});

  final StaffModel? staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialist = staff;
    final currentDraft = ref.watch(bookingDraftProvider);
    final staffBusinessId = specialist?.businessId.trim().isNotEmpty == true
        ? specialist!.businessId.trim()
        : (currentDraft.businessId ?? '');
    final businessState = staffBusinessId.isEmpty
        ? null
        : ref.watch(businessDetailProvider(staffBusinessId));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Staff & Specialists')),
        ),
        body: specialist == null
            ? Center(
                child: Text(
                  context.tr('Specialist information is not available yet.'),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GlassCard(
                    child: Column(
                      children: [
                        _Avatar(staff: specialist),
                        const SizedBox(height: 14),
                        Text(
                          specialist.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        if (specialist.roleTitle.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            specialist.roleTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (specialist.rating > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingStars(rating: specialist.rating),
                              const SizedBox(width: 8),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  specialist.reviewCount > 0
                                      ? '${specialist.rating.toStringAsFixed(1)} (${specialist.reviewCount})'
                                      : specialist.rating.toStringAsFixed(1),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (specialist.experienceYears > 0) ...[
                          const SizedBox(height: 10),
                          Text(
                            context.tr(
                              '• {count} yrs experience',
                              params: {'count': specialist.experienceYears},
                            ),
                          ),
                        ],
                        if (specialist.bio?.trim().isNotEmpty == true) ...[
                          const Divider(height: 28),
                          Text(
                            specialist.bio!.trim(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: !specialist.isActive ||
                            businessState?.value == null
                        ? null
                        : () async {
                            final business = businessState!.value!;
                            final draft = ref.read(bookingDraftProvider);
                            final isSameBusiness =
                                draft.businessId == business.id;

                            ref.read(bookingDraftProvider.notifier).state =
                                isSameBusiness
                                    ? draft.copyWith(
                                        businessId: business.id,
                                        businessName: business.name,
                                        staffId: specialist.id,
                                        staffName: specialist.name,
                                        anySpecialist: false,
                                        resetAppointmentSelection: true,
                                      )
                                    : BookingDraft(
                                        businessId: business.id,
                                        businessName: business.name,
                                        staffId: specialist.id,
                                        staffName: specialist.name,
                                        anySpecialist: false,
                                      );

                            final allowed = await requireLogin(
                              context,
                              targetRoute: '/booking-service',
                            );
                            if (allowed && context.mounted) {
                              context.push('/booking-service');
                            }
                          },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(context.tr('Select')),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.staff});

  final StaffModel staff;

  @override
  Widget build(BuildContext context) {
    final url = staff.avatarUrl.trim();
    if (url.isEmpty) {
      return CircleAvatar(
        radius: 46,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: const Icon(
          Icons.person_rounded,
          size: 44,
          color: AppColors.primary,
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          width: 92,
          height: 92,
          alignment: Alignment.center,
          color: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(
            Icons.person_rounded,
            size: 44,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
