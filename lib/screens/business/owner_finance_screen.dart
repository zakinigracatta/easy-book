import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../providers/owner_finance_providers.dart';
import '../../repositories/owner_finance_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import 'owner_expenses_screen.dart';

class OwnerFinanceScreen extends ConsumerWidget {
  const OwnerFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(ownerProfitAndLossProvider);
    final range = ref.watch(ownerFinanceReportRangeProvider);
    final currency = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);
    final date = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance & Profit'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(ownerProfitAndLossProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerProfitAndLossProvider);
          await ref.read(ownerProfitAndLossProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reporting Period',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${date.format(range.from)} — ${date.format(range.to)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _selectRange(context, ref, range),
                        icon: const Icon(Icons.date_range_rounded, size: 18),
                        label: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _periodButton(ref, 'Today', _todayRange()),
                      _periodButton(ref, 'This Month', _monthRange()),
                      _periodButton(ref, 'This Year', _yearRange()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            reportAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => _errorCard(error),
              data: (report) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          'Recognized Revenue',
                          currency.format(report.recognizedRevenue),
                          Icons.trending_up_rounded,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metricCard(
                          'Expenses',
                          currency.format(report.expenses),
                          Icons.trending_down_rounded,
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          'Net Profit',
                          currency.format(report.netProfit),
                          report.netProfit >= 0
                              ? Icons.account_balance_wallet_rounded
                              : Icons.warning_amber_rounded,
                          report.netProfit >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metricCard(
                          'Profit Margin',
                          '${report.profitMarginPercent.toStringAsFixed(1)}%',
                          Icons.percent_rounded,
                          AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expense Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildExpenseRows(report, currency),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const OwnerExpensesScreen(),
                  ),
                );
                ref.invalidate(ownerProfitAndLossProvider);
              },
              child: const ListTile(
                leading: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  'Manage Expenses',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                subtitle: Text(
                  'Add, edit and archive owner-only business costs',
                ),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const GlassCard(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primaryLight, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Revenue is recognized only from completed bookings in this version. Payment-status accounting will replace this rule when the payment module is connected.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
    );
  }

  List<Widget> _buildExpenseRows(
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.expensesByCategory.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              'No expenses recorded in this period.',
              style: TextStyle(color: AppColors.textMutedDark),
            ),
          ),
        ),
      ];
    }

    final entries = report.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key.label,
                    style: const TextStyle(color: AppColors.textPrimaryDark),
                  ),
                ),
                Text(
                  currency.format(entry.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(growable: false);
  }

  Widget _metricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
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

  Widget _errorCard(Object error) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: AppColors.error, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Finance data unavailable',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton(
    WidgetRef ref,
    String label,
    FinanceReportRange range,
  ) {
    return OutlinedButton(
      onPressed: () {
        ref.read(ownerFinanceReportRangeProvider.notifier).state = range;
      },
      child: Text(label),
    );
  }

  Future<void> _selectRange(
    BuildContext context,
    WidgetRef ref,
    FinanceReportRange current,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: current.from, end: current.to),
    );
    if (picked == null) return;

    ref.read(ownerFinanceReportRangeProvider.notifier).state =
        FinanceReportRange(from: picked.start, to: picked.end);
  }

  FinanceReportRange _todayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return FinanceReportRange(from: today, to: today);
  }

  FinanceReportRange _monthRange() {
    final now = DateTime.now();
    return FinanceReportRange(
      from: DateTime(now.year, now.month, 1),
      to: DateTime(now.year, now.month, now.day),
    );
  }

  FinanceReportRange _yearRange() {
    final now = DateTime.now();
    return FinanceReportRange(
      from: DateTime(now.year, 1, 1),
      to: DateTime(now.year, now.month, now.day),
    );
  }
}
