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
import '../../l10n/l10n.dart';

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
    final l10n = l10nOf(context);
    final servicesAsync = ref.watch(ownerServicesProvider);
    final employeesAsync = ref.watch(ownerEmployeesProvider);
    final businessAsync = ref.watch(ownerBusinessProvider);

    final bizName = businessAsync.value?.name ?? l10n.business;
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(l10n.quickWalkInBooking),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: EdgeInsets.all(16),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk_rounded,
                          color: AppColors.gold, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.receptionWalkInEntry,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              l10n.receptionWalkInDescription,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewCustomer = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isNewCustomer
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isNewCustomer
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.outline),
                          ),
                          child: Text(
                            l10n.newCustomer,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isNewCustomer
                                  ? Colors.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewCustomer = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isNewCustomer
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: !_isNewCustomer
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.outline),
                          ),
                          child: Text(
                            l10n.existingCustomer,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !_isNewCustomer
                                  ? Colors.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GlassCard(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: l10n.customerNameRequiredLabel,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l10n.enterCustomerName;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        label: l10n.phoneNumber,
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),
                      servicesAsync.when(
                        data: (services) {
                          if (_selectedService == null && services.isNotEmpty) {
                            _selectedService = services.first;
                          }
                          return DropdownButtonFormField<ServiceModel>(
                            initialValue: _selectedService,
                            decoration: InputDecoration(
                              labelText: l10n.selectServiceRequiredLabel,
                              labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              prefixIcon: Icon(Icons.design_services_rounded,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                            ),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            items: services.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.name} (AED ${s.price.toStringAsFixed(0)} • ${s.duration})',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedService = val),
                          );
                        },
                        loading: () =>
                            LinearProgressIndicator(color: AppColors.primary),
                        error: (_, __) => SizedBox.shrink(),
                      ),
                      SizedBox(height: 16),
                      employeesAsync.when(
                        data: (staffList) {
                          if (_selectedStaff == null && staffList.isNotEmpty) {
                            _selectedStaff = staffList.first;
                          }
                          return DropdownButtonFormField<StaffModel>(
                            initialValue: _selectedStaff,
                            decoration: InputDecoration(
                              labelText: l10n.assignSpecialistRequiredLabel,
                              labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              prefixIcon: Icon(Icons.badge_outlined,
                                  color: AppColors.primaryLight),
                              filled: true,
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                            ),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            items: staffList.map((st) {
                              return DropdownMenuItem(
                                value: st,
                                child: Text(
                                  '${st.name} • ${st.roleTitle}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedStaff = val),
                          );
                        },
                        loading: () =>
                            LinearProgressIndicator(color: AppColors.primary),
                        error: (_, __) => SizedBox.shrink(),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded,
                                        size: 18,
                                        color: AppColors.primaryLight),
                                    SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'MMM d, yyyy',
                                        Localizations.localeOf(context)
                                            .toLanguageTag(),
                                      ).format(_selectedDate),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickTime,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 18, color: AppColors.accent),
                                    SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _notesController,
                        label: l10n.walkInNotesOptional,
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      SizedBox(height: 24),
                      CustomButton(
                        text: l10n.createWalkInBooking,
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
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
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
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Theme.of(context).colorScheme.surface,
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
        SnackBar(
          content: Text(l10nOf(context).selectServiceAndSpecialist),
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
          SnackBar(
            content: Text(l10nOf(context).walkInCreated),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nOf(context).walkInCreateFailed('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
