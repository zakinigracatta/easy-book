import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
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

    final staffName =
        (draft.resolvedStaffName != null && draft.resolvedStaffName!.isNotEmpty)
            ? draft.resolvedStaffName!
            : (draft.staffName != null && draft.staffName!.isNotEmpty
                ? draft.staffName!
                : 'Any Available Specialist');

    final services = draft.selectedServices;
    final totalPrice = draft.totalPrice;
    final totalDuration = draft.totalDurationMinutes;

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
          title: const Text('Booking Summary'),
        ),
        body: businessState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
              child: Text('Error: $err',
                  style: const TextStyle(color: AppColors.error))),
          data: (business) {
            final salonName = business?.name ?? draft.businessName ?? 'Salon';
            final salonAddress = business?.address ?? 'Dubai, UAE';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 3 Header
                  const BookingProgressHeader(currentStep: 3),
                  const SizedBox(height: 20),

                  // Salon Details Header Card
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront_rounded,
                              color: AppColors.primaryLight, size: 24),
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
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                salonAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMutedDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selected Services Breakdown Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Services',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/salon-details',
                                  extra: businessId),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (services.isNotEmpty)
                          ...services.map((s) {
                            final price = s.discountPrice ?? s.price;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    s.duration,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMutedDark),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    CurrencyFormatter.format(price,
                                        currency: s.currency),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryLight),
                                  ),
                                ],
                              ),
                            );
                          })
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                draft.serviceName ?? 'General Service',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              Text(
                                CurrencyFormatter.format(totalPrice),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                        const Divider(
                            color: AppColors.glassBorderDark, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Duration',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMutedDark)),
                            Text('$totalDuration minutes',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Appointment Details Card (Date, Time, Specialist)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Appointment Info',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/booking-date'),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoRow(Icons.calendar_today_rounded, 'Date', dateStr),
                        const SizedBox(height: 10),
                        _infoRow(Icons.access_time_rounded, 'Time', timeStr),
                        const SizedBox(height: 10),
                        _infoRow(Icons.person_outline_rounded, 'Specialist',
                            staffName),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pricing Breakdown Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        _priceRow(
                            'Subtotal', CurrencyFormatter.format(totalPrice)),
                        const SizedBox(height: 6),
                        _priceRow(
                            'Taxes & Fees', CurrencyFormatter.format(0.0)),
                        const Divider(
                            color: AppColors.glassBorderDark, height: 20),
                        _priceRow('Total Amount',
                            CurrencyFormatter.format(totalPrice),
                            isTotal: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  CustomButton(
                    text: 'Continue to Payment',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Booking summary confirmed! Proceeding to Payment preparation phase...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textMutedDark),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget _priceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.white : AppColors.textSecondaryDark,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryLight : Colors.white,
          ),
        ),
      ],
    );
  }
}
