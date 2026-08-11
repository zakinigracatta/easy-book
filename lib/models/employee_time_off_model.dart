import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeTimeOffModel {
  final String id;
  final String? businessId;
  final String employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? notes;

  EmployeeTimeOffModel({
    required this.id,
    this.businessId,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.notes,
  });

  factory EmployeeTimeOffModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return EmployeeTimeOffModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['businessId'] as String? ?? json['business_id'] as String?,
      employeeId:
          json['employeeId'] as String? ?? json['employee_id'] as String? ?? '',
      employeeName: json['employeeName'] as String? ??
          json['employee_name'] as String? ??
          'Employee',
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      reason: json['reason'] as String? ?? 'Vacation / Day Off',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (businessId != null) 'businessId': businessId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      if (notes != null) 'notes': notes,
    };
  }
}
