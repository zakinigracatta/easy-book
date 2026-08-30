import '../models/user_model.dart';

/// The single source of truth for deciding which application area a role owns.
class RoleRouting {
  const RoleRouting._();

  static const adminLogin = '/admin-login';
  static const customerHome = '/home';
  static const ownerHome = '/owner-dashboard';

  static String homeFor(UserModel user) => homeForRole(user.role);

  static String homeForRole(UserRole role) => switch (role) {
        UserRole.admin || UserRole.superAdmin => '/admin',
        UserRole.owner || UserRole.businessOwner => ownerHome,
        UserRole.customer => customerHome,
      };

  static bool isAdminPath(String path) =>
      path == '/admin' ||
      path.startsWith('/admin/') ||
      const {
        '/admin-dashboard',
        '/users-management',
        '/salon-approval',
        '/payment-management',
        '/analytics',
        '/reports',
      }.contains(path);

  static bool isOwnerPath(String path) => const {
        '/owner-dashboard',
        '/salon-management',
        '/services-management',
        '/add-service',
        '/employee-management',
        '/add-employee',
        '/employee-schedule',
        '/booking-calendar',
        '/customer-management',
        '/sales-report',
        '/promotion-management',
      }.contains(path);

  static bool isCustomerPath(String path) => const {
        '/home',
        '/search',
        '/categories',
        '/salon-list',
        '/salon-details',
        '/service-details',
        '/staff-profile',
        '/gallery',
        '/reviews',
        '/location',
        '/booking',
        '/booking-service',
        '/booking-date',
        '/booking-time',
        '/booking-confirmation',
        '/payment',
        '/booking-success',
        '/my-bookings',
        '/booking-details',
        '/cancel-booking',
        '/reschedule-booking',
        '/favorites',
        '/notifications',
        '/chat',
        '/customer-profile',
      }.contains(path);

  /// Returns null when the requested location is valid for the session.
  static String? redirect({
    required String path,
    required UserModel? user,
    required bool sessionResolved,
  }) {
    const startupPaths = {'/', '/splash'};
    const signedOutPaths = {
      '/welcome',
      '/login',
      '/register',
      '/business-register',
      '/owner-login',
      adminLogin,
      '/forgot-password',
      '/otp-verification',
    };

    if (!sessionResolved) {
      return startupPaths.contains(path) ? null : '/splash';
    }

    if (user == null) {
      if (isAdminPath(path)) return adminLogin;
      if (isOwnerPath(path)) return '/owner-login';
      return null;
    }

    // Email verification remains reachable for every authenticated role.
    if (path == '/email-verification') return null;

    final home = homeFor(user);
    if (startupPaths.contains(path) || signedOutPaths.contains(path)) {
      return home;
    }

    if (user.isAdmin) {
      return isAdminPath(path) ? null : home;
    }
    if (user.role == UserRole.owner || user.role == UserRole.businessOwner) {
      return isAdminPath(path) || isCustomerPath(path) ? home : null;
    }
    return isAdminPath(path) || isOwnerPath(path) ? home : null;
  }
}
