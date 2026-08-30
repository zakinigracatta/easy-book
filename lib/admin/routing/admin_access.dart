import '../../models/user_model.dart';
import '../permissions/admin_permissions.dart';

enum AdminAccessDecision { allow, signIn, forbidden, webOnly }

class AdminAccess {
  const AdminAccess._();

  static AdminAccessDecision evaluate({
    required UserModel? user,
    required bool isWeb,
  }) {
    if (user == null) return AdminAccessDecision.signIn;
    if (!AdminPermissions.isAdmin(user.role)) {
      return AdminAccessDecision.forbidden;
    }
    return isWeb ? AdminAccessDecision.allow : AdminAccessDecision.webOnly;
  }
}
