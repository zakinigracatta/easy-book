import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/booking_model.dart';
import '../../providers/app_providers.dart';
import '../../services/auth_guard.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import 'widgets/booking_progress_header.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isSubmitting = false;

  DateTime _resolveStartDateTime(BookingDraft draft) {
    final date = draft.date;
    final timeSlot = draft.timeSlot;
    if (date == null || timeSlot == null || timeSlot.trim().isEmpty) {
      throw StateError('Please select a valid appointment date and time.');
    }

    final parsedTime = DateFormat('hh:mm a').parseStrict(timeSlot.trim());
    return DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  Future<void> _confirmBooking() async {
    if (_isSubmitting) return;

    final loggedIn = await requireLogin(context, targetRoute: '/booking-summary');
    if (!loggedIn || !mounted) return;

    final draft = ref.read(bookingDraftProvider);
    final user = ref.read(authProvider);
    final businessId = draft.businessId?.trim() ?? '';
    final serviceId = draft.serviceId?.trim() ?? '';
    final staffId = (draft.resolvedStaffId?.trim().isNotEmpty == true
            ? draft.resolvedStaffId
            : draft.staffId)
        ?.trim() ??
        '';

    if (businessId.isEmpty || serviceId.isEmpty || staffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Booking information is incomplete. Please reselect the service and specialist.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final startAt = _resolveStartDateTime(draft);
      if (startAt.minute % 15 != 0 || startAt.second != 0) {
        throw StateError('Selected time is not aligned to a valid 15-minute slot.');
      }

      final duration = draft.totalDurationMinutes > 0
          ? draft.totalDurationMinutes
          : 30;
      final customerName = user?.fullName.trim().isNotEmpty == true
          ? user!.fullName.trim()
          : 'Easy Book Customer';
      final customerPhone = user?.phone.trim() ?? '';

      final requestBooking = BookingModel(
        id: '',
        customerId: user?.id ?? '',
        customerName: customerName,
        customerPhone: customerPhone,
        businessId: businessId,
        businessName: draft.businessName ?? '',
        serviceId: serviceId,
        serviceName: draft.serviceName ?? '',
        servicePrice: draft.totalPrice,
        staffId: staffId,
        staffName: draft.resolvedStaffName ?? draft.staffName ?? '',
        startDateTime: startAt,
        endDateTime: startAt.add(Duration(minutes: duration)),
        status: BookingStatus.pending,
        bookingSource: 'app',
      );

      final saved = await ref
          .read(appointmentsProvider.notifier)
          .createBooking(requestBooking);

      if (!mounted) return;
      ref.read(bookingDraftProvider.notifier).state = BookingDraft();
      context.go('/booking-success', extra: saved);
    } catch (e) {
      if (!mounted) return;
      final message = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Bad state: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
    final businessState = ref.watch(businessDetailProvider(businessId));

    final dateStr = draft.date != null
        ? DateFormat('EEEE, dd MMMM yyyy').format(draft.date!)
        : 'Not selected';
    final timeStr = draft.timeSlot ?? 'Not selected';
    final staffName =
        draft.resolvedStaffName?.trim().isNotEmpty == true
            ? draft.resolvedStaffName!
            : (draft.staffName?.trim().isNotEmpty == true
                ? draft.staffName!
                : 'Any Available Specialist');
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
            onPressed: _isSubmitting
                ? null
                : () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: const Text('Booking Summary'),
        ),
        body: businessState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (business) {
            final salonName = business?.name ?? draft.businessName ?? 'Salon';
            final salonAddress = business?.address ?? 'Dubai, UAE';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: const Icon(Icons.storefront_rounded,
                              color: AppColors.primaryLight, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(salonName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(salonAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMutedDark)),
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
                        const Text('Service',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        if (services.isNotEmpty)
                          ...services.map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(service.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ),
                                    Text(service.duration,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMutedDark)),
                                    const SizedBox(width: 12),
                                    Text(
                                      CurrencyFormatter.format(
                                          service.discountPrice ?? service.price,
                                          currency: service.currency),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                              ))
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Text(draft.serviceName ?? 'Service',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                              Text(CurrencyFormatter.format(totalPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryLight)),
                            ],
                          ),
                        const Divider(
                            color: AppColors.glassBorderDark, height: 20),
                        _valueRow('Total duration', '$totalDuration minutes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Appointment Info',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        _infoRow(Icons.calendar_today_rounded, 'Date', dateStr),
                        const SizedBox(height: 10),
                        _infoRow(Icons.access_time_rounded, 'Time', timeStr),
                        const SizedBox(height: 10),
                        _infoRow(Icons.person_outline_rounded, 'Specialist', staffName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 10),
                        _valueRow('Payment method', 'Pay at venue'),
                        const SizedBox(height: 8),
                        _valueRow('Total', CurrencyFormatter.format(totalPrice),
                            isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm Booking',
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _confirmBooking,
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'The selected slot is revalidated securely when you confirm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMutedDark),
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

  static Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 10),
        Text('$title: ',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMutedDark)),
        Expanded(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ],
    );
  }

  static Widget _valueRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 15 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.white : AppColors.textMutedDark)),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 17 : 13,
                fontWeight: FontWeight.bold,
                color: isTotal ? AppColors.primaryLight : Colors.white)),
      ],
    );
  }
}
