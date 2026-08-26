import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/user_model.dart';

// Auth Screens
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/welcome_screen.dart';

// Customer Screens
import '../screens/customer/booking_confirmation_screen.dart';
import '../screens/customer/booking_date_screen.dart';
import '../screens/customer/booking_details_screen.dart';
import '../screens/customer/booking_service_screen.dart';
import '../screens/customer/booking_specialist_screen.dart';
import '../screens/customer/booking_success_screen.dart';
import '../screens/customer/booking_summary_screen.dart';
import '../screens/customer/booking_time_screen.dart';
import '../screens/customer/cancel_booking_screen.dart';
import '../screens/customer/categories_screen.dart';
import '../screens/customer/chat_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/customer/favorites_screen.dart';
import '../screens/customer/gallery_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/location_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/payment_screen.dart';
import '../screens/customer/reschedule_booking_screen.dart';
import '../screens/customer/reviews_screen.dart';
import '../screens/customer/salon_details_screen.dart';
import '../screens/customer/salon_list_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/service_details_screen.dart';
import '../screens/customer/staff_profile_screen.dart';

// Business Owner Screens
import '../screens/business/add_edit_employee_screen.dart';
import '../screens/business/add_service_screen.dart';
import '../screens/business/booking_calendar_screen.dart';
import '../screens/business/business_register_screen.dart';
import '../screens/business/business_working_hours_screen.dart';
import '../screens/business/customer_management_screen.dart';
import '../screens/business/employee_management_screen.dart';
import '../screens/business/employee_schedule_screen.dart';
import '../screens/business/employee_time_off_screen.dart';
import '../screens/business/owner_bookings_screen.dart';
import '../screens/business/owner_dashboard_screen.dart';
import '../screens/business/owner_gallery_screen.dart';
import '../screens/business/owner_login_screen.dart';
import '../screens/business/owner_more_screen.dart';
import '../screens/business/owner_notifications_screen.dart';
import '../screens/business/owner_reviews_screen.dart';
import '../screens/business/promotion_management_screen.dart';
import '../screens/business/quick_walk_in_booking_screen.dart';
import '../screens/business/sales_report_screen.dart';
import '../screens/business/salon_management_screen.dart';
import '../screens/business/services_management_screen.dart';

// Admin Screens
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/payment_management_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/admin/salon_approval_screen.dart';
import '../screens/admin/users_management_screen.dart';

// General & Settings Screens
import '../screens/settings/about_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/settings/settings_screen.dart';

final Map<String, UserRole> _roleCache = <String, UserRole>{};

const Set<String> _ownerOnlyRoutes = {
  '/owner-dashboard',
  '/owner-bookings',
  '/quick-walk-in',
  '/salon-management',
  '/services-management',
  '/add-service',
  '/employee-management',
  '/add-employee',
  '/employee-schedule',
  '/employee-time-off',
  '/business-hours',
  '/owner-gallery',
  '/booking-calendar',
  '/customer-management',
  '/owner-reviews',
  '/sales-report',
  '/promotion-management',
  '/owner-more',
  '/owner-notifications',
};

const Set<String> _adminOnlyRoutes = {
  '/admin-dashboard',
  '/users-management',
  '/salon-approval',
  '/payment-management',
  '/analytics',
  '/reports',
};

const Set<String> _customerPrivateRoutes = {
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
};

bool _isOwnerRole(UserRole role) =>
    role == UserRole.owner || role == UserRole.businessOwner;

String _landingRoute(UserRole role) {
  if (_isOwnerRole(role)) return '/owner-dashboard';
  if (role == UserRole.admin) return '/admin-dashboard';
  return '/home';
}

Future<UserRole> _resolveRole(User user) async {
  final cached = _roleCache[user.uid];
  if (cached != null) return cached;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!snapshot.exists || snapshot.data() == null) {
    _roleCache[user.uid] = UserRole.customer;
    return UserRole.customer;
  }

  final profile = UserModel.fromJson({
    ...snapshot.data()!,
    'id': user.uid,
    'email': user.email ?? snapshot.data()!['email'] ?? '',
  });
  _roleCache[user.uid] = profile.role;
  return profile.role;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final path = state.matchedLocation;
    if (path == '/splash') return null;

    final user = FirebaseAuth.instance.currentUser;
    final ownerRoute = _ownerOnlyRoutes.contains(path);
    final adminRoute = _adminOnlyRoutes.contains(path);
    final customerPrivateRoute = _customerPrivateRoutes.contains(path);

    if (!ownerRoute && !adminRoute && !customerPrivateRoute) {
      if (path == '/verify-email' && user == null) return '/login';
      return null;
    }

    if (user == null) {
      if (ownerRoute) return '/owner-login';
      if (adminRoute) return '/admin-login';
      return '/login';
    }

    if (!user.emailVerified) return '/verify-email';

    UserRole role;
    try {
      role = await _resolveRole(user);
    } catch (_) {
      // Do not grant a privileged route if the role cannot be verified.
      if (ownerRoute) return '/owner-login';
      if (adminRoute) return '/admin-login';
      return '/home';
    }

    if (ownerRoute && !_isOwnerRole(role)) {
      return role == UserRole.admin ? '/admin-dashboard' : '/owner-login';
    }

    if (adminRoute && role != UserRole.admin) {
      return _isOwnerRole(role) ? '/owner-dashboard' : '/admin-login';
    }

    if (customerPrivateRoute && role != UserRole.customer) {
      return _landingRoute(role);
    }

    return null;
  },
  routes: [
    // Auth
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/business-register',
      builder: (context, state) => const BusinessRegisterScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) => const OTPVerificationScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Customer
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/salon-list',
      builder: (context, state) => const SalonListScreen(),
    ),
    GoRoute(
      path: '/salon-details',
      builder: (context, state) {
        final extraId = state.extra as String?;
        return SalonDetailsScreen(businessId: extraId);
      },
    ),
    GoRoute(
      path: '/salon/:id',
      builder: (context, state) {
        final pathId = state.pathParameters['id'];
        final extraId = state.extra as String?;
        return SalonDetailsScreen(businessId: pathId ?? extraId);
      },
    ),
    GoRoute(
      path: '/service-details',
      builder: (context, state) => const ServiceDetailsScreen(),
    ),
    GoRoute(
      path: '/staff-profile',
      builder: (context, state) => const StaffProfileScreen(),
    ),
    GoRoute(path: '/gallery', builder: (context, state) => const GalleryScreen()),
    GoRoute(path: '/reviews', builder: (context, state) => const ReviewsScreen()),
    GoRoute(path: '/location', builder: (context, state) => const LocationScreen()),
    GoRoute(
      path: '/booking',
      builder: (context, state) => const BookingServiceScreen(),
    ),
    GoRoute(
      path: '/booking-service',
      builder: (context, state) => const BookingServiceScreen(),
    ),
    GoRoute(
      path: '/booking-specialist',
      builder: (context, state) => const BookingSpecialistScreen(),
    ),
    GoRoute(
      path: '/booking-date',
      builder: (context, state) => const BookingDateScreen(),
    ),
    GoRoute(
      path: '/booking-time',
      builder: (context, state) => const BookingTimeScreen(),
    ),
    GoRoute(
      path: '/booking-summary',
      builder: (context, state) => const BookingSummaryScreen(),
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (context, state) => const BookingConfirmationScreen(),
    ),
    GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
    GoRoute(
      path: '/booking-success',
      builder: (context, state) => const BookingSuccessScreen(),
    ),
    GoRoute(
      path: '/my-bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/booking-details',
      builder: (context, state) {
        final booking = state.extra as BookingModel?;
        return BookingDetailsScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/cancel-booking',
      builder: (context, state) {
        final bookingId = state.extra as String?;
        return CancelBookingScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/reschedule-booking',
      builder: (context, state) {
        final booking = state.extra as BookingModel?;
        return RescheduleBookingScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(
      path: '/customer-profile',
      builder: (context, state) => const CustomerProfileScreen(),
    ),

    // Business Owner Dashboard & Portal
    GoRoute(
      path: '/owner-login',
      builder: (context, state) => const OwnerLoginScreen(),
    ),
    GoRoute(
      path: '/owner-dashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/owner-bookings',
      builder: (context, state) => const OwnerBookingsScreen(),
    ),
    GoRoute(
      path: '/quick-walk-in',
      builder: (context, state) => const QuickWalkInBookingScreen(),
    ),
    GoRoute(
      path: '/salon-management',
      builder: (context, state) => const SalonManagementScreen(),
    ),
    GoRoute(
      path: '/services-management',
      builder: (context, state) => const ServicesManagementScreen(),
    ),
    GoRoute(
      path: '/add-service',
      builder: (context, state) {
        final service = state.extra as ServiceModel?;
        return AddServiceScreen(initialService: service);
      },
    ),
    GoRoute(
      path: '/employee-management',
      builder: (context, state) => const EmployeeManagementScreen(),
    ),
    GoRoute(
      path: '/add-employee',
      builder: (context, state) {
        final staff = state.extra as StaffModel?;
        return AddEditEmployeeScreen(initialStaff: staff);
      },
    ),
    GoRoute(
      path: '/employee-schedule',
      builder: (context, state) => const EmployeeScheduleScreen(),
    ),
    GoRoute(
      path: '/employee-time-off',
      builder: (context, state) => const EmployeeTimeOffScreen(),
    ),
    GoRoute(
      path: '/business-hours',
      builder: (context, state) => const BusinessWorkingHoursScreen(),
    ),
    GoRoute(
      path: '/owner-gallery',
      builder: (context, state) => const OwnerGalleryScreen(),
    ),
    GoRoute(
      path: '/booking-calendar',
      builder: (context, state) => const BookingCalendarScreen(),
    ),
    GoRoute(
      path: '/customer-management',
      builder: (context, state) => const CustomerManagementScreen(),
    ),
    GoRoute(
      path: '/owner-reviews',
      builder: (context, state) => const OwnerReviewsScreen(),
    ),
    GoRoute(
      path: '/sales-report',
      builder: (context, state) => const SalesReportScreen(),
    ),
    GoRoute(
      path: '/promotion-management',
      builder: (context, state) => const PromotionManagementScreen(),
    ),
    GoRoute(
      path: '/owner-more',
      builder: (context, state) => const OwnerMoreScreen(),
    ),
    GoRoute(
      path: '/owner-notifications',
      builder: (context, state) => const OwnerNotificationsScreen(),
    ),

    // Admin
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/users-management',
      builder: (context, state) => const UsersManagementScreen(),
    ),
    GoRoute(
      path: '/salon-approval',
      builder: (context, state) => const SalonApprovalScreen(),
    ),
    GoRoute(
      path: '/payment-management',
      builder: (context, state) => const PaymentManagementScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),

    // General & Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
