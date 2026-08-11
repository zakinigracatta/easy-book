import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../providers/owner_providers.dart';

class EmployeeScheduleScreen extends ConsumerStatefulWidget {
  const EmployeeScheduleScreen({super.key});

  @override
  ConsumerState<EmployeeScheduleScreen> createState() =>
      _EmployeeScheduleScreenState();
}

class _EmployeeScheduleScreenState
    extends ConsumerState<EmployeeScheduleScreen> {
  final Map<String, ({bool isWorking, String open, String close, String breakStart, String breakEnd})>
      _weeklySchedule = {
    'Monday': (isWorking: true, open: '09:00 AM', close: '08:00 PM', breakStart: '01:00 PM', breakEnd: '02:00 PM'),
    'Tuesday': (isWorking: true, open: '09:00 AM', close: '08:00 PM', breakStart: '01:00 PM', breakEnd: '02:00 PM'),
    'Wednesday': (isWorking: true, open: '09:00 AM', close: '08:00 PM', breakStart: '01:00 PM', breakEnd: '02:00 PM'),
    'Thursday': (isWorking: true, open: '09:00 AM', close: '08:00 PM', breakStart: '01:00 PM', breakEnd: '02:00 PM'),
    'Friday': (isWorking: true, open: '02:00 PM', close: '11:00 PM', breakStart: '05:00 PM', breakEnd: '06:00 PM'),
    'Saturday': (isWorking: true, open: '10:00 AM', close: '09:00 PM', breakStart: '02:00 PM', breakEnd: '03:00 PM'),
    'Sunday': (isWorking: false, open: '09:00 AM', close: '05:00 PM', breakStart: '01:00 PM', breakEnd: '02:00 PM'),
  };

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(ownerEmployeesProvider);

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
          title: const Text('Employee Working Hours & Breaks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.event_busy_rounded),
              tooltip: 'Time Off / Leave',
              onPressed: () => context.push('/employee-time-off'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Selector Header
              employeesAsync.when(
                data: (staffList) {
                  return GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_rounded,
                            color: AppColors.primaryLight),
                        const SizedBox(width: 10),
                        const Text(
                          'Staff Member: ',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMutedDark),
                        ),
                        Expanded(
                          child: Text(
                            staffList.isNotEmpty
                                ? staffList.first.name
                                : 'All Specialists',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/employee-time-off'),
                          child: const Text('Time Off',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              const Text(
                'Weekly Shifts & Break Times',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 10),

              // Weekdays List
              ..._weeklySchedule.entries.map((entry) {
                final day = entry.key;
                final data = entry.value;

                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: data.isWorking
                                      ? AppColors.success
                                          .withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  data.isWorking ? 'Working' : 'Day Off',
                                  style: TextStyle(
                                    color: data.isWorking
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: data.isWorking,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _weeklySchedule[day] = (
                                  isWorking: val,
                                  open: data.open,
                                  close: data.close,
                                  breakStart: data.breakStart,
                                  breakEnd: data.breakEnd,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      if (data.isWorking) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded,
                                size: 14, color: AppColors.primaryLight),
                            const SizedBox(width: 6),
                            Text(
                              'Shift: ${data.open} – ${data.close}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.free_breakfast_rounded,
                                size: 14, color: AppColors.gold),
                            const SizedBox(width: 6),
                            Text(
                              'Break: ${data.breakStart} – ${data.breakEnd}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMutedDark),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
