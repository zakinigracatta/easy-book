import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_guard.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  const ServiceDetailsScreen({super.key, this.service});

  final ServiceModel? service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = service;
    final currentDraft = ref.watch(bookingDraftProvider);
    final serviceBusinessId = item?.salonId.trim().isNotEmpty == true
        ? item!.salonId.trim()
        : (currentDraft.businessId ?? '');
    final businessState = serviceBusinessId.isEmpty
        ? null
        : ref.watch(businessDetailProvider(serviceBusinessId));

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
          title: Text(context.tr('Service Information')),
        ),
        body: item == null
            ? _UnavailableState(
                message: context.tr('Service details are not available.'),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '${CurrencyFormatter.format(item.effectivePrice, currency: item.currency)} • ${item.durationMinutes} ${context.tr('minutes')}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.categoryName.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              item.categoryName,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (item.description?.trim().isNotEmpty == true) ...[
                            const Divider(height: 24),
                            Text(
                              item.description!.trim(),
                              style: const TextStyle(height: 1.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: context.tr('Proceed to Booking'),
                      onPressed: !item.isActive ||
                              !item.isBookable ||
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
                                          serviceId: item.id,
                                          serviceName: item.name,
                                          servicePrice: item.effectivePrice,
                                          serviceDuration: item.duration,
                                          serviceDurationMinutes:
                                              item.durationMinutes,
                                          selectedServices: [item],
                                          resetStaffSelection:
                                              draft.serviceId?.isNotEmpty == true &&
                                                  draft.serviceId != item.id,
                                          resetAppointmentSelection: true,
                                        )
                                      : BookingDraft(
                                          businessId: business.id,
                                          businessName: business.name,
                                          serviceId: item.id,
                                          serviceName: item.name,
                                          servicePrice: item.effectivePrice,
                                          serviceDuration: item.duration,
                                          serviceDurationMinutes:
                                              item.durationMinutes,
                                          selectedServices: [item],
                                        );

                              final allowed = await requireLogin(
                                context,
                                targetRoute: '/booking-specialist',
                              );
                              if (allowed && context.mounted) {
                                context.push('/booking-specialist');
                              }
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.design_services_outlined, size: 52),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
