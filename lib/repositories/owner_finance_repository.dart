import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/domain_exceptions.dart';
import '../models/booking_model.dart';
import '../models/expense_model.dart';
import '../models/profit_and_loss_summary.dart';
import '../services/owner_finance_calculator.dart';

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
  final OwnerFinanceCalculator _calculator;

  OwnerFinanceRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    OwnerFinanceCalculator calculator = const OwnerFinanceCalculator(),
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _calculator = calculator;

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

  bool _isIndexUnavailable(FirebaseException error) {
    return error.code == 'failed-precondition' || error.code == 'unimplemented';
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchBookingsForReport({
    required String businessId,
    required DateTime start,
    required DateTime endExclusive,
  }) async {
    try {
      return await _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: businessId)
          .where(
            'startDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'startDateTime',
            isLessThan: Timestamp.fromDate(endExclusive),
          )
          .get();
    } on FirebaseException catch (error) {
      if (!_isIndexUnavailable(error)) rethrow;

      // Keep the finance report usable when the compound Firestore index has
      // not been deployed yet or is still building. The date range is filtered
      // locally below, while the server still limits results to this business.
      return _firestore
          .collection('bookings')
          .where('businessId', isEqualTo: businessId)
          .get();
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchExpensesForReport({
    required String businessId,
    required DateTime start,
    required DateTime endExclusive,
  }) async {
    try {
      return await _expenses(businessId)
          .where(
            'expenseDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'expenseDate',
            isLessThan: Timestamp.fromDate(endExclusive),
          )
          .get();
    } on FirebaseException catch (error) {
      if (!_isIndexUnavailable(error)) rethrow;

      // A single-field index normally exists automatically, but this fallback
      // also protects older/emulator projects with indexing disabled.
      return _expenses(businessId).get();
    }
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses(String businessId) async {
    if (businessId.isEmpty) return const [];
    await _assertOwner(businessId);

    try {
      final snapshot = await _expenses(businessId).get();
      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.id, doc.data()))
          .where((expense) => expense.isActive)
          .toList();
      expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      return List.unmodifiable(expenses);
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
    final endExclusive = DateTime(to.year, to.month, to.day)
        .add(const Duration(days: 1));

    try {
      final bookingSnapshot = await _fetchBookingsForReport(
        businessId: businessId,
        start: start,
        endExclusive: endExclusive,
      );
      final expenseSnapshot = await _fetchExpensesForReport(
        businessId: businessId,
        start: start,
        endExclusive: endExclusive,
      );

      final bookings = bookingSnapshot.docs
          .map(
            (doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .where(
            (booking) =>
                !booking.startDateTime.isBefore(start) &&
                booking.startDateTime.isBefore(endExclusive),
          )
          .toList(growable: false);
      final expenses = expenseSnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc.id, doc.data()))
          .where(
            (expense) =>
                !expense.expenseDate.isBefore(start) &&
                expense.expenseDate.isBefore(endExclusive),
          )
          .toList(growable: false);

      return _calculator.calculate(
        bookings: bookings,
        expenses: expenses,
        from: start,
        to: to,
      );
    } on FirebaseException catch (e) {
      throw DomainException(
        'Failed to calculate profit and loss: ${e.message ?? e.code}',
      );
    }
  }
}
