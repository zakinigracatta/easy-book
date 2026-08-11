import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'navigation_service.dart';

/// Reusable authentication guard method.
///
/// Behavior:
/// - If user is logged in: returns true
/// - If guest: saves current intended route, navigates to /login, and returns false
Future<bool> requireLogin(BuildContext context,
    {String targetRoute = '/booking-service'}) async {
  bool isUserLoggedIn = false;

  try {
    final container = ProviderScope.containerOf(context, listen: false);
    final user = container.read(authProvider);
    isUserLoggedIn = (user != null);
  } catch (_) {
    // Fallback if context is outside ProviderScope
    isUserLoggedIn = false;
  }

  if (isUserLoggedIn) {
    return true;
  }

  // Guest mode -> Save intended target route and navigate to /login
  NavigationService().setPendingRoute(targetRoute);

  if (context.mounted) {
    await context.push('/login');
  }

  // Re-check authentication state after returning from /login
  if (!context.mounted) return false;

  try {
    final container = ProviderScope.containerOf(context, listen: false);
    final user = container.read(authProvider);
    return user != null;
  } catch (_) {
    return false;
  }
}
