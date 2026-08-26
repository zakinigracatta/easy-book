import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/staff_model.dart';
import '../../models/staff_schedule_model.dart';
import '../../providers/owner_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class EmployeeScheduleScreen extends ConsumerStatefulWidget {
  const EmployeeScheduleScreen({super.key});

  @override
  ConsumerState<EmployeeScheduleScreen> createState() =>
      _EmployeeScheduleScreenState();
}

class _EmployeeScheduleScreenState
    extends ConsumerState<EmployeeScheduleScreen> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String? _selectedStaffId;
  final Map<String, StaffWorkingHours> _schedule = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(ownerEmployeesProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Employee Working Hours')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.event_busy_rounded),
              tooltip: context.tr('Time Off / Leave'),
              onPressed: () => context.push('/employee-time-off'),
            ),
          ],
        ),
        body: employeesAsync.when(
          data: (staffList) {
            if (staffList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.tr(
                      'Add an employee before configuring working hours.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final selected = _resolveSelectedStaff(staffList);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: DropdownButtonFormField<String>(
                      initialValue: selected.id,
                      decoration: InputDecoration(
                        labelText: context.tr('Staff member'),
                        prefixIcon: const Icon(Icons.badge_rounded),
                      ),
                      items: staffList
                          .map(
                            (staff) => DropdownMenuItem(
                              value: staff.id,
                              child: Text(staff.name),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final staff = staffList.firstWhere((s) => s.id == id);
                        setState(() {
                          _selectedStaffId = id;
                          _loadSchedule(staff, force: true);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('Weekly schedule'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(
                      'These hours directly control when customers can book this employee.',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._days.map(_buildDayCard),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'Save Employee Schedule',
                    isLoading: _isSaving,
                    onPressed: () => _save(selected),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(
            child: Text(
              context.tr('Unable to load employees. Please try again.'),
            ),
          ),
        ),
      ),
    );
  }

  StaffModel _resolveSelectedStaff(List<StaffModel> staffList) {
    StaffModel selected;
    if (_selectedStaffId == null ||
        !staffList.any((staff) => staff.id == _selectedStaffId)) {
      selected = staffList.first;
      _selectedStaffId = selected.id;
      _loadSchedule(selected);
    } else {
      selected = staffList.firstWhere((staff) => staff.id == _selectedStaffId);
      if (_schedule.isEmpty) _loadSchedule(selected);
    }
    return selected;
  }

  void _loadSchedule(StaffModel staff, {bool force = false}) {
    if (_schedule.isNotEmpty && !force) return;
    _schedule.clear();

    for (var i = 0; i < _days.length; i++) {
      final day = _days[i];
      final existing = staff.weeklySchedule[day];
      if (existing != null) {
        _schedule[day] = existing;
        continue;
      }

      final weekday = i + 1;
      final working = staff.workingDays == null ||
          staff.workingDays!.isEmpty ||
          staff.workingDays!.contains(weekday);
      _schedule[day] = StaffWorkingHours(
        dayName: day,
        openTime: staff.shiftStart ?? '09:00 AM',
        closeTime: staff.shiftEnd ?? '06:00 PM',
        isWorking: working,
        breakStart: working ? '01:00 PM' : null,
        breakEnd: working ? '02:00 PM' : null,
      );
    }
  }

  Widget _buildDayCard(String day) {
    final hours = _schedule[day]!;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(day),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
              Text(
                context.tr(hours.isWorking ? 'Working' : 'Day Off'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hours.isWorking ? AppColors.success : AppColors.error,
                ),
              ),
              Switch(
                value: hours.isWorking,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _schedule[day] = hours.copyWith(isWorking: value);
                  });
                },
              ),
            ],
          ),
          if (hours.isWorking) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ScheduleTimeButton(
                    label: 'Shift starts',
                    value: _displayTime(hours.openTime),
                    icon: Icons.login_rounded,
                    onTap: () => _pickTime(day, _TimeField.shiftStart),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ScheduleTimeButton(
                    label: 'Shift ends',
                    value: _displayTime(hours.closeTime),
                    icon: Icons.logout_rounded,
                    onTap: () => _pickTime(day, _TimeField.shiftEnd),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ScheduleTimeButton(
                    label: 'Break starts',
                    value: _displayTime(hours.breakStart ?? '01:00 PM'),
                    icon: Icons.free_breakfast_rounded,
                    onTap: () => _pickTime(day, _TimeField.breakStart),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ScheduleTimeButton(
                    label: 'Break ends',
                    value: _displayTime(hours.breakEnd ?? '02:00 PM'),
                    icon: Icons.play_arrow_rounded,
                    onTap: () => _pickTime(day, _TimeField.breakEnd),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime(String day, _TimeField field) async {
    final current = _schedule[day]!;
    final raw = switch (field) {
      _TimeField.shiftStart => current.openTime,
      _TimeField.shiftEnd => current.closeTime,
      _TimeField.breakStart => current.breakStart ?? '01:00 PM',
      _TimeField.breakEnd => current.breakEnd ?? '02:00 PM',
    };
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(raw),
    );
    if (picked == null || !mounted) return;

    final value = _formatTime(picked);
    setState(() {
      _schedule[day] = StaffWorkingHours(
        dayName: day,
        openTime: field == _TimeField.shiftStart ? value : current.openTime,
        closeTime: field == _TimeField.shiftEnd ? value : current.closeTime,
        isWorking: current.isWorking,
        breakStart:
            field == _TimeField.breakStart ? value : current.breakStart,
        breakEnd: field == _TimeField.breakEnd ? value : current.breakEnd,
      );
    });
  }

  Future<void> _save(StaffModel staff) async {
    setState(() => _isSaving = true);
    try {
      final workingDays = <int>[];
      for (var i = 0; i < _days.length; i++) {
        if (_schedule[_days[i]]?.isWorking == true) workingDays.add(i + 1);
      }

      final firstWorking = _days
          .map((day) => _schedule[day]!)
          .where((hours) => hours.isWorking)
          .cast<StaffWorkingHours?>()
          .firstOrNull;

      final updated = staff.copyWith(
        weeklySchedule: Map.of(_schedule),
        workingDays: workingDays,
        shiftStart: firstWorking?.openTime ?? staff.shiftStart,
        shiftEnd: firstWorking?.closeTime ?? staff.shiftEnd,
      );

      await ref.read(ownerEmployeesProvider.notifier).saveEmployee(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Employee schedule updated successfully.',
            ),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Failed to save employee schedule. Please try again.'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  TimeOfDay _parseTime(String raw) {
    final clean = raw.trim().toUpperCase();
    final isPm = clean.contains('PM');
    final isAm = clean.contains('AM');
    final numeric = clean.replaceAll(RegExp(r'[^\d:]'), '');
    final parts = numeric.split(':');
    var hour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return TimeOfDay(
      hour: hour.clamp(0, 23).toInt(),
      minute: minute.clamp(0, 59).toInt(),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _displayTime(String raw) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      _parseTime(raw),
      alwaysUse24HourFormat:
          MediaQuery.alwaysUse24HourFormatOf(context) ||
              Localizations.localeOf(context).languageCode == 'ru',
    );
  }
}

enum _TimeField { shiftStart, shiftEnd, breakStart, breakEnd }

class _ScheduleTimeButton extends StatelessWidget {
  const _ScheduleTimeButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.glassBgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorderDark),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primaryLight),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(label),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
