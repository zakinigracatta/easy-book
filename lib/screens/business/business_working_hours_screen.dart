import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../providers/owner_providers.dart';
import '../../models/working_hours_model.dart';
import '../../models/business_model.dart';
import '../../l10n/l10n.dart';

class BusinessWorkingHoursScreen extends ConsumerStatefulWidget {
  const BusinessWorkingHoursScreen({super.key});

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
    final l10n = l10nOf(context);
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
          title: Text(l10n.businessWorkingHours),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/owner-dashboard'),
          ),
        ),
        body: businessAsync.when(
          data: (business) {
            _initializeFromBusiness(business);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.primaryLight, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.operatingHours,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.businessHoursHelp,
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
                  const SizedBox(height: 16),
                  ..._days.map(_buildDayCard),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: l10n.saveWorkingHours,
                    isLoading: _isLoading,
                    onPressed: () => _save(business),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.workingHoursLoadFailed(error.toString())),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final hours = _hoursMap[day]!;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
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
                hours.isClosed ? l10nOf(context).closed : l10nOf(context).open,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hours.isClosed ? AppColors.error : AppColors.success,
                ),
              ),
              const SizedBox(width: 6),
              Switch(
                value: !hours.isClosed,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.success,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: l10nOf(context).opens,
                    value: _localizedTime(hours.openTime),
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => _pickTime(day, isOpening: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimeButton(
                    label: l10nOf(context).closes,
                    value: _localizedTime(hours.closeTime),
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

  Future<void> _pickTime(String day, {required bool isOpening}) async {
    final current = _hoursMap[day]!;
    final initial =
        _parseTime(isOpening ? current.openTime : current.closeTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpening
          ? l10nOf(context).selectOpeningTime
          : l10nOf(context).selectClosingTime,
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
          content: Text(l10nOf(context).businessHoursUpdated),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10nOf(context).businessHoursUpdateFailed(e.toString())),
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

  String _localizedTime(String value) =>
      MaterialLocalizations.of(context).formatTimeOfDay(_parseTime(value));
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
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outline),
          color: colors.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10, color: colors.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
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
