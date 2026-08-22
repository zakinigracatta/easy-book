import '../models/booking_model.dart';
import '../models/expense_model.dart';
import '../models/profit_and_loss_summary.dart';

class OwnerFinanceCalculator {
  const OwnerFinanceCalculator();

  ProfitAndLossSummary calculate({
    required List<BookingModel> bookings,
    required List<ExpenseModel> expenses,
    required DateTime from,
    required DateTime to,
  }) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) {
      throw ArgumentError('The report end date cannot be before the start date.');
    }
    final endExclusive = end.add(const Duration(days: 1));

    var recognizedRevenue = 0.0;
    for (final booking in bookings) {
      final inRange = !booking.startDateTime.isBefore(start) &&
          booking.startDateTime.isBefore(endExclusive);
      if (inRange && booking.status == BookingStatus.completed) {
        recognizedRevenue += booking.servicePrice;
      }
    }

    var expenseTotal = 0.0;
    final expensesByCategory = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      final inRange = !expense.expenseDate.isBefore(start) &&
          expense.expenseDate.isBefore(endExclusive);
      if (!expense.isActive || !inRange) continue;

      expenseTotal += expense.amount;
      expensesByCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final netProfit = recognizedRevenue - expenseTotal;
    final profitMarginPercent = recognizedRevenue <= 0
        ? 0.0
        : (netProfit / recognizedRevenue) * 100;

    return ProfitAndLossSummary(
      from: start,
      to: end,
      recognizedRevenue: recognizedRevenue,
      expenses: expenseTotal,
      netProfit: netProfit,
      profitMarginPercent: profitMarginPercent,
      expensesByCategory: Map.unmodifiable(expensesByCategory),
    );
  }
}
