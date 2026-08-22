import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import '../models/profit_and_loss_summary.dart';
import '../repositories/owner_finance_repository.dart';
import 'owner_providers.dart';

final ownerFinanceRepositoryProvider = Provider<OwnerFinanceRepository>((ref) {
  return OwnerFinanceRepositoryImpl();
});

class OwnerExpensesNotifier
    extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final OwnerFinanceRepository _repository;
  final String _businessId;

  OwnerExpensesNotifier(this._repository, this._businessId)
      : super(_businessId.isEmpty
            ? const AsyncValue.data(<ExpenseModel>[])
            : const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      load();
    }
  }

  Future<void> load() async {
    if (_businessId.isEmpty) {
      state = const AsyncValue.data(<ExpenseModel>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repository.fetchExpenses(_businessId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> save({
    String? expenseId,
    required ExpenseCategory category,
    required String description,
    required double amount,
    required DateTime expenseDate,
    required String paymentMethod,
    String? supplier,
    String? receiptUrl,
    String? notes,
    ExpenseFrequency frequency = ExpenseFrequency.oneTime,
  }) async {
    if (_businessId.isEmpty) {
      throw StateError('No business is linked to this owner account.');
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw StateError('No authenticated owner is available.');
    }

    ExpenseModel? existing;
    if (expenseId != null) {
      for (final item in state.value ?? const <ExpenseModel>[]) {
        if (item.id == expenseId) {
          existing = item;
          break;
        }
      }
    }

    final expense = ExpenseModel(
      id: expenseId ?? '',
      businessId: _businessId,
      category: category,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
      paymentMethod: paymentMethod,
      supplier: supplier,
      receiptUrl: receiptUrl,
      notes: notes,
      frequency: frequency,
      isActive: true,
      createdBy: existing?.createdBy ?? uid,
      createdAt: existing?.createdAt,
    );

    await _repository.saveExpense(expense);
    await load();
  }

  Future<void> archive(String expenseId) async {
    if (_businessId.isEmpty || expenseId.isEmpty) return;
    await _repository.archiveExpense(_businessId, expenseId);
    await load();
  }
}

final ownerExpensesProvider = StateNotifierProvider<OwnerExpensesNotifier,
    AsyncValue<List<ExpenseModel>>>((ref) {
  final repository = ref.watch(ownerFinanceRepositoryProvider);
  final businessId = ref.watch(currentBusinessIdProvider).value ?? '';
  return OwnerExpensesNotifier(repository, businessId);
});

class FinanceReportRange {
  final DateTime from;
  final DateTime to;

  const FinanceReportRange({required this.from, required this.to});

  FinanceReportRange copyWith({DateTime? from, DateTime? to}) {
    return FinanceReportRange(
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

final ownerFinanceReportRangeProvider = StateProvider<FinanceReportRange>((ref) {
  final now = DateTime.now();
  return FinanceReportRange(
    from: DateTime(now.year, now.month, 1),
    to: DateTime(now.year, now.month, now.day),
  );
});

final ownerProfitAndLossProvider = FutureProvider<ProfitAndLossSummary>((ref) async {
  final businessId = await ref.watch(currentBusinessIdProvider.future);
  if (businessId.isEmpty) {
    throw StateError('No business is linked to this owner account.');
  }

  final range = ref.watch(ownerFinanceReportRangeProvider);
  final repository = ref.watch(ownerFinanceRepositoryProvider);
  return repository.buildProfitAndLoss(
    businessId: businessId,
    from: range.from,
    to: range.to,
  );
});
