import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Stores post-login navigation targets in memory and, when Hive is available,
/// in the settings box so a browser refresh or app restart during sign-in does
/// not lose the original protected route.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  static const String _pendingRouteKey = 'pending_navigation_route';

  factory NavigationService() => _instance;

  NavigationService._internal();

  String? _pendingRoute;

  String? _storedPendingRoute() {
    if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return null;
    final value =
        Hive.box(AppConstants.hiveSettingsBox).get(_pendingRouteKey);
    final route = value is String ? value.trim() : '';
    return route.isEmpty ? null : route;
  }

  void _persistPendingRoute(String? route) {
    if (!Hive.isBoxOpen(AppConstants.hiveSettingsBox)) return;
    final box = Hive.box(AppConstants.hiveSettingsBox);
    if (route == null || route.trim().isEmpty) {
      box.delete(_pendingRouteKey);
    } else {
      box.put(_pendingRouteKey, route.trim());
    }
  }

  /// Get the current pending target route, recovering it from local storage
  /// when the process or browser page was restarted during authentication.
  String? get pendingRoute {
    final memoryRoute = _pendingRoute?.trim() ?? '';
    if (memoryRoute.isNotEmpty) return memoryRoute;

    final storedRoute = _storedPendingRoute();
    if (storedRoute != null) {
      _pendingRoute = storedRoute;
    }
    return storedRoute;
  }

  /// Whether a pending post-login redirect route exists.
  bool get hasPendingRoute => pendingRoute != null;

  /// Store a pending route to navigate to after successful authentication.
  void setPendingRoute(String route) {
    final normalized = route.trim();
    if (normalized.isEmpty) {
      clearPendingRoute();
      return;
    }
    _pendingRoute = normalized;
    _persistPendingRoute(normalized);
  }

  /// Retrieve the pending route and clear it automatically.
  String? consumePendingRoute() {
    final route = pendingRoute;
    _pendingRoute = null;
    _persistPendingRoute(null);
    return route;
  }

  /// Clear the pending route without returning it.
  void clearPendingRoute() {
    _pendingRoute = null;
    _persistPendingRoute(null);
  }
}
