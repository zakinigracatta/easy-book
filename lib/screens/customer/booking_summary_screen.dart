import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/currency_formatter.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import 'widgets/booking_progress_header.dart';

class BookingSummaryScreen extends ConsumerWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
    final businessState = ref.watch(businessDetailProvider(businessId));

    final dateStr = draft.date != null
        ? DateFormat('EEEE, dd MMMM yyyy').format(draft.date!)
        : 'Not selected';
    final timeStr = draft.timeSlot ?? 'Not selected';
    final staffName = _resolvedStaffName(draft);
    final services = draft.selectedServices;
    final totalPrice = draft.totalPrice;
    final totalDuration = draft.totalDurationMinutes;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: const Text('Booking Summary'),
        ),
        body: businessState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _errorState(
            context,
            'Unable to load the business details. Please try again.',
          ),
          data: (business) {
            if (business == null) {
              return _errorState(context, 'This business is no longer available.');
            }

            final salonName = business.name;
            final salonAddress = business.address;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BookingProgressHeader(currentStep: 3),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primaryLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salonName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                salonAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMutedDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          context,
                          'Services',
                          onEdit: () => context.push('/booking-service'),
                        ),
                        const SizedBox(height: 12),
                        if (services.isNotEmpty)
                          ...services.map((service) {
                            final price = service.discountPrice ?? service.price;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimaryDark,
                                          ),
                                        ),
                                        Text(
                                          service.duration,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMutedDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      CurrencyFormatter.format(
                                        price,
                                        currency: service.currency,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        else
                          _summaryRow(
                            draft.serviceName ?? 'Service',
                            CurrencyFormatter.format(totalPrice),
                          ),
                        const Divider(height: 22),
                        _summaryRow('Total duration', '$totalDuration minutes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          context,
                          'Appointment',
                          onEdit: () => context.push('/booking-time'),
                        ),
                        const SizedBox(height: 12),
                        _infoRow(Icons.calendar_today_rounded, 'Date', dateStr),
                        const SizedBox(height: 10),
                        _infoRow(Icons.access_time_rounded, 'Time', timeStr),
                        const SizedBox(height: 10),
                        _infoRow(
                          Icons.person_outline_rounded,
                          'Specialist',
                          staffName,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Amount due',
                              style: TextStyle(color: AppColors.textMutedDark),
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                CurrencyFormatter.format(totalPrice),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Continue to Confirmation',
                    onPressed: draft.isComplete
                        ? () => context.push('/booking-confirmation')
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete the service, specialist, date and time first.',
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _resolvedStaffName(BookingDraft draft) {
    final resolved = draft.resolvedStaffName?.trim() ?? '';
    if (resolved.isNotEmpty) return resolved;
    final selected = draft.staffName?.trim() ?? '';
    if (selected.isNotEmpty) return selected;
    return draft.anySpecialist ? 'Any Available Specialist' : 'Not selected';
  }

  static Widget _sectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        TextButton(onPressed: onEdit, child: const Text('Edit')),
      ],
    );
  }

  static Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primaryLight),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMutedDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMutedDark),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }

  static Widget _errorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMutedDark),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
