import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory {
  rent,
  salaries,
  commissions,
  utilities,
  internetPhone,
  supplies,
  equipment,
  maintenance,
  cleaningLaundry,
  marketing,
  licensing,
  insurance,
  paymentFees,
  easyBookFees,
  taxes,
  transport,
  other,
}

/// Describes how the owner classifies an expense for management reporting.
///
/// This is intentionally NOT an automatic recurrence engine. Every expense
/// document still represents a real cost that occurred on [expenseDate].
enum ExpenseFrequency { daily, monthly, yearly, emergency }

enum ExpenseGroup {
  staff,
  occupancy,
  operations,
  marketing,
  feesAndCompliance,
  other,
}

class ExpenseModel {
  final String id;
  final String businessId;
  final ExpenseCategory category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String paymentMethod;
  final String? supplier;
  final String? receiptUrl;
  final String? notes;
  final ExpenseFrequency frequency;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    required this.id,
    required this.businessId,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.paymentMethod,
    this.supplier,
    this.receiptUrl,
    this.notes,
    this.frequency = ExpenseFrequency.emergency,
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Daily/monthly/yearly describe an expected cadence; emergency is a
  /// one-off/unplanned cost. No cadence automatically creates extra expenses.
  bool get isRecurringClassification => frequency != ExpenseFrequency.emergency;

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const FormatException('Expense date is missing or invalid.');
  }

  factory ExpenseModel.fromFirestore(
    String documentId,
    Map<String, dynamic> json,
  ) {
    final rawCategory = json['category']?.toString() ?? 'other';
    final category = ExpenseCategory.values.firstWhere(
      (value) => value.name == rawCategory,
      orElse: () => ExpenseCategory.other,
    );

    // V1 stored real one-off expenses as `oneTime`. Keep those historical
    // documents readable and classify them as Emergency / One-time in V3.
    final rawFrequency = json['frequency']?.toString() ?? 'oneTime';
    final frequency = rawFrequency == 'oneTime'
        ? ExpenseFrequency.emergency
        : ExpenseFrequency.values.firstWhere(
            (value) => value.name == rawFrequency,
            orElse: () => ExpenseFrequency.emergency,
          );

    return ExpenseModel(
      id: documentId,
      businessId: json['businessId']?.toString() ?? '',
      category: category,
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      expenseDate: _parseDate(json['expenseDate']),
      paymentMethod: json['paymentMethod']?.toString() ?? 'Other',
      supplier: json['supplier']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
      notes: json['notes']?.toString(),
      frequency: frequency,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt:
          json['createdAt'] == null ? null : _parseDate(json['createdAt']),
      updatedAt:
          json['updatedAt'] == null ? null : _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'category': category.name,
      'description': description.trim(),
      'amount': amount,
      'expenseDate': Timestamp.fromDate(expenseDate),
      'paymentMethod': paymentMethod.trim(),
      // Keep optional strings explicit so editing a value to blank really clears
      // the old Firestore value instead of silently preserving stale data.
      'supplier': supplier?.trim() ?? '',
      'receiptUrl': receiptUrl?.trim() ?? '',
      'notes': notes?.trim() ?? '',
      'frequency': frequency.name,
      'isActive': isActive,
      'createdBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? businessId,
    ExpenseCategory? category,
    String? description,
    double? amount,
    DateTime? expenseDate,
    String? paymentMethod,
    String? supplier,
    String? receiptUrl,
    String? notes,
    ExpenseFrequency? frequency,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      supplier: supplier ?? this.supplier,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension ExpenseCategoryDetails on ExpenseCategory {
  /// Provides a sensible default while still allowing the owner to override it.
  ExpenseFrequency get suggestedFrequency {
    switch (this) {
      case ExpenseCategory.rent:
      case ExpenseCategory.salaries:
      case ExpenseCategory.commissions:
      case ExpenseCategory.utilities:
      case ExpenseCategory.internetPhone:
      case ExpenseCategory.marketing:
      case ExpenseCategory.paymentFees:
      case ExpenseCategory.easyBookFees:
        return ExpenseFrequency.monthly;
      case ExpenseCategory.supplies:
      case ExpenseCategory.cleaningLaundry:
      case ExpenseCategory.transport:
        return ExpenseFrequency.daily;
      case ExpenseCategory.licensing:
      case ExpenseCategory.insurance:
      case ExpenseCategory.taxes:
        return ExpenseFrequency.yearly;
      case ExpenseCategory.equipment:
      case ExpenseCategory.maintenance:
      case ExpenseCategory.other:
        return ExpenseFrequency.emergency;
    }
  }

  ExpenseGroup get group {
    switch (this) {
      case ExpenseCategory.salaries:
      case ExpenseCategory.commissions:
        return ExpenseGroup.staff;
      case ExpenseCategory.rent:
      case ExpenseCategory.utilities:
      case ExpenseCategory.internetPhone:
        return ExpenseGroup.occupancy;
      case ExpenseCategory.supplies:
      case ExpenseCategory.equipment:
      case ExpenseCategory.maintenance:
      case ExpenseCategory.cleaningLaundry:
      case ExpenseCategory.transport:
        return ExpenseGroup.operations;
      case ExpenseCategory.marketing:
        return ExpenseGroup.marketing;
      case ExpenseCategory.licensing:
      case ExpenseCategory.insurance:
      case ExpenseCategory.paymentFees:
      case ExpenseCategory.easyBookFees:
      case ExpenseCategory.taxes:
        return ExpenseGroup.feesAndCompliance;
      case ExpenseCategory.other:
        return ExpenseGroup.other;
    }
  }
}
