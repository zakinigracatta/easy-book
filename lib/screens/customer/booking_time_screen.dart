import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/staff_model.dart';
import '../../models/available_slot.dart';
import '../../l10n/l10n.dart';
import 'widgets/booking_progress_header.dart';
import 'widgets/booking_date_selector.dart';
import 'widgets/time_slot_grid.dart';

class BookingTimeScreen extends ConsumerStatefulWidget {
  const BookingTimeScreen({super.key});

  @override
  ConsumerState<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends ConsumerState<BookingTimeScreen> {
  AvailableSlot? _selectedSlot;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    final now = DateTime.now();
    _selectedDate = draft.date ?? DateTime(now.year, now.month, now.day);
  }

  void _onNext(
      List<StaffModel> eligibleStaff, List<AvailableSlot> availableSlots) {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10nOf(context).timeSelectionRequired)),
      );
      return;
    }

    final draft = ref.read(bookingDraftProvider);
    String resolvedId = draft.staffId ?? '';
    String resolvedName = draft.staffName ?? l10nOf(context).specialist;

    // If Any Specialist was chosen, resolve staff ID from available staff for this slot
    if (draft.anySpecialist || resolvedId.isEmpty) {
      if (_selectedSlot!.availableStaffIds.isNotEmpty) {
        resolvedId = _selectedSlot!.availableStaffIds.first;
        final match = eligibleStaff.where((s) => s.id == resolvedId).toList();
        if (match.isNotEmpty) {
          resolvedName = match.first.name;
        }
      }
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

    final eligibleStaffState = ref.watch(eligibleStaffProvider((
      businessId: businessId,
      selectedServices: selectedServices,
    )));

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
          title: Text(l10nOf(context).selectAppointmentTime),
        ),
        body: businessState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
              child: Text(l10nOf(context).errorWithDetails('$err'),
                  style: const TextStyle(color: AppColors.error))),
          data: (business) {
            if (business == null) {
              return Center(
                  child: Text(l10nOf(context).salonNotFound,
                      style: const TextStyle(color: AppColors.textMutedDark)));
            }

            return eligibleStaffState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                  child: Text(l10nOf(context).staffLoadError('$err'),
                      style: const TextStyle(color: AppColors.error))),
              data: (eligibleStaff) {
                final engineSlotsState =
                    ref.watch(availableSlotsEngineProvider((
                  business: business,
                  selectedServices: selectedServices,
                  allStaff: eligibleStaff,
                  specialistId: draft.staffId,
                  anySpecialist: draft.anySpecialist,
                  date: _selectedDate,
                )));

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Header Step 2
                      const BookingProgressHeader(currentStep: 2),
                      const SizedBox(height: 16),

                      // Date Selector
                      BookingDateSelector(
                        selectedDate: _selectedDate,
                        onDateSelected: (d) {
                          setState(() {
                            _selectedDate = d;
                            _selectedSlot = null; // clear slot on date change
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Time Slots
                      Expanded(
                        child: SingleChildScrollView(
                          child: engineSlotsState.when(
                            loading: () => const TimeSlotGrid(
                              slots: [],
                              selectedSlotTime: null,
                              onSlotSelected: _noop,
                              isLoading: true,
                            ),
                            error: (err, _) => Center(
                                child: Text(
                                    l10nOf(context).slotsLoadError('$err'),
                                    style: const TextStyle(
                                        color: AppColors.error))),
                            data: (availableSlots) {
                              return TimeSlotGrid(
                                slots: availableSlots,
                                selectedSlotTime: _selectedSlot?.timeString,
                                onSlotSelected: (slot) {
                                  setState(() {
                                    _selectedSlot = slot;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      engineSlotsState.maybeWhen(
                        data: (slots) => CustomButton(
                          text: l10nOf(context).reviewBookingSummary,
                          onPressed: _selectedSlot != null
                              ? () => _onNext(eligibleStaff, slots)
                              : null,
                        ),
                        orElse: () => const SizedBox.shrink(),
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
