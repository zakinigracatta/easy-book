import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';
import '../../models/staff_model.dart';

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

  bool _isNewCustomer = true;
  ServiceModel? _selectedService;
  StaffModel? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(ownerServicesProvider);
    final employeesAsync = ref.watch(ownerEmployeesProvider);
    final businessAsync = ref.watch(ownerBusinessProvider);

    final bizName = businessAsync.value?.name ?? 'Business';
    final bizId = businessAsync.value?.id ??
        ref.read(currentBusinessIdProvider).value ??
        '';

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
          title: const Text('Quick Walk-in Booking'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_walk_rounded,
                          color: AppColors.gold, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reception Walk-in Entry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Create a booking for on-site clients arriving without the customer app.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMutedDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewCustomer = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isNewCustomer
                                ? AppColors.primary
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isNewCustomer
                                    ? AppColors.primary
                                    : AppColors.glassBorderDark),
                          ),
                          child: Text(
                            'New Customer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isNewCustomer
                                  ? Colors.white
                                  : AppColors.textMutedDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewCustomer = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isNewCustomer
                                ? AppColors.primary
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: !_isNewCustomer
                                    ? AppColors.primary
                                    : AppColors.glassBorderDark),
                          ),
                          child: Text(
                            'Existing Customer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !_isNewCustomer
                                  ? Colors.white
                                  : AppColors.textMutedDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      servicesAsync.when(
                        data: (services) {
                          if (_selectedService == null && services.isNotEmpty) {
                            _selectedService = services.first;
                          }
                          return DropdownButtonFormField<ServiceModel>(
                            initialValue: _selectedService,
                            decoration: InputDecoration(
                              labelText: 'Select Service *',
                              labelStyle: const TextStyle(
                                  color: AppColors.textMutedDark),
                              prefixIcon: const Icon(
                                  Icons.design_services_rounded,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor: AppColors.bgDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.glassBorderDark),
                              ),
                            ),
                            dropdownColor: AppColors.cardDark,
                            items: services.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.name} (AED ${s.price.toStringAsFixed(0)} • ${s.duration})',
                                  style: const TextStyle(
                                      color: AppColors.textPrimaryDark,
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
                      employeesAsync.when(
                        data: (staffList) {
                          if (_selectedStaff == null && staffList.isNotEmpty) {
                            _selectedStaff = staffList.first;
                          }
                          return DropdownButtonFormField<StaffModel>(
                            initialValue: _selectedStaff,
                            decoration: InputDecoration(
                              labelText: 'Assign Specialist *',
                              labelStyle: const TextStyle(
                                  color: AppColors.textMutedDark),
                              prefixIcon: const Icon(Icons.badge_outlined,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor: AppColors.bgDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.glassBorderDark),
                              ),
                            ),
                            dropdownColor: AppColors.cardDark,
                            items: staffList.map((st) {
                              return DropdownMenuItem(
                                value: st,
                                child: Text(
                                  '${st.name} • ${st.roleTitle}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimaryDark,
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
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.bgDark,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.glassBorderDark),
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
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimaryDark,
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
                                  color: AppColors.bgDark,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.glassBorderDark),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 18, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimaryDark,
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
                      CustomTextField(
                        controller: _notesController,
                        label: 'Walk-in Notes (Optional)',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Create Walk-in Booking',
                        isLoading: _isLoading,
                        onPressed: () => _submitWalkIn(bizId, bizName),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.cardDark,
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
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitWalkIn(String bizId, String bizName) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null || _selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a service and a specialist.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
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
        servicePrice:
            _selectedService!.discountPrice ?? _selectedService!.price,
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
          const SnackBar(
            content: Text('Walk-in booking created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create walk-in: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
