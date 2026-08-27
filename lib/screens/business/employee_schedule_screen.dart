import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/staff_model.dart';
import '../../models/staff_schedule_model.dart';
import '../../l10n/l10n.dart';

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
    final l10n = l10nOf(context);
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
          title: Text(l10n.employeeWorkingHours),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/owner-dashboard'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.event_busy_rounded),
              tooltip: l10n.timeOffAndAbsence,
              onPressed: () => context.push('/employee-time-off'),
            ),
          ],
        ),
        body: employeesAsync.when(
          data: (staffList) {
            if (staffList.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(l10n.addEmployeeBeforeSchedule),
                ),
              );
            }

            final selected = _resolveSelectedStaff(staffList);
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: EdgeInsets.all(14),
                    child: DropdownButtonFormField<String>(
                      initialValue: selected.id,
                      decoration: InputDecoration(
                        labelText: l10n.staffMember,
                        prefixIcon: Icon(Icons.badge_rounded),
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
                  SizedBox(height: 14),
                  Text(
                    l10n.weeklySchedule,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    l10n.employeeScheduleHelp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12),
                  ..._days.map(_buildDayCard),
                  SizedBox(height: 8),
                  CustomButton(
                    text: l10n.saveEmployeeSchedule,
                    isLoading: _isSaving,
                    onPressed: () => _save(selected),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              Center(child: Text(l10n.staffLoadError(error.toString()))),
        ),
      ),
    );
  }

  StaffModel _resolveSelectedStaff(List<StaffModel> staffList) {
    StaffModel selected;
    if (_selectedStaffId == null ||
        !staffList.any((s) => s.id == _selectedStaffId)) {
      selected = staffList.first;
      _selectedStaffId = selected.id;
      _loadSchedule(selected);
    } else {
      selected = staffList.firstWhere((s) => s.id == _selectedStaffId);
      if (_schedule.isEmpty) _loadSchedule(selected);
    }
    return selected;
  }

  String _localizedDay(String day) {
    final l10n = l10nOf(context);
    final index = _days.indexOf(day);
    return [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday
    ][index];
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
      padding: EdgeInsets.all(14),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _localizedDay(day),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                hours.isWorking
                    ? l10nOf(context).working
                    : l10nOf(context).dayOff,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hours.isWorking ? AppColors.success : AppColors.error,
                ),
              ),
              Switch(
                value: hours.isWorking,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.success,
                onChanged: (value) {
                  setState(() {
                    _schedule[day] = hours.copyWith(isWorking: value);
                  });
                },
              ),
            ],
          ),
          if (hours.isWorking) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ScheduleTimeButton(
                    label: l10nOf(context).shiftStarts,
                    value: _localizedTime(hours.openTime),
                    icon: Icons.login_rounded,
                    onTap: () => _pickTime(day, _TimeField.shiftStart),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ScheduleTimeButton(
                    label: l10nOf(context).shiftEnds,
                    value: _localizedTime(hours.closeTime),
                    icon: Icons.logout_rounded,
                    onTap: () => _pickTime(day, _TimeField.shiftEnd),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ScheduleTimeButton(
                    label: l10nOf(context).breakStarts,
                    value: _localizedTime(hours.breakStart ?? '01:00 PM'),
                    icon: Icons.free_breakfast_rounded,
                    onTap: () => _pickTime(day, _TimeField.breakStart),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ScheduleTimeButton(
                    label: l10nOf(context).breakEnds,
                    value: _localizedTime(hours.breakEnd ?? '02:00 PM'),
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

  String _localizedTime(String value) =>
      MaterialLocalizations.of(context).formatTimeOfDay(_parseTime(value));

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
        breakStart: field == _TimeField.breakStart ? value : current.breakStart,
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
          content: Text(l10nOf(context).employeeScheduleUpdated(staff.name)),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10nOf(context).employeeScheduleSaveFailed(e.toString())),
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
        padding: EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primaryLight),
            SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 9,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
