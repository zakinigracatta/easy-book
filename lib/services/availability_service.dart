import 'package:cloud_functions/cloud_functions.dart';

import '../models/employee_time_off_model.dart';

class AvailabilityService {
  final FirebaseFunctions _functions;

  AvailabilityService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<List<EmployeeTimeOffModel>> getPublicTimeOffs({
    required String businessId,
  }) async {
    final normalizedBusinessId = businessId.trim();
    if (normalizedBusinessId.isEmpty) return [];

    final callable = _functions.httpsCallable('getAvailabilityBlocks');
    final response = await callable.call({
      'businessId': normalizedBusinessId,
    });

    if (response.data is! Map) return [];
    final payload = Map<String, dynamic>.from(response.data as Map);
    final rawBlocks = payload['blocks'];
    if (rawBlocks is! List) return [];

    final result = <EmployeeTimeOffModel>[];
    for (final item in rawBlocks) {
      if (item is! Map) continue;
      final data = Map<String, dynamic>.from(item);
      final employeeId = (data['employeeId'] ?? '').toString().trim();
      final start = DateTime.tryParse((data['startDate'] ?? '').toString());
      final end = DateTime.tryParse((data['endDate'] ?? '').toString());
      if (employeeId.isEmpty || start == null || end == null) continue;

      result.add(
        EmployeeTimeOffModel(
          id: (data['id'] ?? '').toString(),
          businessId: normalizedBusinessId,
          employeeId: employeeId,
          employeeName: '',
          startDate: start.toLocal(),
          endDate: end.toLocal(),
          reason: '',
        ),
      );
    }

    return result;
  }


}
