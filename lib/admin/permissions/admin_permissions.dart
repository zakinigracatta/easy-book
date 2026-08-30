import '../../models/user_model.dart';

enum AdminPermission {
  viewDashboard,
  manageBusinesses,
  manageUsers,
  manageBookings,
  manageFinance,
  moderateReviews,
  sendNotifications,
  viewReports,
  manageAdmins,
  changePlatformSettings,
}

class AdminPermissions {
  const AdminPermissions._();

  static bool isAdmin(UserRole role) =>
      role == UserRole.admin || role == UserRole.superAdmin;

  static bool allows(UserRole role, AdminPermission permission) {
    if (role == UserRole.superAdmin) return true;
    if (role != UserRole.admin) return false;
    return permission != AdminPermission.manageAdmins &&
        permission != AdminPermission.changePlatformSettings;
  }
}
