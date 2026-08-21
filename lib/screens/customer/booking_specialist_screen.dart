import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_catalog_provider.dart';
import '../../theme/app_colors.dart';
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
        staffName: 'Any Available Specialist',
      );
    } else {
      if (_selectedStaffId == null || _selectedStaffId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please choose a specialist or select Any Available Specialist.')),
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

    final eligibleStaffState = ref.watch(cachedEligibleStaffProvider((
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
          title: const Text('Select Specialist'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const BookingProgressHeader(currentStep: 1),
              const SizedBox(height: 16),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Specialist',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select your preferred specialist or choose anyone available.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMutedDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: eligibleStaffState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error loading specialists: $err',
                        style: const TextStyle(color: AppColors.error)),
                  ),
                  data: (eligibleStaff) {
                    return ListView(
                      children: [
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
              eligibleStaffState.maybeWhen(
                data: (eligibleStaff) => CustomButton(
                  text: 'Continue: Select Date & Time',
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
