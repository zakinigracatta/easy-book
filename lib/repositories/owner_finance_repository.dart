import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/domain_exceptions.dart';
import '../models/booking_model.dart';
import '../models/expense_model.dart';

class ProfitAndLossSummary {
  final DateTime from;
  final DateTime to;
  final double recognizedRevenue;
  final double expenses;
  final double netProfit;
  final double profitMarginPercent;
  final Map<ExpenseCategory, double> expensesByCategory;

  const ProfitAndLossSummary({
    required this.from,
    required this.to,
    required this.recognizedRevenue,
    required this.expenses,
    required this.netProfit,
    required this.profitMarginPercent,
    required this.expensesByCategory,
  });
}

abstract class OwnerFinanceRepository {
  Future<List<ExpenseModel>> fetchExpenses(String businessId);
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> archiveExpense(String businessId, String expenseId);
  Future<ProfitAndLossSummary> buildProfitAndLoss({
    required String businessId,
    required DateTime from,
    required DateTime to,
  });
}

class OwnerFinanceRepositoryImpl implements OwnerFinanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OwnerFinanceRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> _assertOwner(String businessId) async {
    final user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw DomainException('You must be signed in to access finance data.');
    }

    final business =
        await _firestore.collection('businesses').doc(businessId).get();
    final data = business.data();
    if (!business.exists || data == null) {
      throw DomainException('Business record not found.');
    }

    final ownerId = (data['ownerId'] ?? data['owner_id'])?.toString() ?? '';
    if (ownerId != user.uid) {
      throw DomainException('Only the business owner can access finance data.');
    }
  }

  CollectionReference<Map<String, dynamic>> _expenses(String businessId) =>
      _firestore.collection('businesses').doc(businessId).collection('expenses');

  @override
  Future<List<ExpenseModel>> fetchExpenses(String businessId) async {
    if (businessId.isEmpty) return const [];
    await _assertOwner(businessId);

    try {
      final snapshot = await _expenses(businessId)
          .where('isActive', isEqualTo: true)
          .orderBy('expenseDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to load expenses: ${e.message ?? e.code}',
      );
    }
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    if (expense.businessId.isEmpty) {
      throw DomainException('Business ID is required.');
    }
    if (expense.description.trim().isEmpty) {
      throw DomainException('Expense description is required.');
    }
    if (!expense.amount.isFinite || expense.amount <= 0) {
      throw DomainException('Expense amount must be greater than zero.');
    }

    await _assertOwner(expense.businessId);
    final user = _auth.currentUser!;
    if (expense.createdBy != user.uid) {
      throw DomainException('Expense owner identity does not match.');
    }

    try {
      final collection = _expenses(expense.businessId);
      if (expense.id.isEmpty) {
        await collection.add({
          ...expense.toFirestore(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final existing = await collection.doc(expense.id).get();
        if (!existing.exists) {
          throw DomainException('Expense record no longer exists.');
        }
        await collection.doc(expense.id).update(expense.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to save expense: ${e.message ?? e.code}',
      );
    }
  }

  @override
  Future<void> archiveExpense(String businessId, String expenseId) async {
    if (businessId.isEmpty || expenseId.isEmpty) return;
    await _assertOwner(businessId);

    try {
      await _expenses(businessId).doc(expenseId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to archive expense: ${e.message ?? e.code}',
      );
    }
  }

  @override
  Future<ProfitAndLossSummary> buildProfitAndLoss({
    required String businessId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (businessId.isEmpty) {
      throw DomainException('Business ID is required.');
    }
    if (to.isBefore(from)) {
      throw DomainException('The report end date cannot be before the start date.');
    }

    await _assertOwner(businessId);

    final start = DateTime(from.year, from.month, from.day);
    final endExclusive = DateTime(to.year, to.month, to.day).add(
      const Duration(days: 1),
    );

    try {
      final results = await Future.wait([
        _firestore
            .collection('bookings')
            .where('businessId', isEqualTo: businessId)
            .where('status', isEqualTo: BookingStatus.completed.name)
            .where('startDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('startDateTime', isLessThan: Timestamp.fromDate(endExclusive))
            .get(),
        _expenses(businessId)
            .where('isActive', isEqualTo: true)
            .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('expenseDate', isLessThan: Timestamp.fromDate(endExclusive))
            .get(),
      ]);

      final bookingSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final expenseSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;

      final recognizedRevenue = bookingSnapshot.docs.fold<double>(0, (sum, doc) {
        final data = doc.data();
        final price = (data['servicePrice'] ?? data['service_price']) as num?;
        return sum + (price?.toDouble() ?? 0);
      });

      final expensesByCategory = <ExpenseCategory, double>{};
      var expenseTotal = 0.0;
      for (final doc in expenseSnapshot.docs) {
        final expense = ExpenseModel.fromFirestore(doc.id, doc.data());
        expenseTotal += expense.amount;
        expensesByCategory.update(
          expense.category,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }

      final netProfit = recognizedRevenue - expenseTotal;
      final margin = recognizedRevenue <= 0
          ? 0.0
          : (netProfit / recognizedRevenue) * 100;

      return ProfitAndLossSummary(
        from: start,
        to: DateTime(to.year, to.month, to.day),
        recognizedRevenue: recognizedRevenue,
        expenses: expenseTotal,
        netProfit: netProfit,
        profitMarginPercent: margin,
        expensesByCategory: Map.unmodifiable(expensesByCategory),
      );
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to calculate profit and loss: ${e.message ?? e.code}',
      );
    }
  }
}
