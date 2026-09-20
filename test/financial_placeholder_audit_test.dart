import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unused financial and demo placeholder screens stay removed', () {
    const removedFiles = <String>[
      'lib/features/admin/admin_payouts_screen.dart',
      'lib/features/notifications/notifications_screen.dart',
      'lib/features/profile/wallet_screen.dart',
      'lib/features/profile/rewards_screen.dart',
      'lib/features/profile/gift_cards_screen.dart',
      'lib/features/profile/payment_methods_screen.dart',
      'lib/features/profile/subscription_plans_screen.dart',
      'lib/features/profile/deals_offers_screen.dart',
      'lib/features/profile/favorites_screen.dart',
      'lib/features/profile/reviews_screen.dart',
      'lib/features/profile/staff_directory_screen.dart',
      'lib/features/customer/mobile_wallet_pass_screen.dart',
    ];

    final remaining = removedFiles
        .where((path) => File(path).existsSync())
        .toList(growable: false);

    expect(
      remaining,
      isEmpty,
      reason: 'Dead placeholder screens returned:\n${remaining.join('\n')}',
    );
  });

  test('live payment surfaces stay honest until backend is connected', () {
    final customerPayment =
        File('lib/screens/customer/payment_screen.dart').readAsStringSync();
    final adminPayment =
        File('lib/screens/admin/payment_management_screen.dart')
            .readAsStringSync();

    expect(
      customerPayment,
      contains('Payment integration will be enabled in Phase 3.'),
    );
    expect(
      adminPayment,
      contains('Payments backend is not configured yet.'),
    );
    expect(
      File('lib/providers/auth_provider.dart').readAsStringSync(),
      isNot(contains('updateWalletBalance(')),
    );
  });

  test('known fake financial and demo claims are absent from active lib code', () {
    const forbidden = <String>[
      '1,450 Points',
      'VIP Gold Tier Member',
      'SARAH JENKINS',
      r'Balance: $240.00',
      'SUMMER30',
      'WELCOME20',
      'Marcus Vance',
      'Elena Rostova',
      r'Requested: $2,450.00',
      'Approve Payout',
    ];

    final failures = <String>[];
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      for (final value in forbidden) {
        if (source.contains(value)) {
          failures.add('${file.path}: $value');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Fake demo content remains:\n${failures.join('\n')}',
    );
  });
}
