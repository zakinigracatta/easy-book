import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('financial placeholder screens do not present fake balances or actions', () {
    const files = <String>[
      'lib/features/profile/wallet_screen.dart',
      'lib/features/profile/rewards_screen.dart',
      'lib/features/profile/gift_cards_screen.dart',
      'lib/features/admin/admin_payouts_screen.dart',
    ];

    const forbidden = <String>[
      '250.00',
      '1,450 Points',
      'VIP Gold Tier Member',
      '550 pts until Platinum Tier',
      r'\$15 Off Any Hair Salon Booking',
      'Purchase Gift Voucher',
      'Added \\$50.00 to your wallet!',
      'Executive Barber Lounge',
      r'Requested: \$2,450.00',
      'Approve Payout',
      'updateWalletBalance(',
    ];

    final failures = <String>[];
    for (final path in files) {
      final source = File(path).readAsStringSync();
      for (final value in forbidden) {
        if (source.contains(value)) {
          failures.add('$path: $value');
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Fake financial claims/actions remain:\n${failures.join('\n')}',
    );
  });

  test('unconnected financial features fail honestly', () {
    expect(
      File('lib/features/profile/wallet_screen.dart').readAsStringSync(),
      contains('Wallet is not connected yet.'),
    );
    expect(
      File('lib/features/profile/rewards_screen.dart').readAsStringSync(),
      contains('Rewards are not connected yet.'),
    );
    expect(
      File('lib/features/profile/gift_cards_screen.dart').readAsStringSync(),
      contains('Gift cards are not connected yet.'),
    );
    expect(
      File('lib/features/admin/admin_payouts_screen.dart').readAsStringSync(),
      contains('Payout management is not connected yet.'),
    );
  });
}
