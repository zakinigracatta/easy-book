import 'package:go_router/go_router.dart';

// Auth Screens (1-5)
import '../screens/auth/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_verification_screen.dart';

// Customer Screens (6-29)
import '../screens/customer/home_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/categories_screen.dart';
import '../screens/customer/salon_list_screen.dart';
import '../screens/customer/salon_details_screen.dart';
import '../screens/customer/service_details_screen.dart';
import '../screens/customer/staff_profile_screen.dart';
import '../screens/customer/gallery_screen.dart';
import '../screens/customer/reviews_screen.dart';
import '../screens/customer/location_screen.dart';
import '../screens/customer/booking_service_screen.dart';
import '../screens/customer/booking_date_screen.dart';
import '../screens/customer/booking_time_screen.dart';
import '../screens/customer/booking_confirmation_screen.dart';
import '../screens/customer/payment_screen.dart';
import '../screens/customer/booking_success_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/customer/booking_details_screen.dart';
import '../screens/customer/cancel_booking_screen.dart';
import '../screens/customer/reschedule_booking_screen.dart';
import '../screens/customer/favorites_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/chat_screen.dart';
import '../screens/customer/customer_profile_screen.dart';

// Business Owner Screens (30-40)
import '../screens/business/owner_login_screen.dart';
import '../screens/business/owner_dashboard_screen.dart';
import '../screens/business/salon_management_screen.dart';
import '../screens/business/services_management_screen.dart';
import '../screens/business/add_service_screen.dart';
import '../screens/business/employee_management_screen.dart';
import '../screens/business/employee_schedule_screen.dart';
import '../screens/business/booking_calendar_screen.dart';
import '../screens/business/customer_management_screen.dart';
import '../screens/business/sales_report_screen.dart';
import '../screens/business/promotion_management_screen.dart';

// Admin Screens (41-47)
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/users_management_screen.dart';
import '../screens/admin/salon_approval_screen.dart';
import '../screens/admin/payment_management_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/reports_screen.dart';

// General & Settings Screens (48-50)
import '../screens/settings/settings_screen.dart';
import '../screens/settings/help_screen.dart';
import '../screens/settings/about_screen.dart';

import '../screens/business/business_register_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Auth (1-5)
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/business-register', builder: (context, state) => const BusinessRegisterScreen()),
    GoRoute(path: '/otp-verification', builder: (context, state) => const OTPVerificationScreen()),

    // Customer (6-29)
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
    GoRoute(path: '/salon-list', builder: (context, state) => const SalonListScreen()),
    GoRoute(path: '/salon-details', builder: (context, state) => const SalonDetailsScreen()),
    GoRoute(path: '/service-details', builder: (context, state) => const ServiceDetailsScreen()),
    GoRoute(path: '/staff-profile', builder: (context, state) => const StaffProfileScreen()),
    GoRoute(path: '/gallery', builder: (context, state) => const GalleryScreen()),
    GoRoute(path: '/reviews', builder: (context, state) => const ReviewsScreen()),
    GoRoute(path: '/location', builder: (context, state) => const LocationScreen()),
    GoRoute(path: '/booking', builder: (context, state) => const BookingServiceScreen()),
    GoRoute(path: '/booking-service', builder: (context, state) => const BookingServiceScreen()),
    GoRoute(path: '/booking-date', builder: (context, state) => const BookingDateScreen()),
    GoRoute(path: '/booking-time', builder: (context, state) => const BookingTimeScreen()),
    GoRoute(path: '/booking-confirmation', builder: (context, state) => const BookingConfirmationScreen()),
    GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
    GoRoute(path: '/booking-success', builder: (context, state) => const BookingSuccessScreen()),
    GoRoute(path: '/my-bookings', builder: (context, state) => const MyBookingsScreen()),
    GoRoute(path: '/booking-details', builder: (context, state) => const BookingDetailsScreen()),
    GoRoute(path: '/cancel-booking', builder: (context, state) => const CancelBookingScreen()),
    GoRoute(path: '/reschedule-booking', builder: (context, state) => const RescheduleBookingScreen()),
    GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/customer-profile', builder: (context, state) => const CustomerProfileScreen()),

    // Business Owner (30-40)
    GoRoute(path: '/owner-login', builder: (context, state) => const OwnerLoginScreen()),
    GoRoute(path: '/owner-dashboard', builder: (context, state) => const OwnerDashboardScreen()),
    GoRoute(path: '/salon-management', builder: (context, state) => const SalonManagementScreen()),
    GoRoute(path: '/services-management', builder: (context, state) => const ServicesManagementScreen()),
    GoRoute(path: '/add-service', builder: (context, state) => const AddServiceScreen()),
    GoRoute(path: '/employee-management', builder: (context, state) => const EmployeeManagementScreen()),
    GoRoute(path: '/employee-schedule', builder: (context, state) => const EmployeeScheduleScreen()),
    GoRoute(path: '/booking-calendar', builder: (context, state) => const BookingCalendarScreen()),
    GoRoute(path: '/customer-management', builder: (context, state) => const CustomerManagementScreen()),
    GoRoute(path: '/sales-report', builder: (context, state) => const SalesReportScreen()),
    GoRoute(path: '/promotion-management', builder: (context, state) => const PromotionManagementScreen()),

    // Admin (41-47)
    GoRoute(path: '/admin-login', builder: (context, state) => const AdminLoginScreen()),
    GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/users-management', builder: (context, state) => const UsersManagementScreen()),
    GoRoute(path: '/salon-approval', builder: (context, state) => const SalonApprovalScreen()),
    GoRoute(path: '/payment-management', builder: (context, state) => const PaymentManagementScreen()),
    GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),

    // General & Settings (48-50)
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
