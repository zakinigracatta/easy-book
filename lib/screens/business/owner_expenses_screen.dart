import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/expense_l10n.dart';
import '../../l10n/l10n.dart';
import '../../models/expense_model.dart';
import '../../providers/owner_finance_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class OwnerExpensesScreen extends ConsumerWidget {
  const OwnerExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
    final expensesAsync = ref.watch(ownerExpensesProvider);
    final money = NumberFormat.currency(
      symbol: 'AED ',
      decimalDigits: 2,
      customPattern: '\u200E¤#,##0.00;\u200E-¤#,##0.00',
    );
    final date = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.businessExpenses),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: () => ref.read(ownerExpensesProvider.notifier).load(),
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: Icon(Icons.add_rounded),
        label: Text(l10n.addExpense),
      ),
      body: expensesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (expenses) {
          final sorted = [...expenses]
            ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

          return RefreshIndicator(
            onRefresh: () => ref.read(ownerExpensesProvider.notifier).load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _classificationSummary(context, sorted, money),
                SizedBox(height: 16),
                for (final frequency in ExpenseFrequency.values) ...[
                  _frequencySection(
                    context,
                    ref,
                    sorted,
                    frequency,
                    money,
                    date,
                  ),
                  SizedBox(height: 18),
                ],
                if (expenses.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 24),
                    child: Text(
                      l10n.noExpensesYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
    BuildContext context,
    List<ExpenseModel> expenses,
    NumberFormat money,
  ) {
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);

    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nOf(context).expenseClassification,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l10nOf(context).expenseClassificationHelp,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 14),
          _summaryRow(context, l10nOf(context).totalActiveExpenses,
              money.format(total), true),
          Divider(height: 20),
          for (final frequency in ExpenseFrequency.values)
            _summaryRow(
              context,
              frequency.label(l10nOf(context)),
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

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value,
    bool emphasize,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: emphasize ? 13 : 12,
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
                color: emphasize
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: emphasize
                  ? AppColors.error
                  : Theme.of(context).colorScheme.onSurface,
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
                    frequency.label(l10nOf(context)),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    frequency.description(l10nOf(context)),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Text(
              money.format(total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (items.isEmpty)
          GlassCard(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10nOf(context).noExpensesOfType(
                      frequency.shortLabel(l10nOf(context)),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map(
            (expense) => Padding(
              padding: EdgeInsets.only(bottom: 10),
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
      padding: EdgeInsets.all(14),
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
                child: Icon(
                  Icons.payments_outlined,
                  color: AppColors.error,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${expense.category.label(l10nOf(context))} • ${date.format(expense.expenseDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money.format(expense.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditor(context, ref, existing: expense);
                      } else {
                        _confirmArchive(context, ref, expense);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'edit', child: Text(l10nOf(context).edit)),
                      PopupMenuItem(
                          value: 'archive',
                          child: Text(l10nOf(context).archive)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tag(context, expense.frequency.shortLabel(l10nOf(context))),
              _tag(
                  context,
                  localizedPaymentMethod(
                    expense.paymentMethod,
                    l10nOf(context),
                  )),
              if (expense.supplier?.trim().isNotEmpty == true)
                _tag(context, expense.supplier!.trim()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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
        title: Text(l10nOf(context).archiveExpenseQuestion),
        content: Text(
          l10nOf(context).archiveExpenseConfirmation(expense.description),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10nOf(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10nOf(context).archive),
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
          SnackBar(content: Text(l10nOf(context).expenseArchived)),
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

  static final _paymentMethods = <String>[
    'Cash',
    'Card',
    'Bank transfer',
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
    final l10n = l10nOf(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

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
                widget.existing == null ? l10n.addExpense : l10n.editExpense,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                l10n.expenseEditorHelp,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 18),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.category),
                items: ExpenseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label(l10n)),
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
              SizedBox(height: 12),
              DropdownButtonFormField<ExpenseFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(
                  labelText: l10n.expenseType,
                  helperText: l10n.expenseTypeHelper,
                ),
                items: ExpenseFrequency.values
                    .map(
                      (frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.label(l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _frequency = value);
                },
              ),
              SizedBox(height: 12),
              Text(
                _frequency.description(l10n),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(labelText: l10n.description),
                textInputAction: TextInputAction.next,
                maxLength: 300,
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.descriptionRequired
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixText: 'AED ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return l10n.validPositiveAmountRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.expenseDate),
                subtitle: Text(date.format(_date)),
                trailing: Icon(Icons.calendar_month_rounded),
                onTap: _pickDate,
              ),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(labelText: l10n.paymentMethod),
                items: _paymentMethods
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(localizedPaymentMethod(method, l10n)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _supplier,
                decoration: InputDecoration(
                  labelText: l10n.supplierOptional,
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.notesOptional),
                minLines: 2,
                maxLines: 4,
              ),
              SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.save_rounded),
                label: Text(_saving ? l10n.saving : l10n.saveExpense),
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
