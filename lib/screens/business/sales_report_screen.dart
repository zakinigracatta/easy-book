import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../providers/owner_providers.dart';
import '../../models/booking_model.dart';

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);
    final servicesAsync = ref.watch(ownerServicesProvider);
    final staffAsync = ref.watch(ownerEmployeesProvider);

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
          title: const Text('Sales & Business Analytics'),
        ),
        body: bookingsAsync.when(
          data: (bookings) {
            final now = DateTime.now();

            final todayBookings = bookings
                .where((b) =>
                    b.startDateTime.year == now.year &&
                    b.startDateTime.month == now.month &&
                    b.startDateTime.day == now.day)
                .toList();

            final todayRev = todayBookings
                .where((b) => b.status != BookingStatus.cancelled)
                .fold<double>(0.0, (sum, b) => sum + b.servicePrice);

            final monthBookings = bookings
                .where((b) =>
                    b.startDateTime.year == now.year &&
                    b.startDateTime.month == now.month)
                .toList();

            final monthRev = monthBookings
                .where((b) => b.status != BookingStatus.cancelled)
                .fold<double>(0.0, (sum, b) => sum + b.servicePrice);

            final completedCount = bookings
                .where((b) => b.status == BookingStatus.completed)
                .length;

            final cancelledCount = bookings
                .where((b) => b.status == BookingStatus.cancelled)
                .length;

            final noShowCount =
                bookings.where((b) => b.status == BookingStatus.noShow).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Sales MTD Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Revenue (This Month)',
                          style: TextStyle(
                            color: AppColors.textMutedDark,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GradientText(
                          'AED ${monthRev.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.trending_up_rounded,
                                color: AppColors.success, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '+18.5% growth compared to last month',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Today vs Month Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _statBox(
                            "Today's Revenue",
                            'AED ${todayRev.toStringAsFixed(0)}',
                            AppColors.success),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statBox('Bookings Today',
                            '${todayBookings.length}', AppColors.primaryLight),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statBox(
                            'Completed', '$completedCount', AppColors.success),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statBox(
                            'Cancelled', '$cancelledCount', AppColors.error),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statBox(
                            'No Shows', '$noShowCount', AppColors.warning),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Revenue Bar Chart Visual
                  const Text(
                    'Weekly Revenue Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 2000,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ];
                                  final index = val.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: const TextStyle(
                                          color: AppColors.textMutedDark,
                                          fontSize: 11),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: [
                            _makeBarGroup(0, 1100),
                            _makeBarGroup(1, 1450),
                            _makeBarGroup(2, 980),
                            _makeBarGroup(3, 1620),
                            _makeBarGroup(4, 1950),
                            _makeBarGroup(5, 1800),
                            _makeBarGroup(6, 1240),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Performing Services
                  const Text(
                    'Top Performing Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  servicesAsync.maybeWhen(
                    data: (services) => Column(
                      children: services.take(3).map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.star_outline_rounded,
                                  color: AppColors.gold),
                              title: Text(s.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark)),
                              subtitle: Text('${s.duration} • AED ${s.price}'),
                              trailing: const Text('74 bookings',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Top Employees Ranking
                  const Text(
                    'Top Specialists',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  staffAsync.maybeWhen(
                    data: (staffList) => Column(
                      children: staffList.take(2).map((st) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(st.name[0]),
                              ),
                              title: Text(st.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark)),
                              subtitle: Text(st.roleTitle),
                              trailing: Text('${st.rating} ★',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => const SizedBox.shrink(),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  Widget _statBox(String label, String val, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 14,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
