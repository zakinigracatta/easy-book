/// Service to store and manage pending navigation routes for post-login redirects.
///
/// Designed to work seamlessly with Firebase Auth state listeners, GoRouter,
/// and guest authentication guards.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  String? _pendingRoute;

  /// Get the current pending target route, if any.
  String? get pendingRoute => _pendingRoute;

  /// Whether a pending post-login redirect route exists.
  bool get hasPendingRoute =>
      _pendingRoute != null && _pendingRoute!.isNotEmpty;

  /// Store a pending route to navigate to after successful authentication.
  void setPendingRoute(String route) {
    _pendingRoute = route;
  }

  /// Retrieve the pending route and clear it automatically.
  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  /// Clear the pending route without returning it.
  void clearPendingRoute() {
    _pendingRoute = null;
  }
}
