import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/employee_time_off_model.dart';
import '../../models/staff_model.dart';
import '../../providers/owner_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class EmployeeTimeOffScreen extends ConsumerStatefulWidget {
  const EmployeeTimeOffScreen({super.key});

  @override
  ConsumerState<EmployeeTimeOffScreen> createState() =>
      _EmployeeTimeOffScreenState();
}

class _EmployeeTimeOffScreenState extends ConsumerState<EmployeeTimeOffScreen> {
  final _reasonController = TextEditingController(text: 'Annual Vacation');
  StaffModel? _selectedStaff;
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeOffsAsync = ref.watch(ownerTimeOffsProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/employee-management');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/employee-management'),
          ),
          title: const Text('Employee Time Off & Leave'),
          actions: [
            IconButton(
              tooltip: 'Add Leave',
              icon: const Icon(Icons.add_rounded),
              onPressed: _showAddTimeOffModal,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ownerTimeOffsProvider);
            await ref.read(ownerTimeOffsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const GlassCard(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
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
                            'Scheduled leave blocks customer booking slots for the selected employee.',
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
                  const Expanded(
                    child: Text(
                      'Scheduled Leave Periods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _showAddTimeOffModal,
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('Add Leave'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              timeOffsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => OwnerEmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Leave Records',
                  description: 'Please check your connection and try again.',
                  actionLabel: 'Retry',
                  onActionTap: () => ref.invalidate(ownerTimeOffsProvider),
                ),
                data: (timeOffs) {
                  if (timeOffs.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.event_available_rounded,
                      title: 'No Time Off Scheduled',
                      description:
                          'All employees are currently on their standard working schedules.',
                      actionLabel: 'Schedule Leave',
                      onActionTap: _showAddTimeOffModal,
                    );
                  }

                  final sorted = [...timeOffs]
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));
                  return Column(
                    children: sorted.map(_leaveCard).toList(growable: false),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaveCard(EmployeeTimeOffModel timeOff) {
    final start = DateFormat('MMM d, yyyy').format(timeOff.startDate);
    final end = DateFormat('MMM d, yyyy').format(timeOff.endDate);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeOff.employeeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeOff.reason,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '$start – $end',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTimeOffModal() async {
    if (_isLoading) return;

    List<StaffModel> activeStaff;
    try {
      final allStaff = await ref.read(ownerEmployeesProvider.future);
      activeStaff = allStaff.where((staff) => staff.isActive).toList();
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to load employees. Please try again.', isError: true);
      }
      return;
    }

    if (!mounted) return;
    if (activeStaff.isEmpty) {
      _showMessage('Add an active employee before scheduling leave.', isError: true);
      return;
    }

    if (_selectedStaff == null ||
        !activeStaff.any((staff) => staff.id == _selectedStaff!.id)) {
      _selectedStaff = activeStaff.first;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  DropdownButtonFormField<StaffModel>(
                    initialValue: _selectedStaff,
                    decoration: const InputDecoration(
                      labelText: 'Select Employee',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    dropdownColor: AppColors.cardDark,
                    items: activeStaff
                        .map(
                          (staff) => DropdownMenuItem(
                            value: staff,
                            child: Text(staff.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setModalState(() => _selectedStaff = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _reasonController,
                    label: 'Reason (Vacation, Sick Leave, Day Off)',
                    prefixIcon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _dateButton(
                          label: 'Start',
                          date: _startDate,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: _startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked == null || !sheetContext.mounted) return;
                            setModalState(() {
                              _startDate = picked;
                              if (_endDate.isBefore(_startDate)) {
                                _endDate = _startDate;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dateButton(
                          label: 'End',
                          date: _endDate,
                          onTap: () async {
                            final initial = _endDate.isBefore(_startDate)
                                ? _startDate
                                : _endDate;
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate: initial,
                              firstDate: _startDate,
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked == null || !sheetContext.mounted) return;
                            setModalState(() => _endDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Save Leave Period',
                    isLoading: _isLoading,
                    onPressed: _isLoading
                        ? null
                        : () => _saveLeave(sheetContext, setModalState),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: Text('$label: ${DateFormat('MMM d').format(date)}'),
    );
  }

  Future<void> _saveLeave(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    final selectedStaff = _selectedStaff;
    if (selectedStaff == null) {
      _showMessage('Please select an employee.', isError: true);
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _showMessage('Please enter a reason for the leave.', isError: true);
      return;
    }

    setModalState(() => _isLoading = true);
    try {
      final businessId = await ref.read(currentBusinessIdProvider.future);
      if (businessId.isEmpty) {
        throw StateError('No business is linked to this owner account.');
      }

      final start = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
      );
      final end = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        23,
        59,
        59,
        999,
      );

      final newOff = EmployeeTimeOffModel(
        id: 'toff_${DateTime.now().microsecondsSinceEpoch}',
        businessId: businessId,
        employeeId: selectedStaff.id,
        employeeName: selectedStaff.name,
        startDate: start,
        endDate: end,
        reason: reason,
      );

      await ref.read(ownerRepositoryProvider).saveEmployeeTimeOff(newOff);
      ref.invalidate(ownerTimeOffsProvider);

      if (!sheetContext.mounted) return;
      Navigator.pop(sheetContext);
      if (mounted) _showMessage('Employee leave scheduled successfully.');
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to schedule employee leave. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (sheetContext.mounted) {
        setModalState(() => _isLoading = false);
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
