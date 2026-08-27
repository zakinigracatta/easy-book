import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

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

// Admin Screens (preserved for Web Admin Portal)
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/payment_management_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/admin/salon_approval_screen.dart';
import '../screens/admin/users_management_screen.dart';
import '../screens/admin/admin_access_denied_screen.dart';
import '../screens/admin/web_only_admin_access_screen.dart';

// General & Settings Screens
import '../screens/settings/about_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/settings/settings_screen.dart';

// ---------------------------------------------------------------------------
// Admin route constants — centralized for test access
// ---------------------------------------------------------------------------

/// All routes that require an admin or super_admin role.
const adminProtectedRoutes = [
  '/admin',
  '/admin/dashboard',
  '/admin/users',
  '/admin/approvals',
  '/admin/payments',
  '/admin/analytics',
  '/admin/reports',
];

/// Admin sign-in page (web only).
const adminLoginRoute = '/admin/login';

/// Shown to admin users on mobile (Admin Portal is web-only).
const adminWebOnlyRoute = '/admin-web-only';

/// Shown to non-admin users attempting to access /admin on web.
const adminAccessDeniedRoute = '/admin/access-denied';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final loc = state.matchedLocation;
    if (loc == '/splash') return null;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      const allowedUnverified = [
        '/verify-email',
        '/welcome',
        '/login',
        '/register',
        '/business-register',
        '/owner-login',
        '/splash',
        '/forgot-password',
      ];
      if (!allowedUnverified.contains(loc)) {
        return '/verify-email';
      }
    }

    UserModel? currentUserModel;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      currentUserModel = container.read(authProvider);
    } catch (_) {}

    // -----------------------------------------------------------------------
    // Owner / Business Partner route protection
    // -----------------------------------------------------------------------
    const ownerProtectedRoutes = [
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
    ];

    if (ownerProtectedRoutes.contains(loc)) {
      if (user == null) return '/owner-login';
      if (currentUserModel != null &&
          currentUserModel.role != UserRole.owner &&
          currentUserModel.role != UserRole.businessOwner) {
        return '/home';
      }
    }

    // -----------------------------------------------------------------------
    // Admin route protection — centralized guard
    // -----------------------------------------------------------------------
    if (adminProtectedRoutes.contains(loc)) {
      // On mobile, admin portal is not available — show web-only screen.
      if (!kIsWeb) {
        return adminWebOnlyRoute;
      }

      // Unauthenticated → admin login
      if (user == null) return adminLoginRoute;

      // Authenticated but not admin → access denied
      if (currentUserModel != null && !currentUserModel.isAdmin) {
        return adminAccessDeniedRoute;
      }
    }

    // Admin login page: only on web, and if already admin → go to dashboard
    if (loc == adminLoginRoute) {
      if (!kIsWeb) return adminWebOnlyRoute;
      if (user != null && currentUserModel != null && currentUserModel.isAdmin) {
        return '/admin/dashboard';
      }
    }

    // -----------------------------------------------------------------------
    // Customer route protection
    // -----------------------------------------------------------------------
    const customerProtectedRoutes = [
      '/my-bookings',
      '/booking-details',
      '/reschedule-booking',
      '/cancel-booking',
      '/favorites',
      '/customer-profile',
      '/chat',
    ];

    if (user == null && customerProtectedRoutes.contains(loc)) {
      return '/login';
    }

    return null;
  },
  routes: [
    // =====================================================================
    // Auth & Onboarding
    // =====================================================================
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

    // =====================================================================
    // Customer Screens (public browsing + protected actions)
    // =====================================================================
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
      builder: (context, state) => BookingSuccessScreen(
        booking:
            state.extra is BookingModel ? state.extra as BookingModel : null,
      ),
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

    // =====================================================================
    // Business Owner / Partner Screens
    // =====================================================================
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

    // =====================================================================
    // Admin Portal (Web-only — centrally guarded by redirect above)
    // =====================================================================
    GoRoute(
      path: adminLoginRoute,
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const UsersManagementScreen(),
    ),
    GoRoute(
      path: '/admin/approvals',
      builder: (context, state) => const SalonApprovalScreen(),
    ),
    GoRoute(
      path: '/admin/payments',
      builder: (context, state) => const PaymentManagementScreen(),
    ),
    GoRoute(
      path: '/admin/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/admin/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: adminAccessDeniedRoute,
      builder: (context, state) => const AdminAccessDeniedScreen(),
    ),

    // Admin on mobile — web-only notice screen
    GoRoute(
      path: adminWebOnlyRoute,
      builder: (context, state) => const WebOnlyAdminAccessScreen(),
    ),

    // =====================================================================
    // Legacy admin routes — redirect to new paths for backward compatibility
    // =====================================================================
    GoRoute(
      path: '/admin-login',
      redirect: (context, state) => adminLoginRoute,
    ),
    GoRoute(
      path: '/admin-dashboard',
      redirect: (context, state) => '/admin/dashboard',
    ),
    GoRoute(
      path: '/users-management',
      redirect: (context, state) => '/admin/users',
    ),
    GoRoute(
      path: '/salon-approval',
      redirect: (context, state) => '/admin/approvals',
    ),
    GoRoute(
      path: '/payment-management',
      redirect: (context, state) => '/admin/payments',
    ),
    GoRoute(
      path: '/analytics',
      redirect: (context, state) => '/admin/analytics',
    ),
    GoRoute(
      path: '/reports',
      redirect: (context, state) => '/admin/reports',
    ),

    // =====================================================================
    // General & Settings
    // =====================================================================
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
