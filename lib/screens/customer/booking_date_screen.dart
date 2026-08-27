import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';
import 'widgets/booking_progress_header.dart';
import 'widgets/booking_date_selector.dart';

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
        ref.read(bookingDraftProvider).copyWith(
              date: _selectedDate,
            );
    context.push('/booking-time');
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(l10nOf(context).selectAppointmentDate),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Header Step 2
              const BookingProgressHeader(currentStep: 2),
              const SizedBox(height: 20),

              // Date Selector Component
              BookingDateSelector(
                selectedDate: _selectedDate,
                onDateSelected: (d) => setState(() => _selectedDate = d),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: l10nOf(context).nextSelectTime,
                onPressed: _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
