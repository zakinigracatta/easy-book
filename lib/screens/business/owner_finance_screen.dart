import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../l10n/expense_l10n.dart';
import '../../models/expense_model.dart';
import '../../models/profit_and_loss_summary.dart';
import '../../providers/owner_finance_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import 'owner_expenses_screen.dart';

class OwnerFinanceScreen extends ConsumerWidget {
  const OwnerFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final reportAsync = ref.watch(ownerProfitAndLossProvider);
    final range = ref.watch(ownerFinanceReportRangeProvider);
    final currency = NumberFormat.currency(
      symbol: 'AED ',
      decimalDigits: 2,
      customPattern: '\u200E¤#,##0.00;\u200E-¤#,##0.00',
    );
    final date = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financeAndProfit),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
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
            _periodCard(context, ref, range, date),
            const SizedBox(height: 16),
            reportAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => _errorCard(context, error),
              data: (report) => _reportBody(context, report, currency),
            ),
            const SizedBox(height: 18),
            GlassCard(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OwnerExpensesScreen(),
                  ),
                );
                ref.invalidate(ownerProfitAndLossProvider);
                ref.invalidate(ownerTodayProfitAndLossProvider);
              },
              child: ListTile(
                leading: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accent,
                ),
                title: Text(
                  l10n.manageExpenses,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(l10n.expenseCadences),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.financeRecognitionNote,
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
    DateFormat date,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nOf(context).reportingPeriod,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${date.format(range.from)} — ${date.format(range.to)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _selectRange(context, ref, range),
                icon: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(l10nOf(context).change),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _periodButton(ref, l10nOf(context).today, _todayRange()),
              _periodButton(ref, l10nOf(context).thisMonth, _monthRange()),
              _periodButton(ref, l10nOf(context).thisYear, _yearRange()),
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
        _profitHero(context, report, currency),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                l10nOf(context).recognizedRevenue,
                currency.format(report.recognizedRevenue),
                Icons.trending_up_rounded,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                context,
                l10nOf(context).expenses,
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
                context,
                l10nOf(context).completedBookings,
                '${report.completedBookingsCount}',
                Icons.task_alt_rounded,
                AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                context,
                l10nOf(context).averagePerBooking,
                currency.format(report.averageRevenuePerCompletedBooking),
                Icons.calculate_outlined,
                AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _sectionCard(
          context,
          title: l10nOf(context).expenseFrequency,
          subtitle: l10nOf(context).expenseFrequencySubtitle,
          children: _buildExpenseFrequencyRows(context, report, currency),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          title: l10nOf(context).costStructure,
          subtitle: l10nOf(context).costStructureSubtitle,
          children: _buildExpenseGroupRows(context, report, currency),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          title: l10nOf(context).revenueByService,
          subtitle: l10nOf(context).revenueByServiceSubtitle,
          children: _buildRevenueRows(context, report, currency),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          title: l10nOf(context).detailedExpenseCategories,
          subtitle: l10nOf(context).detailedExpenseCategoriesSubtitle,
          children: _buildExpenseCategoryRows(context, report, currency),
        ),
      ],
    );
  }

  Widget _profitHero(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    final positive = report.netProfit >= 0;
    final color = positive ? AppColors.success : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              positive
                  ? Icons.account_balance_wallet_rounded
                  : Icons.warning_amber_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nOf(context).netProfit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  currency.format(report.netProfit),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l10nOf(context).marginPercent(
                report.profitMarginPercent.toStringAsFixed(1),
              ),
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildExpenseFrequencyRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    return ExpenseFrequency.values.map((frequency) {
      final amount = report.expensesByFrequency[frequency] ?? 0.0;
      final share = report.expenses <= 0 ? 0.0 : amount / report.expenses;
      return _breakdownRow(
        context,
        label: frequency.label(l10nOf(context)),
        value: currency.format(amount),
        detail: l10nOf(context).expenseShareWithDescription(
          (share * 100).toStringAsFixed(1),
          frequency.description(l10nOf(context)),
        ),
      );
    }).toList(growable: false);
  }

  List<Widget> _buildExpenseGroupRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.expensesByGroup.isEmpty) {
      return _emptyRows(context, l10nOf(context).noExpensesInPeriod);
    }

    final entries = report.expensesByGroup.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final share = report.expenses <= 0 ? 0.0 : entry.value / report.expenses;
      return _breakdownRow(
        context,
        label: entry.key.label(l10nOf(context)),
        value: currency.format(entry.value),
        detail: l10nOf(context).expenseShare(
          (share * 100).toStringAsFixed(1),
        ),
      );
    }).toList(growable: false);
  }

  List<Widget> _buildRevenueRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.revenueByService.isEmpty) {
      return _emptyRows(context, l10nOf(context).noCompletedBookingRevenue);
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
        detail: l10nOf(context).revenueShare(
          (share * 100).toStringAsFixed(1),
        ),
      );
    }).toList(growable: false);
  }

  List<Widget> _buildExpenseCategoryRows(
    BuildContext context,
    ProfitAndLossSummary report,
    NumberFormat currency,
  ) {
    if (report.expensesByCategory.isEmpty) {
      return _emptyRows(context, l10nOf(context).noExpensesInPeriod);
    }

    final entries = report.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) => _breakdownRow(
            context,
            label: entry.key.label(l10nOf(context)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
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
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _emptyRows(BuildContext context, String message) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, Object error) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.error,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            l10nOf(context).financeDataUnavailable,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
