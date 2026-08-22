import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../providers/owner_finance_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class OwnerExpensesScreen extends ConsumerWidget {
  const OwnerExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(ownerExpensesProvider);
    final money = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);
    final date = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Expenses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.read(ownerExpensesProvider.notifier).load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      body: expensesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (expenses) {
          final sorted = [...expenses]
            ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

          return RefreshIndicator(
            onRefresh: () => ref.read(ownerExpensesProvider.notifier).load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _classificationSummary(sorted, money),
                const SizedBox(height: 16),
                for (final frequency in ExpenseFrequency.values) ...[
                  _frequencySection(
                    context,
                    ref,
                    sorted,
                    frequency,
                    money,
                    date,
                  ),
                  const SizedBox(height: 18),
                ],
                if (expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 24),
                    child: Text(
                      'No expenses recorded yet. Use “Add Expense” to record a real business cost.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMutedDark),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _classificationSummary(
    List<ExpenseModel> expenses,
    NumberFormat money,
  ) {
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Classification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Every record is an actual cost. The type describes its business cadence; it does not automatically repeat the amount.',
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Total Active Expenses', money.format(total), true),
          const Divider(height: 20),
          for (final frequency in ExpenseFrequency.values)
            _summaryRow(
              frequency.label,
              money.format(
                expenses
                    .where((item) => item.frequency == frequency)
                    .fold<double>(0, (sum, item) => sum + item.amount),
              ),
              false,
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool emphasize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: emphasize ? 13 : 12,
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
                color: emphasize
                    ? AppColors.textPrimaryDark
                    : AppColors.textMutedDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: emphasize ? AppColors.error : AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _frequencySection(
    BuildContext context,
    WidgetRef ref,
    List<ExpenseModel> expenses,
    ExpenseFrequency frequency,
    NumberFormat money,
    DateFormat date,
  ) {
    final items = expenses
        .where((expense) => expense.frequency == frequency)
        .toList(growable: false);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frequency.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    frequency.description,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              money.format(total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.textMutedDark,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No ${frequency.shortLabel.toLowerCase()} expenses recorded.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _expenseCard(context, ref, expense, money, date),
            ),
          ),
      ],
    );
  }

  Widget _expenseCard(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
    NumberFormat money,
    DateFormat date,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${expense.category.label} • ${date.format(expense.expenseDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                money.format(expense.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tag(expense.frequency.shortLabel),
              _tag(expense.paymentMethod),
              if (expense.supplier?.trim().isNotEmpty == true)
                _tag(expense.supplier!.trim()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _openEditor(
                  context,
                  ref,
                  existing: expense,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _confirmArchive(
                  context,
                  ref,
                  expense,
                ),
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: const Text('Archive'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassBorderDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
      ),
    );
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive expense?'),
        content: Text(
          'Archive “${expense.description}”? It will be removed from active expense reports but retained as an archived financial record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(ownerExpensesProvider.notifier).archive(expense.id);
      ref.invalidate(ownerProfitAndLossProvider);
      ref.invalidate(ownerTodayProfitAndLossProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense archived.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    ExpenseModel? existing,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ExpenseEditor(existing: existing),
    );

    if (saved == true) {
      await ref.read(ownerExpensesProvider.notifier).load();
      ref.invalidate(ownerProfitAndLossProvider);
      ref.invalidate(ownerTodayProfitAndLossProvider);
    }
  }
}

class _ExpenseEditor extends ConsumerStatefulWidget {
  final ExpenseModel? existing;

  const _ExpenseEditor({this.existing});

  @override
  ConsumerState<_ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends ConsumerState<_ExpenseEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late final TextEditingController _supplier;
  late final TextEditingController _notes;
  late ExpenseCategory _category;
  late ExpenseFrequency _frequency;
  late DateTime _date;
  late String _paymentMethod;
  bool _saving = false;

  static const _paymentMethods = <String>[
    'Cash',
    'Card',
    'Bank Transfer',
    'Cheque',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _description = TextEditingController(text: item?.description ?? '');
    _amount = TextEditingController(
      text: item == null ? '' : item.amount.toStringAsFixed(2),
    );
    _supplier = TextEditingController(text: item?.supplier ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _category = item?.category ?? ExpenseCategory.other;
    _frequency = item?.frequency ?? _category.suggestedFrequency;
    _date = item?.expenseDate ?? DateTime.now();
    _paymentMethod = item?.paymentMethod ?? _paymentMethods.first;
    if (!_paymentMethods.contains(_paymentMethod)) {
      _paymentMethod = 'Other';
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _supplier.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy');

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'Add Expense' : 'Edit Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Record the actual amount that occurred, then classify it as Daily, Monthly, Annual or Emergency. The classification itself does not create recurring charges.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.textMutedDark,
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                    if (widget.existing == null) {
                      _frequency = value.suggestedFrequency;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Expense Type',
                  helperText: 'Daily / Monthly / Annual / Emergency',
                ),
                items: ExpenseFrequency.values
                    .map(
                      (frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _frequency = value);
                },
              ),
              const SizedBox(height: 12),
              Text(
                _frequency.description,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMutedDark,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.next,
                maxLength: 300,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'AED ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return 'Enter a valid amount greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expense Date'),
                subtitle: Text(date.format(_date)),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: _pickDate,
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: _paymentMethods
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplier,
                decoration: const InputDecoration(
                  labelText: 'Supplier / Payee (optional)',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving…' : 'Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref.read(ownerExpensesProvider.notifier).save(
            expenseId: widget.existing?.id,
            category: _category,
            description: _description.text.trim(),
            amount: double.parse(_amount.text.trim()),
            expenseDate: _date,
            paymentMethod: _paymentMethod,
            supplier: _supplier.text.trim(),
            notes: _notes.text.trim(),
            frequency: _frequency,
          );
      ref.invalidate(ownerProfitAndLossProvider);
      ref.invalidate(ownerTodayProfitAndLossProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
