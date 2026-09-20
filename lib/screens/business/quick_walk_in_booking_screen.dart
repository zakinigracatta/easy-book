import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/utils/business_clock.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';
import '../../models/staff_model.dart';
import '../../l10n/app_localizations.dart';

class QuickWalkInBookingScreen extends ConsumerStatefulWidget {
  const QuickWalkInBookingScreen({super.key});

  @override
  ConsumerState<QuickWalkInBookingScreen> createState() =>
      _QuickWalkInBookingScreenState();
}

class _QuickWalkInBookingScreenState
    extends ConsumerState<QuickWalkInBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  ServiceModel? _selectedService;
  StaffModel? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = _nextQuarterHour();
  bool _isLoading = false;

  static TimeOfDay _nextQuarterHour() {
    final now = DateTime.now();
    final roundedMinute = ((now.minute + 14) ~/ 15) * 15;
    final rounded = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(Duration(minutes: roundedMinute));
    return TimeOfDay(hour: rounded.hour, minute: rounded.minute);
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(ownerServicesProvider);
    final employeesAsync = ref.watch(ownerEmployeesProvider);
    final businessAsync = ref.watch(ownerBusinessProvider);

    final bizName = businessAsync.value?.name ?? 'Business';
    final bizId = businessAsync.value?.id ??
        ref.read(currentBusinessIdProvider).value ??
        '';
    final bizTimeZone = businessAsync.value?.timeZone ?? 'Asia/Dubai';

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(context.tr('Quick Walk-in Booking')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Walk-in Header Banner
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_walk_rounded,
                          color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('Reception Walk-in Entry'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(context.tr('Create a booking for on-site clients arriving without the customer app.'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Customer Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Customer Name *',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Customer Phone Field
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      // Service Picker Dropdown
                      servicesAsync.when(
                        data: (services) {
                          final selectableServices = services
                              .where((service) =>
                                  service.isActive && service.isBookable)
                              .toList(growable: false);
                          if (_selectedService == null ||
                              !selectableServices.any(
                                (service) => service.id == _selectedService!.id,
                              )) {
                            _selectedService = selectableServices.isEmpty
                                ? null
                                : selectableServices.first;
                          }
                          return DropdownButtonFormField<ServiceModel>(
                            initialValue: _selectedService,
                            decoration: InputDecoration(
                              labelText: 'Select Service *',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              prefixIcon: const Icon(
                                  Icons.design_services_rounded,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor),
                              ),
                            ),
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            items: selectableServices.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.name} (AED ${s.effectivePrice.toStringAsFixed(0)} • ${s.duration})',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedService = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(
                            color: AppColors.primary),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 16),

                      // Employee Picker Dropdown
                      employeesAsync.when(
                        data: (staffList) {
                          final activeStaff = staffList
                              .where((staff) => staff.isActive)
                              .toList(growable: false);
                          if (_selectedStaff == null ||
                              !activeStaff.any(
                                (staff) => staff.id == _selectedStaff!.id,
                              )) {
                            _selectedStaff =
                                activeStaff.isEmpty ? null : activeStaff.first;
                          }
                          return DropdownButtonFormField<StaffModel>(
                            initialValue: _selectedStaff,
                            decoration: InputDecoration(
                              labelText: 'Assign Specialist *',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              prefixIcon: const Icon(Icons.badge_outlined,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor),
                              ),
                            ),
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            items: activeStaff.map((st) {
                              return DropdownMenuItem(
                                value: st,
                                child: Text(
                                  '${st.name} • ${st.roleTitle}',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedStaff = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(
                            color: AppColors.primary),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 16),

                      // Date & Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickDate(bizTimeZone),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded,
                                        size: 18,
                                        color: AppColors.primaryLight),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM d, yyyy')
                                          .format(_selectedDate),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 18, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notes Field
                      CustomTextField(
                        controller: _notesController,
                        label: 'Walk-in Notes (Optional)',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // Create Button
                      CustomButton(
                        text: 'Create Walk-in Booking',
                        isLoading: _isLoading,
                        onPressed: () => _submitWalkIn(bizId, bizName, bizTimeZone),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(String timeZone) async {
    final businessToday = BusinessClock.calendarToday(timeZone);
    final initialDate =
        _selectedDate.isBefore(businessToday) ? businessToday : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: businessToday,
      lastDate: businessToday.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Theme.of(context).colorScheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Theme.of(context).colorScheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (picked.minute % 15 != 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Please select a time in 15-minute increments.'),
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitWalkIn(
    String bizId,
    String bizName,
    String timeZone,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null || _selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Please select both a service and a specialist.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedTime.minute % 15 != 0) {
        throw StateError('Walk-in time must use a 15-minute interval.');
      }

      final startDt = BusinessClock.wallClock(
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        timeZone,
      );

      final endDt =
          startDt.add(Duration(minutes: _selectedService!.durationMinutes));

      final walkInBooking = BookingModel(
        id: '',
        customerId: 'walkin_${DateTime.now().millisecondsSinceEpoch}',
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        businessId: bizId,
        businessName: bizName,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        servicePrice: _selectedService!.effectivePrice,
        staffId: _selectedStaff!.id,
        staffName: _selectedStaff!.name,
        startDateTime: startDt,
        endDateTime: endDt,
        status: BookingStatus.confirmed,
        bookingSource: 'walkIn',
        notes: _notesController.text.trim(),
      );

      await ref
          .read(ownerBookingsProvider.notifier)
          .createWalkIn(walkInBooking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Walk-in booking created successfully!')),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Failed to create walk-in. Please try again.')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
