import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    final draftDate = ref.read(bookingDraftProvider).date;
    final now = DateTime.now();
    _selectedDate = draftDate ?? DateTime(now.year, now.month, now.day);
  }

  void _onNext() {
    ref.read(bookingDraftProvider.notifier).state =
        ref.read(bookingDraftProvider).copyWith(date: _selectedDate);
    context.push('/booking-time');
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(context.tr('Select Appointment Date')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookingProgressHeader(currentStep: 2),
              const SizedBox(height: 20),
              BookingDateSelector(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              CustomButton(
                text: 'Next: Select Time Slot',
                onPressed: _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
