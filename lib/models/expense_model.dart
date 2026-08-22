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

enum ExpenseFrequency { oneTime, monthly, yearly }

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
    this.frequency = ExpenseFrequency.oneTime,
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get isRecurring => frequency != ExpenseFrequency.oneTime;

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

    final rawFrequency = json['frequency']?.toString() ?? 'oneTime';
    final frequency = ExpenseFrequency.values.firstWhere(
      (value) => value.name == rawFrequency,
      orElse: () => ExpenseFrequency.oneTime,
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
      createdAt: json['createdAt'] == null ? null : _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] == null ? null : _parseDate(json['updatedAt']),
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
      if (supplier != null && supplier!.trim().isNotEmpty)
        'supplier': supplier!.trim(),
      if (receiptUrl != null && receiptUrl!.trim().isNotEmpty)
        'receiptUrl': receiptUrl!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
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

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.salaries:
        return 'Staff Salaries';
      case ExpenseCategory.commissions:
        return 'Staff Commissions';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.internetPhone:
        return 'Internet & Phone';
      case ExpenseCategory.supplies:
        return 'Products & Supplies';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.cleaningLaundry:
        return 'Cleaning & Laundry';
      case ExpenseCategory.marketing:
        return 'Marketing & Advertising';
      case ExpenseCategory.licensing:
        return 'Licensing & Government Fees';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.paymentFees:
        return 'Payment & Bank Fees';
      case ExpenseCategory.easyBookFees:
        return 'Easy Book Fees';
      case ExpenseCategory.taxes:
        return 'Taxes / VAT';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}
