import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner business resolution does not probe businesses/{uid} first', () {
    final source =
        File('lib/providers/owner_providers.dart').readAsStringSync();

    expect(source, contains(".where('ownerId', isEqualTo: user.uid)"));
    expect(source, contains(".where('owner_id', isEqualTo: user.uid)"));
    expect(
      source,
      isNot(contains(".collection('businesses')\n      .doc(user.uid)\n      .get()")),
    );
  });

  test('public availability is range-scoped and active-staff scoped', () {
    final source = File(
      'functions/src/booking/getAvailabilityBlocks.ts',
    ).readAsStringSync();

    expect(source, contains('startAt and endAt are required'));
    expect(source, contains('activeStaffIdSet'));
    expect(source, contains('activeStaffIds'));
    expect(source, contains('businessStatus !== \'open\''));
    expect(source, isNot(contains('id: doc.id')));
  });

  test('booking backend requires explicit active staff', () {
    final source =
        File('functions/src/booking/bookingValidation.ts').readAsStringSync();

    expect(
      source,
      contains('(staffData.isActive ?? staffData.is_active) !== true'),
    );
  });

  test('user wallet balance remains server-owned in Firestore rules', () {
    final source = File('firestore.rules').readAsStringSync();

    expect(
      source,
      contains(
        "(!('wallet_balance' in request.resource.data) || request.resource.data.wallet_balance == 0)",
      ),
    );
    expect(
      source,
      isNot(
        contains(
          "affectedKeys().hasOnly(['role', 'email'])",
        ),
      ),
    );
  });

  test('business media reads are gated by publication or privileged access', () {
    final source = File('storage.rules').readAsStringSync();

    expect(source, contains('function canReadBusinessAsset(businessId)'));
    expect(
      RegExp(
        r'match /businesses/\{businessId\}/profile/\{allPaths=\*\*\} \{[\s\S]*?allow read: if canReadBusinessAsset\(businessId\);',
      ).hasMatch(source),
      isTrue,
    );
    expect(
      RegExp(
        r'match /businesses/\{businessId\}/gallery/\{imageId\}/\{fileName\} \{[\s\S]*?allow read: if canReadBusinessAsset\(businessId\);',
      ).hasMatch(source),
      isTrue,
    );
  });
}
