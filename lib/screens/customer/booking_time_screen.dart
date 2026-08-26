import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/available_slot.dart';
import '../../models/staff_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'widgets/booking_date_selector.dart';
import 'widgets/booking_progress_header.dart';
import 'widgets/time_slot_grid.dart';

class BookingTimeScreen extends ConsumerStatefulWidget {
  BookingTimeScreen({super.key});

  @override
  ConsumerState<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends ConsumerState<BookingTimeScreen> {
  AvailableSlot? _selectedSlot;
  late DateTime _selectedDate;

  Color get _mutedColor => Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : AppColors.textMutedLight;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    final now = DateTime.now();
    _selectedDate = draft.date ?? DateTime(now.year, now.month, now.day);
  }

  void _onNext(List<StaffModel> eligibleStaff) {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Please select an available time slot to continue.'),
          ),
        ),
      );
      return;
    }

    final draft = ref.read(bookingDraftProvider);
    String resolvedId = draft.staffId ?? '';
    String resolvedName = draft.staffName ?? context.tr('Specialist');

    if (draft.anySpecialist || resolvedId.isEmpty) {
      if (_selectedSlot!.availableStaffIds.isNotEmpty) {
        resolvedId = _selectedSlot!.availableStaffIds.first;
        final matches = eligibleStaff.where((staff) => staff.id == resolvedId);
        if (matches.isNotEmpty) resolvedName = matches.first.name;
      }
    }

    if (resolvedId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'No available specialist was resolved for this time slot.',
            ),
          ),
        ),
      );
      return;
    }

    ref.read(bookingDraftProvider.notifier).state = draft.copyWith(
      date: _selectedDate,
      timeSlot: _selectedSlot!.timeString,
      resolvedStaffId: resolvedId,
      resolvedStaffName: resolvedName,
    );

    context.push('/booking-summary');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
    final businessState = ref.watch(businessDetailProvider(businessId));
    final selectedServices = draft.selectedServices;
    final eligibleStaffState = ref.watch(
      eligibleStaffProvider((
        businessId: businessId,
        selectedServices: selectedServices,
      )),
    );

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
          title: Text(context.tr('Select Appointment Time')),
        ),
        body: businessState.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              context.tr(
                'Unable to load the business details. Please try again.',
              ),
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
          data: (business) {
            if (business == null) {
              return Center(
                child: Text(
                  context.tr('Salon not found.'),
                  style: TextStyle(color: _mutedColor),
                ),
              );
            }

            return eligibleStaffState.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(
                  context.tr('Unable to load specialists. Please try again.'),
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (eligibleStaff) {
                final engineSlotsState = ref.watch(
                  availableSlotsEngineProvider((
                    business: business,
                    selectedServices: selectedServices,
                    allStaff: eligibleStaff,
                    specialistId: draft.staffId,
                    anySpecialist: draft.anySpecialist,
                    date: _selectedDate,
                  )),
                );

                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingProgressHeader(currentStep: 2),
                      SizedBox(height: 16),
                      BookingDateSelector(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                            _selectedSlot = null;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: engineSlotsState.when(
                            loading: () => TimeSlotGrid(
                              slots: [],
                              selectedSlotTime: null,
                              onSlotSelected: _noop,
                              isLoading: true,
                            ),
                            error: (_, __) => Center(
                              child: Text(
                                context.tr(
                                  'Unable to load time slots. Please try again.',
                                ),
                                style:
                                    TextStyle(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            data: (availableSlots) => TimeSlotGrid(
                              slots: availableSlots,
                              selectedSlotTime: _selectedSlot?.timeString,
                              onSlotSelected: (slot) {
                                setState(() => _selectedSlot = slot);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      engineSlotsState.maybeWhen(
                        data: (_) => CustomButton(
                          text: 'Review Booking Summary',
                          onPressed: _selectedSlot != null
                              ? () => _onNext(eligibleStaff)
                              : null,
                        ),
                        orElse: () => SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static void _noop(AvailableSlot slot) {}
}
