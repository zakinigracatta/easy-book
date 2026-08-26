import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class BookingServiceScreen extends ConsumerStatefulWidget {
  BookingServiceScreen({super.key});

  @override
  ConsumerState<BookingServiceScreen> createState() =>
      _BookingServiceScreenState();
}

class _BookingServiceScreenState extends ConsumerState<BookingServiceScreen> {
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = ref.read(bookingDraftProvider).serviceId;
  }

  void _onNext(List<ServiceModel> services) {
    if (_selectedServiceId == null || _selectedServiceId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Please select a service to proceed.'))),
      );
      return;
    }

    try {
      final selected = services.firstWhere((s) => s.id == _selectedServiceId);
      ref.read(bookingDraftProvider.notifier).state =
          ref.read(bookingDraftProvider).copyWith(
        serviceId: selected.id,
        serviceName: selected.name,
        servicePrice: selected.discountPrice ?? selected.price,
        serviceDuration: selected.duration,
        serviceDurationMinutes: selected.durationMinutes,
        selectedServices: [selected],
      );
      context.push('/booking-specialist');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Invalid service selected.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
    final servicesState = ref.watch(servicesProvider(businessId));

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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Select Service')),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: servicesState.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 12),
                        Text(
                          context.tr('Unable to load services. Please try again.'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  data: (services) {
                    if (services.isEmpty) {
                      return Center(
                        child: Text(
                          context.tr('No services available for this salon.'),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      );
                    }

                    _selectedServiceId ??= services.first.id;

                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isSelected = _selectedServiceId == service.id;
                        final price = service.discountPrice ?? service.price;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () =>
                                setState(() => _selectedServiceId = service.id),
                            borderColor:
                                isSelected ? Theme.of(context).primaryColor : null,
                            child: ListTile(
                              title: Text(
                                service.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(service.duration),
                              trailing: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  CurrencyFormatter.format(
                                    price,
                                    currency: service.currency,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              servicesState.maybeWhen(
                data: (services) => CustomButton(
                  text: 'Continue: Select Specialist',
                  onPressed:
                      services.isNotEmpty ? () => _onNext(services) : null,
                ),
                orElse: () => SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
