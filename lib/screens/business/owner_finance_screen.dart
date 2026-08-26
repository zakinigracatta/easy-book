import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../l10n/app_localizations.dart';
import '../../models/expense_model.dart';
import '../../models/profit_and_loss_summary.dart';
import '../../providers/owner_finance_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import 'owner_expenses_screen.dart';

class OwnerFinanceScreen extends ConsumerWidget {
  OwnerFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(ownerProfitAndLossProvider);
    final range = ref.watch(ownerFinanceReportRangeProvider);
    final currency = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Finance & Profit')),
        actions: [
          IconButton(
            tooltip: context.tr('Refresh'),
            onPressed: () => ref.invalidate(ownerProfitAndLossProvider),
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerProfitAndLossProvider);
          await ref.read(ownerProfitAndLossProvider.future);
        },
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _periodCard(context, ref, range),
            SizedBox(height: 16),
            reportAsync.when(
              loading: () => Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => _errorCard(context, ref),
              data: (report) => _reportBody(context, report, currency),
            ),
            SizedBox(height: 18),
            GlassCard(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OwnerExpensesScreen(),
                  ),
                );
                ref.invalidate(ownerProfitAndLossProvider);
              },
              child: ListTile(
                leading: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  context.tr('Manage Expenses'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  context.tr('Add, edit and archive owner-only business costs'),
                ),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ),
            SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr(
                        'Revenue is recognized only from completed bookings in this version. Payment-status accounting will replace this rule when the payment module is connected.',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
    );
  }

  Widget _periodCard(
    BuildContext context,
    WidgetRef ref,
    FinanceReportRange range,
  ) {
    final material = MaterialLocalizations.of(context);
    final from = material.formatMediumDate(range.from);
    final to = material.formatMediumDate(range.to);

    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Reporting Period'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '$from — $to',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _selectRange(context, ref, range),
                icon: Icon(Icons.date_range_rounded, size: 18),
                label: Text(context.tr('Change')),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _periodButton(context, ref, 'Today', _todayRange()),
              _periodButton(context, ref, 'This Month', _monthRange()),
              _periodButton(context, ref, 'This Year', _yearRange()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportBody(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                'Recognized Revenue',
                currency.format(report.recognizedRevenue),
                Icons.trending_up_rounded,
                AppColors.success,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                context,
                'Expenses',
                currency.format(report.expenses),
                Icons.trending_down_rounded,
                AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                'Net Profit',
                currency.format(report.netProfit),
                report.netProfit >= 0
                    ? Icons.account_balance_wallet_rounded
                    : Icons.warning_amber_rounded,
                report.netProfit >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                context,
                'Profit Margin',
                '${report.profitMarginPercent.toStringAsFixed(1)}%',
                Icons.percent_rounded,
                AppColors.gold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                'Completed Bookings',
                '${report.completedBookingsCount}',
                Icons.task_alt_rounded,
                AppColors.primaryLight,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                context,
                'Average / Booking',
                currency.format(report.averageRevenuePerCompletedBooking),
                Icons.calculate_outlined,
                AppColors.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        _sectionCard(
          context,
          title: 'Cost Structure',
          subtitle: 'Expenses grouped into business cost areas',
          children: _buildExpenseGroupRows(context, report, currency),
        ),
        SizedBox(height: 14),
        _sectionCard(
          context,
          title: 'Revenue by Service',
          subtitle: 'Completed-booking revenue by service',
          children: _buildRevenueRows(context, report, currency),
        ),
        SizedBox(height: 14),
        _sectionCard(
          context,
          title: 'Detailed Expense Categories',
          subtitle: 'Exact expense categories recorded by the owner',
          children: _buildExpenseCategoryRows(context, report, currency),
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3),
          Text(
            context.tr(subtitle),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildExpenseGroupRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.expensesByGroup.isEmpty) {
      return _emptyRows(context, 'No expenses recorded in this period.');
    }

    final entries = report.expensesByGroup.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final share = report.expenses <= 0 ? 0.0 : entry.value / report.expenses;
      return _breakdownRow(
        context,
        label: entry.key.label,
        value: currency.format(entry.value),
        detail: '${(share * 100).toStringAsFixed(1)}% ${context.tr('of expenses')}',
      );
    }).toList(growable: false);
  }

  List<Widget> _buildRevenueRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.revenueByService.isEmpty) {
      return _emptyRows(
        context,
        'No completed-booking revenue in this period.',
      );
    }

    final entries = report.revenueByService.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final share = report.recognizedRevenue <= 0
          ? 0.0
          : entry.value / report.recognizedRevenue;
      return _breakdownRow(
        context,
        label: entry.key,
        value: currency.format(entry.value),
        detail: '${(share * 100).toStringAsFixed(1)}% ${context.tr('of revenue')}',
      );
    }).toList(growable: false);
  }

  List<Widget> _buildExpenseCategoryRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.expensesByCategory.isEmpty) {
      return _emptyRows(context, 'No expenses recorded in this period.');
    }

    final entries = report.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) => _breakdownRow(
            context,
            label: entry.key.label,
            value: currency.format(entry.value),
          ),
        )
        .toList(growable: false);
  }

  Widget _breakdownRow(
    BuildContext context, {
    required String label,
    required String value,
    String? detail,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(label),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detail != null) ...[
                  SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _emptyRows(BuildContext context, String message) {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            context.tr(message),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    ];
  }

  Widget _metricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            context.tr(label),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 32,
          ),
          SizedBox(height: 10),
          Text(
            context.tr('Finance data unavailable'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6),
          Text(
            context.tr(
              'We could not load the finance report. Check your connection and try again.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(ownerProfitAndLossProvider),
            icon: Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.tr('Try Again')),
          ),
        ],
      ),
    );
  }

  Widget _periodButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    FinanceReportRange range,
  ) {
    return OutlinedButton(
      onPressed: () {
        ref.read(ownerFinanceReportRangeProvider.notifier).state = range;
      },
      child: Text(context.tr(label)),
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
      lastDate: DateTime.now(),
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
