import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../providers/app_providers.dart';
import '../../models/service_model.dart';
import '../../theme/app_colors.dart';

class BookingServiceScreen extends ConsumerStatefulWidget {
  const BookingServiceScreen({super.key});

  @override
  ConsumerState<BookingServiceScreen> createState() =>
      _BookingServiceScreenState();
}

class _BookingServiceScreenState extends ConsumerState<BookingServiceScreen> {
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _selectedServiceId = draft.serviceId;
  }

  void _onNext(List<ServiceModel> services) {
    if (_selectedServiceId == null || _selectedServiceId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service to proceed.')),
      );
      return;
    }

    try {
      final sel = services.firstWhere((s) => s.id == _selectedServiceId);
      ref.read(bookingDraftProvider.notifier).state =
          ref.read(bookingDraftProvider).copyWith(
        serviceId: sel.id,
        serviceName: sel.name,
        servicePrice: sel.discountPrice ?? sel.price,
        serviceDuration: sel.duration,
        serviceDurationMinutes: sel.durationMinutes,
        selectedServices: [sel],
      );
      context.push('/booking-specialist');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid service selected.')),
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
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Step 1: Select Service'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: servicesState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Error loading services: $err',
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  data: (services) {
                    if (services.isEmpty) {
                      return const Center(
                        child: Text(
                          'No services available for this salon.',
                          style: TextStyle(color: AppColors.textMutedDark),
                        ),
                      );
                    }

                    // Auto-select first service if none selected
                    _selectedServiceId ??= services.first.id;

                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final s = services[index];
                        final isSel = _selectedServiceId == s.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () =>
                                setState(() => _selectedServiceId = s.id),
                            borderColor:
                                isSel ? Theme.of(context).primaryColor : null,
                            child: ListTile(
                              title: Text(s.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(s.duration),
                              trailing: Text(
                                '\$${s.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
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
                  text: 'Next: Select Date',
                  onPressed:
                      services.isNotEmpty ? () => _onNext(services) : null,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
