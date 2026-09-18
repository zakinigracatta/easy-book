import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Portal language state is intentionally isolated from the customer app
/// locale. The portal currently supports English and Arabic only.
final adminLocaleProvider = StateProvider<Locale>(
  (ref) => const Locale('en'),
);
