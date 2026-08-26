import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Null follows the device locale. A concrete locale is an explicit in-app
/// language choice for the current session.
final localeProvider = StateProvider<Locale?>((ref) => null);
