import '../models/expense_model.dart';
import 'app_localizations.dart';

String localizedPaymentMethod(String method, AppLocalizations l10n) {
  return switch (method) {
    'Cash' || 'نقدًا' => l10n.cash,
    'Card' || 'بطاقة' => l10n.card,
    'Bank transfer' || 'تحويل بنكي' => l10n.bankTransfer,
    'Cheque' || 'شيك' => l10n.cheque,
    _ => l10n.other,
  };
}

extension LocalizedExpenseFrequency on ExpenseFrequency {
  String label(AppLocalizations l10n) => switch (this) {
        ExpenseFrequency.daily => l10n.dailyExpenses,
        ExpenseFrequency.monthly => l10n.monthlyExpenses,
        ExpenseFrequency.yearly => l10n.annualExpenses,
        ExpenseFrequency.emergency => l10n.emergencyOneTime,
      };

  String shortLabel(AppLocalizations l10n) => switch (this) {
        ExpenseFrequency.daily => l10n.daily,
        ExpenseFrequency.monthly => l10n.monthly,
        ExpenseFrequency.yearly => l10n.annual,
        ExpenseFrequency.emergency => l10n.emergency,
      };

  String description(AppLocalizations l10n) => switch (this) {
        ExpenseFrequency.daily => l10n.dailyExpenseDescription,
        ExpenseFrequency.monthly => l10n.monthlyExpenseDescription,
        ExpenseFrequency.yearly => l10n.annualExpenseDescription,
        ExpenseFrequency.emergency => l10n.emergencyExpenseDescription,
      };
}

extension LocalizedExpenseCategory on ExpenseCategory {
  String label(AppLocalizations l10n) => switch (this) {
        ExpenseCategory.rent => l10n.rent,
        ExpenseCategory.salaries => l10n.staffSalaries,
        ExpenseCategory.commissions => l10n.staffCommissions,
        ExpenseCategory.utilities => l10n.utilities,
        ExpenseCategory.internetPhone => l10n.internetAndPhone,
        ExpenseCategory.supplies => l10n.productsAndSupplies,
        ExpenseCategory.equipment => l10n.equipment,
        ExpenseCategory.maintenance => l10n.maintenance,
        ExpenseCategory.cleaningLaundry => l10n.cleaningAndLaundry,
        ExpenseCategory.marketing => l10n.marketingAndAdvertising,
        ExpenseCategory.licensing => l10n.licensingAndGovernmentFees,
        ExpenseCategory.insurance => l10n.insurance,
        ExpenseCategory.paymentFees => l10n.paymentAndBankFees,
        ExpenseCategory.easyBookFees => l10n.easyBookFees,
        ExpenseCategory.taxes => l10n.taxesAndVat,
        ExpenseCategory.transport => l10n.transport,
        ExpenseCategory.other => l10n.other,
      };
}

extension LocalizedExpenseGroup on ExpenseGroup {
  String label(AppLocalizations l10n) => switch (this) {
        ExpenseGroup.staff => l10n.staffCosts,
        ExpenseGroup.occupancy => l10n.occupancyAndUtilities,
        ExpenseGroup.operations => l10n.operatingCosts,
        ExpenseGroup.marketing => l10n.marketing,
        ExpenseGroup.feesAndCompliance => l10n.feesInsuranceAndTaxes,
        ExpenseGroup.other => l10n.otherCosts,
      };
}
