import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/customer_profile_service.dart';

final customerProfileServiceProvider = Provider<CustomerProfileService>((ref) {
  return CustomerProfileService();
});

final customerProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final service = ref.watch(customerProfileServiceProvider);
  return service.fetchCurrentProfile();
});
