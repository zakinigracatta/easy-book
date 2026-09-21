import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/business_clock.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/custom_button.dart';
import 'widgets/booking_date_selector.dart';
import 'widgets/booking_progress_header.dart';

class BookingDateScreen extends ConsumerStatefulWidget {
  const BookingDateScreen({super.key});

  @override
  ConsumerState<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends ConsumerState<BookingDateScreen> {
  late DateTime _selectedDate;
  bool _hasUserSelectedDate = false;

  @override
  void initState() {
    super.initState();
    final draftDate = ref.read(bookingDraftProvider).date;
    final now = DateTime.now();
    _selectedDate = draftDate ?? DateTime(now.year, now.month, now.day);
  }

  void _onNext(DateTime selectedDate) {
    ref.read(bookingDraftProvider.notifier).state =
        ref.read(bookingDraftProvider).copyWith(
              date: selectedDate,
              resetAppointmentSelection: true,
            );
    context.push('/booking-time');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final businessState =
        ref.watch(businessDetailProvider(draft.businessId ?? ''));
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
          title: Text(context.tr('Select Appointment Date')),
        ),
        body: businessState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              context.tr('Unable to load the business details. Please try again.'),
              textAlign: TextAlign.center,
            ),
          ),
          data: (business) {
            if (business == null) {
              return Center(child: Text(context.tr('Salon not found.')));
            }
            final businessToday = BusinessClock.calendarToday(business.timeZone);
            final effectiveSelectedDate =
                !_hasUserSelectedDate && draft.date == null
                    ? businessToday
                    : (_selectedDate.isBefore(businessToday)
                        ? businessToday
                        : _selectedDate);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BookingProgressHeader(currentStep: 2),
                  const SizedBox(height: 20),
                  BookingDateSelector(
                    selectedDate: effectiveSelectedDate,
                    today: businessToday,
                    onDateSelected: (date) => setState(() {
                      _selectedDate = date;
                      _hasUserSelectedDate = true;
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Spacer(),
                  CustomButton(
                    text: 'Next: Select Time Slot',
                    onPressed: () => _onNext(effectiveSelectedDate),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
