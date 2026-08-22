import 'expense_model.dart';

class ProfitAndLossSummary {
  final DateTime from;
  final DateTime to;
  final double recognizedRevenue;
  final double expenses;
  final double netProfit;
  final double profitMarginPercent;
  final int completedBookingsCount;
  final double averageRevenuePerCompletedBooking;
  final Map<ExpenseCategory, double> expensesByCategory;
  final Map<ExpenseGroup, double> expensesByGroup;
  final Map<String, double> revenueByService;

  const ProfitAndLossSummary({
    required this.from,
    required this.to,
    required this.recognizedRevenue,
    required this.expenses,
    required this.netProfit,
    required this.profitMarginPercent,
    required this.completedBookingsCount,
    required this.averageRevenuePerCompletedBooking,
    required this.expensesByCategory,
    required this.expensesByGroup,
    required this.revenueByService,
  });
}