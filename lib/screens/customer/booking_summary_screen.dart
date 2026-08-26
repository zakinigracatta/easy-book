import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import 'widgets/booking_progress_header.dart';

class BookingSummaryScreen extends ConsumerWidget {
  BookingSummaryScreen({super.key});

  static Color _mutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
    final businessState = ref.watch(businessDetailProvider(businessId));
    final mutedColor = _mutedColor(context);

    final dateStr = draft.date != null
        ? MaterialLocalizations.of(context).formatFullDate(draft.date!)
        : context.tr('Not selected');
    final timeStr = draft.timeSlot ?? context.tr('Not selected');
    final staffName = _resolvedStaffName(context, draft);
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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(context.tr('Booking Summary')),
        ),
        body: businessState.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (_, __) => _errorState(
            context,
            'Unable to load the business details. Please try again.',
          ),
          data: (business) {
            if (business == null) {
              return _errorState(
                context,
                'This business is no longer available.',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingProgressHeader(currentStep: 3),
                  SizedBox(height: 20),
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                business.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          context,
                          'Services',
                          onEdit: () => context.push('/booking-service'),
                        ),
                        SizedBox(height: 12),
                        if (services.isNotEmpty)
                          ...services.map((service) {
                            final price =
                                service.discountPrice ?? service.price;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          service.duration,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: mutedColor,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        else
                          _summaryRow(
                            context,
                            draft.serviceName ?? 'Service',
                            CurrencyFormatter.format(totalPrice),
                          ),
                        Divider(height: 22),
                        _summaryRow(
                          context,
                          'Total duration',
                          '$totalDuration ${context.tr('minutes')}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          context,
                          'Appointment',
                          onEdit: () => context.push('/booking-time'),
                        ),
                        SizedBox(height: 12),
                        _infoRow(
                          context,
                          Icons.calendar_today_rounded,
                          'Date',
                          dateStr,
                        ),
                        SizedBox(height: 10),
                        _infoRow(
                          context,
                          Icons.access_time_rounded,
                          'Time',
                          timeStr,
                        ),
                        SizedBox(height: 10),
                        _infoRow(
                          context,
                          Icons.person_outline_rounded,
                          'Specialist',
                          staffName,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Total'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('Amount due'),
                              style: TextStyle(color: mutedColor),
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                CurrencyFormatter.format(totalPrice),
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'Continue to Confirmation',
                    onPressed: draft.isComplete
                        ? () => context.push('/booking-confirmation')
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr(
                                    'Please complete the service, specialist, date and time first.',
                                  ),
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

  static String _resolvedStaffName(BuildContext context, BookingDraft draft) {
    final resolved = draft.resolvedStaffName?.trim() ?? '';
    if (resolved.isNotEmpty) return resolved;
    final selected = draft.staffName?.trim() ?? '';
    if (selected.isNotEmpty) {
      return selected == 'Any Available Specialist'
          ? context.tr(selected)
          : selected;
    }
    return draft.anySpecialist
        ? context.tr('Any Available Specialist')
        : context.tr('Not selected');
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
          context.tr(title),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: Text(context.tr('Edit')),
        ),
      ],
    );
  }

  static Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.shrink(),
        Icon(icon, size: 17, color: AppColors.primary),
        SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            context.tr(title),
            style: TextStyle(
              fontSize: 13,
              color: _mutedColor(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _summaryRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.tr(label),
            style: TextStyle(color: _mutedColor(context)),
          ),
        ),
        SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  static Widget _errorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: 12),
            Text(
              context.tr(message),
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedColor(context)),
            ),
            SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: Text(context.tr('Back to Home')),
            ),
          ],
        ),
      ),
    );
  }
}
