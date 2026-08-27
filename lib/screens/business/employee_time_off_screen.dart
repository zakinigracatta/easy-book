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

class _EmployeeTimeOffScreenState extends ConsumerState<EmployeeTimeOffScreen> {
  final _reasonController = TextEditingController(text: 'Annual Vacation');

  StaffModel? _selectedStaff;
  DateTime _startDate = DateTime.now().add(Duration(days: 3));
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/employee-management');
              }
            },
          ),
          title: Text('Employee Time Off & Leave'),
          actions: [
            IconButton(
              icon: Icon(Icons.add_rounded),
              onPressed: _showAddTimeOffModal,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Time-off periods automatically block customer booking slots for selected specialists.',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled Leave Periods',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _showAddTimeOffModal,
                    icon: Icon(Icons.add_rounded, size: 16),
                    label: Text('Add Leave',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              timeOffsAsync.when(
                data: (timeOffs) {
                  if (timeOffs.isEmpty) {
                    return OwnerEmptyStateWidget(
                      icon: Icons.event_available_rounded,
                      title: 'No Time Off Scheduled',
                      description:
                          'All employees are currently on standard working schedules.',
                      actionLabel: 'Schedule Leave',
                      onActionTap: _showAddTimeOffModal,
                    );
                  }

                  return Column(
                    children: timeOffs.map((t) {
                      final startStr =
                          DateFormat('MMM d, yyyy').format(t.startDate);
                      final endStr =
                          DateFormat('MMM d, yyyy').format(t.endDate);

                      return GlassCard(
                        padding: EdgeInsets.all(14),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              child: Icon(Icons.person_off_rounded,
                                  color: AppColors.warning),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.employeeName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    t.reason,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '$startStr – $endStr',
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
                      );
                    }).toList(),
                  );
                },
                loading: () => Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => OwnerEmptyStateWidget(
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

  void _showAddTimeOffModal() {
    final employeesAsync = ref.read(ownerEmployeesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Employee Time Off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                        labelText: 'Select Employee',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: staffList.map((st) {
                        return DropdownMenuItem(
                          value: st,
                          child: Text(st.name,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => _selectedStaff = val),
                    );
                  },
                  loading: () => SizedBox.shrink(),
                  error: (_, __) => SizedBox.shrink(),
                ),
                SizedBox(height: 14),
                CustomTextField(
                  controller: _reasonController,
                  label: 'Reason (Vacation, Sick Leave, Day Off)',
                  prefixIcon: Icons.notes_rounded,
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: sheetContext,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null && sheetContext.mounted) {
                            setModalState(() => _startDate = pickedDate);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Text(
                            'Start: ${DateFormat('MMM d').format(_startDate)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: sheetContext,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null && sheetContext.mounted) {
                            setModalState(() => _endDate = pickedDate);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Text(
                            'End: ${DateFormat('MMM d').format(_endDate)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: 'Save Leave Period',
                  isLoading: _isLoading,
                  onPressed: () async {
                    final selectedStaff = _selectedStaff;
                    if (selectedStaff == null) return;
                    setModalState(() => _isLoading = true);

                    final newOff = EmployeeTimeOffModel(
                      id: 'toff_${DateTime.now().millisecondsSinceEpoch}',
                      employeeId: selectedStaff.id,
                      employeeName: selectedStaff.name,
                      startDate: _startDate,
                      endDate: _endDate,
                      reason: _reasonController.text.trim(),
                    );

                    try {
                      await ref
                          .read(ownerRepositoryProvider)
                          .saveEmployeeTimeOff(newOff);
                      ref.invalidate(ownerTimeOffsProvider);

                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Employee leave scheduled!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
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
