import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense_model.dart';
import '../../providers/owner_finance_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class OwnerExpensesScreen extends ConsumerWidget {
  OwnerExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(ownerExpensesProvider);
    final material = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Business Expenses')),
        actions: [
          IconButton(
            tooltip: context.tr('Refresh'),
            onPressed: () => ref.read(ownerExpensesProvider.notifier).load(),
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: Icon(Icons.add_rounded),
        label: Text(context.tr('Add Expense')),
      ),
      body: expensesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 42,
                  color: AppColors.error,
                ),
                SizedBox(height: 12),
                Text(
                  context.tr(
                    'Unable to load expenses right now. Please try again.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 58,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 14),
                    Text(
                      context.tr('No expenses recorded yet'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      context.tr(
                        'Record each real business cost so profit reports remain accurate.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(ownerExpensesProvider.notifier).load(),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final expense = expenses[index];
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
                                  '${context.tr(expense.category.label)} • ${material.formatMediumDate(expense.expenseDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              CurrencyFormatter.format(expense.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _tag(context, expense.paymentMethod),
                          _tag(context, expense.frequency.label),
                          if (expense.supplier?.trim().isNotEmpty == true)
                            _tag(context, expense.supplier!.trim(), translate: false),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openEditor(
                              context,
                              ref,
                              existing: expense,
                            ),
                            icon: Icon(Icons.edit_outlined, size: 18),
                            label: Text(context.tr('Edit')),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmArchive(
                              context,
                              ref,
                              expense,
                            ),
                            icon: Icon(Icons.archive_outlined, size: 18),
                            label: Text(context.tr('Archive')),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _tag(BuildContext context, String text, {bool translate = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        translate ? context.tr(text) : text,
        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Archive expense?')),
        content: Text(
          context.tr(
            'Archive this expense? It will be removed from active expense reports but retained as an archived financial record.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('Archive')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(ownerExpensesProvider.notifier).archive(expense.id);
      ref.invalidate(ownerProfitAndLossProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Expense archived.'))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                'Unable to archive this expense. Please try again.',
              ),
            ),
          ),
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
    _frequency = item?.frequency ?? ExpenseFrequency.oneTime;
    _date = item?.expenseDate ?? DateTime.now();
    _paymentMethod = item?.paymentMethod ?? _paymentMethods.first;
    if (!_paymentMethods.contains(_paymentMethod)) _paymentMethod = 'Other';
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
    final material = MaterialLocalizations.of(context);

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
                context.tr(
                  widget.existing == null ? 'Add Expense' : 'Edit Expense',
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                context.tr(
                  'Record the cost when it actually occurs. Frequency classifies the expense for reporting and does not create automatic future charges.',
                ),
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 18),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: InputDecoration(labelText: context.tr('Category')),
                items: ExpenseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(context.tr(category.label)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<ExpenseFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(labelText: context.tr('Frequency')),
                items: ExpenseFrequency.values
                    .map(
                      (frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(context.tr(frequency.label)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _frequency = value);
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(labelText: context.tr('Description')),
                textInputAction: TextInputAction.next,
                maxLength: 300,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('Description is required.')
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                decoration: InputDecoration(
                  labelText: context.tr('Amount'),
                  prefixText: 'AED ',
                ),
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return context.tr('Enter a valid amount greater than zero.');
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Expense Date')),
                subtitle: Text(material.formatMediumDate(_date)),
                trailing: Icon(Icons.calendar_month_rounded),
                onTap: _pickDate,
              ),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: context.tr('Payment Method'),
                ),
                items: _paymentMethods
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(context.tr(method)),
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
                  labelText: context.tr('Supplier / Payee (optional)'),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(
                  labelText: context.tr('Notes (optional)'),
                ),
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
                label: Text(context.tr(_saving ? 'Saving…' : 'Save Expense')),
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
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Unable to save this expense. Please try again.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

extension ExpenseFrequencyLabel on ExpenseFrequency {
  String get label {
    switch (this) {
      case ExpenseFrequency.oneTime:
        return 'One-time';
      case ExpenseFrequency.monthly:
        return 'Monthly';
      case ExpenseFrequency.yearly:
        return 'Annual';
    }
  }
}
