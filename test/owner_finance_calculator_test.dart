import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/models/expense_model.dart';
import 'package:easy_book/services/owner_finance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = OwnerFinanceCalculator();

  BookingModel booking({
    required String id,
    required BookingStatus status,
    required double price,
    required DateTime date,
  }) {
    return BookingModel(
      id: id,
      customerId: 'customer-1',
      customerName: 'Customer',
      businessId: 'business-1',
      businessName: 'Business',
      serviceId: 'service-1',
      serviceName: 'Service',
      servicePrice: price,
      staffId: 'staff-1',
      staffName: 'Staff',
      startDateTime: date,
      endDateTime: date.add(const Duration(minutes: 45)),
      status: status,
    );
  }

  ExpenseModel expense({
    required String id,
    required ExpenseCategory category,
    required double amount,
    required DateTime date,
    bool isActive = true,
  }) {
    return ExpenseModel(
      id: id,
      businessId: 'business-1',
      category: category,
      description: 'Expense $id',
      amount: amount,
      expenseDate: date,
      paymentMethod: 'Cash',
      isActive: isActive,
      createdBy: 'owner-1',
    );
  }

  test('recognizes revenue only from completed bookings inside range', () {
    final summary = calculator.calculate(
      bookings: [
        booking(
          id: 'completed',
          status: BookingStatus.completed,
          price: 200,
          date: DateTime(2026, 8, 10, 12),
        ),
        booking(
          id: 'pending',
          status: BookingStatus.pending,
          price: 500,
          date: DateTime(2026, 8, 10, 13),
        ),
        booking(
          id: 'confirmed',
          status: BookingStatus.confirmed,
          price: 400,
          date: DateTime(2026, 8, 11, 13),
        ),
        booking(
          id: 'cancelled',
          status: BookingStatus.cancelled,
          price: 900,
          date: DateTime(2026, 8, 12, 13),
        ),
        booking(
          id: 'outside',
          status: BookingStatus.completed,
          price: 800,
          date: DateTime(2026, 7, 31, 23, 59),
        ),
      ],
      expenses: const [],
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 8, 31),
    );

    expect(summary.recognizedRevenue, 200);
    expect(summary.expenses, 0);
    expect(summary.netProfit, 200);
    expect(summary.profitMarginPercent, 100);
  });

  test('counts active expenses in range and groups them by category', () {
    final summary = calculator.calculate(
      bookings: [
        booking(
          id: 'completed',
          status: BookingStatus.completed,
          price: 1000,
          date: DateTime(2026, 8, 15),
        ),
      ],
      expenses: [
        expense(
          id: 'rent',
          category: ExpenseCategory.rent,
          amount: 300,
          date: DateTime(2026, 8, 1),
        ),
        expense(
          id: 'supplies-1',
          category: ExpenseCategory.supplies,
          amount: 100,
          date: DateTime(2026, 8, 5),
        ),
        expense(
          id: 'supplies-2',
          category: ExpenseCategory.supplies,
          amount: 50,
          date: DateTime(2026, 8, 20),
        ),
        expense(
          id: 'archived',
          category: ExpenseCategory.marketing,
          amount: 700,
          date: DateTime(2026, 8, 10),
          isActive: false,
        ),
        expense(
          id: 'outside',
          category: ExpenseCategory.other,
          amount: 900,
          date: DateTime(2026, 9, 1),
        ),
      ],
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 8, 31),
    );

    expect(summary.expenses, 450);
    expect(summary.expensesByCategory[ExpenseCategory.rent], 300);
    expect(summary.expensesByCategory[ExpenseCategory.supplies], 150);
    expect(summary.expensesByCategory.containsKey(ExpenseCategory.marketing), false);
    expect(summary.netProfit, 550);
    expect(summary.profitMarginPercent, 55);
  });

  test('uses inclusive calendar dates for the report range', () {
    final summary = calculator.calculate(
      bookings: [
        booking(
          id: 'late',
          status: BookingStatus.completed,
          price: 120,
          date: DateTime(2026, 8, 23, 23, 59, 59),
        ),
      ],
      expenses: [
        expense(
          id: 'same-day',
          category: ExpenseCategory.utilities,
          amount: 20,
          date: DateTime(2026, 8, 23, 23, 30),
        ),
      ],
      from: DateTime(2026, 8, 23),
      to: DateTime(2026, 8, 23),
    );

    expect(summary.recognizedRevenue, 120);
    expect(summary.expenses, 20);
    expect(summary.netProfit, 100);
  });

  test('returns zero margin when there is no recognized revenue', () {
    final summary = calculator.calculate(
      bookings: const [],
      expenses: [
        expense(
          id: 'rent',
          category: ExpenseCategory.rent,
          amount: 300,
          date: DateTime(2026, 8, 1),
        ),
      ],
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 8, 31),
    );

    expect(summary.recognizedRevenue, 0);
    expect(summary.netProfit, -300);
    expect(summary.profitMarginPercent, 0);
  });

  test('rejects an inverted report range', () {
    expect(
      () => calculator.calculate(
        bookings: const [],
        expenses: const [],
        from: DateTime(2026, 8, 31),
        to: DateTime(2026, 8, 1),
      ),
      throwsArgumentError,
    );
  });
}
