import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/employee_time_off_model.dart';
import '../../models/staff_model.dart';

class EmployeeTimeOffScreen extends ConsumerStatefulWidget {
  const EmployeeTimeOffScreen({super.key});

  @override
  ConsumerState<EmployeeTimeOffScreen> createState() =>
      _EmployeeTimeOffScreenState();
}

class _EmployeeTimeOffScreenState
    extends ConsumerState<EmployeeTimeOffScreen> {
  final _reasonController = TextEditingController(text: 'Annual Vacation');
  final _notesController = TextEditingController();

  StaffModel? _selectedStaff;
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(ownerEmployeesProvider);
    final timeOffsAsync = ref.watch(ownerTimeOffsProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/employee-management');
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
                context.go('/employee-management');
              }
            },
          ),
          title: const Text('Employee Time Off & Leave'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddTimeOffModal(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.event_busy_rounded,
                        color: AppColors.gold, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Leave Manager',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Time-off periods automatically block customer booking slots for selected specialists.',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scheduled Leave Periods',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showAddTimeOffModal(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Leave',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              timeOffsAsync.when(
                data: (timeOffs) {
                  if (timeOffs.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.event_available_rounded,
                      title: 'No Time Off Scheduled',
                      description:
                          'All employees are currently on standard working schedules.',
                      actionLabel: 'Schedule Leave',
                      onActionTap: () => _showAddTimeOffModal(context),
                    );
                  }

                  return Column(
                    children: timeOffs.map((t) {
                      final startStr = DateFormat('MMM d, yyyy').format(t.startDate);
                      final endStr = DateFormat('MMM d, yyyy').format(t.endDate);

                      return GlassCard(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.cardDark,
                              child: Icon(Icons.person_off_rounded,
                                  color: AppColors.warning),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.employeeName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.reason,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$startStr – $endStr',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMutedDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Leave Records',
                  description: 'Failed to retrieve employee time off entries.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTimeOffModal(BuildContext context) {
    final employeesAsync = ref.read(ownerEmployeesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule Employee Time Off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Employee Selector
                employeesAsync.when(
                  data: (staffList) {
                    if (_selectedStaff == null && staffList.isNotEmpty) {
                      _selectedStaff = staffList.first;
                    }
                    return DropdownButtonFormField<StaffModel>(
                      value: _selectedStaff,
                      decoration: const InputDecoration(
                        labelText: 'Select Employee',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      dropdownColor: AppColors.cardDark,
                      items: staffList.map((st) {
                        return DropdownMenuItem(
                          value: st,
                          child: Text(st.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimaryDark)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => _selectedStaff = val),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _reasonController,
                  label: 'Reason (Vacation, Sick Leave, Day Off)',
                  prefixIcon: Icons.notes_rounded,
                ),

                const SizedBox(height: 14),

                // Start & End Dates
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (p != null) setModalState(() => _startDate = p);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorderDark),
                          ),
                          child: Text(
                            'Start: ${DateFormat('MMM d').format(_startDate)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textPrimaryDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final p = await showDatePicker(
                            context: ctx,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (p != null) setModalState(() => _endDate = p);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorderDark),
                          ),
                          child: Text(
                            'End: ${DateFormat('MMM d').format(_endDate)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textPrimaryDark),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                CustomButton(
                  text: 'Save Leave Period',
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_selectedStaff == null) return;
                    setModalState(() => _isLoading = true);

                    final newOff = EmployeeTimeOffModel(
                      id: 'toff_${DateTime.now().millisecondsSinceEpoch}',
                      employeeId: _selectedStaff!.id,
                      employeeName: _selectedStaff!.name,
                      startDate: _startDate,
                      endDate: _endDate,
                      reason: _reasonController.text.trim(),
                    );

                    await ref
                        .read(ownerRepositoryProvider)
                        .saveEmployeeTimeOff(newOff);
                    ref.invalidate(ownerTimeOffsProvider);

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Employee leave scheduled!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
