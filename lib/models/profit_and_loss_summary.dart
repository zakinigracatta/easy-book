import 'expense_model.dart';

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
