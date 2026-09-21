import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy demo admin approval screens stay removed', () {
    expect(
      File('lib/features/admin/business_approval_screen.dart').existsSync(),
      isFalse,
    );
    expect(
      File('lib/features/admin/partner_verification_center_screen.dart').existsSync(),
      isFalse,
    );

    final router = File('lib/routes/app_router.dart').readAsStringSync();
    expect(router, contains("path: '/admin/approvals'"));
    expect(router, contains('const SalonApprovalScreen()'));
    expect(router, isNot(contains('BusinessApprovalScreen')));
    expect(router, isNot(contains('PartnerVerificationCenterScreen')));
  });
}
