import 'package:timezone/timezone.dart' as tz;

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
    final start = _calendarMidnight(from);
    final end = _calendarMidnight(to);
    if (end.isBefore(start)) {
      throw ArgumentError('The report end date cannot be before the start date.');
    }
    final endExclusive = _nextCalendarMidnight(to);

    var recognizedRevenue = 0.0;
    var completedBookingsCount = 0;
    final revenueByService = <String, double>{};

    for (final booking in bookings) {
      final inRange = !booking.startDateTime.isBefore(start) &&
          booking.startDateTime.isBefore(endExclusive);
      if (!inRange || booking.status != BookingStatus.completed) continue;

      recognizedRevenue += booking.servicePrice;
      completedBookingsCount += 1;

      final serviceLabel = booking.serviceName.trim().isEmpty
          ? 'Unnamed Service'
          : booking.serviceName.trim();
      revenueByService.update(
        serviceLabel,
        (value) => value + booking.servicePrice,
        ifAbsent: () => booking.servicePrice,
      );
    }

    var expenseTotal = 0.0;
    final expensesByCategory = <ExpenseCategory, double>{};
    final expensesByGroup = <ExpenseGroup, double>{};

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
      expensesByGroup.update(
        expense.category.group,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final netProfit = recognizedRevenue - expenseTotal;
    final profitMarginPercent = recognizedRevenue <= 0
        ? 0.0
        : (netProfit / recognizedRevenue) * 100;
    final averageRevenuePerCompletedBooking = completedBookingsCount == 0
        ? 0.0
        : recognizedRevenue / completedBookingsCount;

    return ProfitAndLossSummary(
      from: start,
      to: end,
      recognizedRevenue: recognizedRevenue,
      expenses: expenseTotal,
      netProfit: netProfit,
      profitMarginPercent: profitMarginPercent,
      completedBookingsCount: completedBookingsCount,
      averageRevenuePerCompletedBooking: averageRevenuePerCompletedBooking,
      expensesByCategory: Map.unmodifiable(expensesByCategory),
      expensesByGroup: Map.unmodifiable(expensesByGroup),
      revenueByService: Map.unmodifiable(revenueByService),
    );
  }

  DateTime _calendarMidnight(DateTime value) {
    if (value is tz.TZDateTime) {
      return tz.TZDateTime(
        value.location,
        value.year,
        value.month,
        value.day,
      );
    }
    if (value.isUtc) {
      return DateTime.utc(value.year, value.month, value.day);
    }
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _nextCalendarMidnight(DateTime value) {
    if (value is tz.TZDateTime) {
      return tz.TZDateTime(
        value.location,
        value.year,
        value.month,
        value.day + 1,
      );
    }
    if (value.isUtc) {
      return DateTime.utc(value.year, value.month, value.day + 1);
    }
    return DateTime(value.year, value.month, value.day + 1);
  }
}