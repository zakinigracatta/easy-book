import 'package:flutter/material.dart';

import 'owner_finance_screen.dart';

/// Backward-compatible route target for `/sales-report`.
///
/// The legacy screen contained hard-coded chart values and treated every
/// non-cancelled booking as revenue. The owner portal now routes this entry
/// point to the real owner-only Finance & Profit module.
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OwnerFinanceScreen();
  }
}
