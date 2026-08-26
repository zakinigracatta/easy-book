import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/working_hours_model.dart';
import '../../models/business_model.dart';
import '../../l10n/app_localizations.dart';

class BusinessWorkingHoursScreen extends ConsumerStatefulWidget {
  BusinessWorkingHoursScreen({super.key});

  @override
  ConsumerState<BusinessWorkingHoursScreen> createState() =>
      _BusinessWorkingHoursScreenState();
}

class _BusinessWorkingHoursScreenState
    extends ConsumerState<BusinessWorkingHoursScreen> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, DailyHours> _hoursMap = {};
  bool _initialized = false;
  bool _isLoading = false;

  void _initializeFromBusiness(BusinessModel business) {
    if (_initialized) return;
    for (final day in _days) {
      _hoursMap[day] = business.workingHours.schedule[day] ??
          DailyHours(
            dayName: day,
            openTime: '09:00 AM',
            closeTime: '06:00 PM',
          );
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(ownerBusinessProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Business Working Hours')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
        ),
        body: businessAsync.when(
          data: (business) {
            _initializeFromBusiness(business);
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            color: AppColors.primaryLight, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('Operating Hours'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(context.tr('Set exact opening and closing times. Customer availability follows these hours.'),
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
                  SizedBox(height: 16),
                  ..._days.map(_buildDayCard),
                  SizedBox(height: 8),
                  CustomButton(
                    text: 'Save Working Hours',
                    isLoading: _isLoading,
                    onPressed: () => _save(business),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Unable to load working hours: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final hours = _hoursMap[day]!;
    return GlassCard(
      padding: EdgeInsets.all(14),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                hours.isClosed ? 'Closed' : 'Open',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hours.isClosed ? AppColors.error : AppColors.success,
                ),
              ),
              SizedBox(width: 6),
              Switch(
                value: !hours.isClosed,
                activeColor: AppColors.primary,
                onChanged: (open) {
                  setState(() {
                    _hoursMap[day] = DailyHours(
                      dayName: day,
                      openTime: hours.openTime,
                      closeTime: hours.closeTime,
                      isClosed: !open,
                    );
                  });
                },
              ),
            ],
          ),
          if (!hours.isClosed) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Opens',
                    value: hours.openTime,
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => _pickTime(day, isOpening: true),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TimeButton(
                    label: 'Closes',
                    value: hours.closeTime,
                    icon: Icons.nightlight_outlined,
                    onTap: () => _pickTime(day, isOpening: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime(String day, {required bool isOpening}) async {
    final current = _hoursMap[day]!;
    final initial = _parseTime(isOpening ? current.openTime : current.closeTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpening ? 'Select opening time' : 'Select closing time',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _hoursMap[day] = DailyHours(
        dayName: day,
        openTime: isOpening ? _formatTime(picked) : current.openTime,
        closeTime: isOpening ? current.closeTime : _formatTime(picked),
        isClosed: current.isClosed,
      );
    });
  }

  Future<void> _save(BusinessModel business) async {
    setState(() => _isLoading = true);
    try {
      final updated = business.copyWith(
        workingHours: WorkingHoursModel(schedule: Map.of(_hoursMap)),
      );
      await ref.read(ownerBusinessProvider.notifier).updateBusiness(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Business working hours updated.')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update working hours: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

class _TimeButton extends StatelessWidget {
  const _TimeButton({
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryLight),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
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
