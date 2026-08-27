import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../l10n/l10n.dart';
import '../../widgets/custom_button.dart';
import 'widgets/selected_services_summary.dart';
import 'widgets/specialist_option_card.dart';
import 'widgets/booking_progress_header.dart';

class BookingSpecialistScreen extends ConsumerStatefulWidget {
  const BookingSpecialistScreen({super.key});

  @override
  ConsumerState<BookingSpecialistScreen> createState() =>
      _BookingSpecialistScreenState();
}

class _BookingSpecialistScreenState
    extends ConsumerState<BookingSpecialistScreen> {
  String? _selectedStaffId;
  bool _anySpecialist = true;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _anySpecialist = draft.anySpecialist ||
        (draft.staffId == null || draft.staffId!.isEmpty);
    _selectedStaffId = draft.staffId;
  }

  void _onNext(List<StaffModel> eligibleStaff) {
    final draft = ref.read(bookingDraftProvider);
    if (_anySpecialist) {
      ref.read(bookingDraftProvider.notifier).state = draft.copyWith(
        anySpecialist: true,
        staffId: '',
        staffName: l10nOf(context).anyAvailableSpecialist,
      );
    } else {
      if (_selectedStaffId == null || _selectedStaffId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10nOf(context).specialistSelectionRequired)),
        );
        return;
      }
      final staff = eligibleStaff.firstWhere((s) => s.id == _selectedStaffId);
      ref.read(bookingDraftProvider.notifier).state = draft.copyWith(
        anySpecialist: false,
        staffId: staff.id,
        staffName: staff.name,
      );
    }
    context.push('/booking-date');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final businessId = draft.businessId ?? '';
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
          title: Text(l10nOf(context).selectSpecialist),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress Header Step 1
              const BookingProgressHeader(currentStep: 1),
              const SizedBox(height: 16),

              // Selected Services Summary Review
              if (selectedServices.isNotEmpty) ...[
                SelectedServicesSummary(
                  services: selectedServices,
                  onEditTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.push('/salon-details', extra: businessId);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nOf(context).chooseSpecialist,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10nOf(context).chooseSpecialistDescription,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMutedDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Eligible Staff List
              Expanded(
                child: eligibleStaffState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(l10nOf(context).specialistsLoadError('$err'),
                        style: const TextStyle(color: AppColors.error)),
                  ),
                  data: (eligibleStaff) {
                    return ListView(
                      children: [
                        // Option 1: Any Available Specialist
                        SpecialistOptionCard(
                          isAnySpecialist: true,
                          isSelected: _anySpecialist,
                          onTap: () {
                            setState(() {
                              _anySpecialist = true;
                              _selectedStaffId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // Eligible Staff Cards
                        ...eligibleStaff.map((staff) {
                          final isSel =
                              !_anySpecialist && _selectedStaffId == staff.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SpecialistOptionCard(
                              staff: staff,
                              isSelected: isSel,
                              onTap: () {
                                setState(() {
                                  _anySpecialist = false;
                                  _selectedStaffId = staff.id;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),

              // Continue Button
              eligibleStaffState.maybeWhen(
                data: (eligibleStaff) => CustomButton(
                  text: l10nOf(context).continueDateTime,
                  onPressed: () => _onNext(eligibleStaff),
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
