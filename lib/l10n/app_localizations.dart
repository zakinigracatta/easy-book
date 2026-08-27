import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Book'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your portal'**
  String get signInSubtitle;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @businessOwner.
  ///
  /// In en, this message translates to:
  /// **'Business Owner'**
  String get businessOwner;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email / Phone'**
  String get emailOrPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @registerAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Register as Customer?'**
  String get registerAsCustomer;

  /// No description provided for @customerRegister.
  ///
  /// In en, this message translates to:
  /// **'Customer Register'**
  String get customerRegister;

  /// No description provided for @registerAsPartner.
  ///
  /// In en, this message translates to:
  /// **'Register as Partner?'**
  String get registerAsPartner;

  /// No description provided for @ownerRegister.
  ///
  /// In en, this message translates to:
  /// **'Owner Register'**
  String get ownerRegister;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @appearanceAndTheme.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE & THEME'**
  String get appearanceAndTheme;

  /// No description provided for @darkThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme Mode'**
  String get darkThemeMode;

  /// No description provided for @darkModeActive.
  ///
  /// In en, this message translates to:
  /// **'Dark mode active'**
  String get darkModeActive;

  /// No description provided for @lightModeActive.
  ///
  /// In en, this message translates to:
  /// **'Light mode active'**
  String get lightModeActive;

  /// No description provided for @systemModeActive.
  ///
  /// In en, this message translates to:
  /// **'System mode active'**
  String get systemModeActive;

  /// No description provided for @themePreference.
  ///
  /// In en, this message translates to:
  /// **'Theme Preference'**
  String get themePreference;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app display language'**
  String get languageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @preferencesAndHelp.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES & HELP'**
  String get preferencesAndHelp;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminders and status updates'**
  String get notificationsSubtitle;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @aboutEasyBook.
  ///
  /// In en, this message translates to:
  /// **'About Easy Book'**
  String get aboutEasyBook;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get invalidCredentials;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @salonProfile.
  ///
  /// In en, this message translates to:
  /// **'Salon Profile'**
  String get salonProfile;

  /// No description provided for @servicesMenu.
  ///
  /// In en, this message translates to:
  /// **'Services Menu'**
  String get servicesMenu;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @employeeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Employee Schedule'**
  String get employeeSchedule;

  /// No description provided for @bookingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Booking Calendar'**
  String get bookingCalendar;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @salonApprovals.
  ///
  /// In en, this message translates to:
  /// **'Salon Approvals'**
  String get salonApprovals;

  /// No description provided for @paymentManagement.
  ///
  /// In en, this message translates to:
  /// **'Payment Management'**
  String get paymentManagement;

  /// No description provided for @platformAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Platform Analytics'**
  String get platformAnalytics;

  /// No description provided for @reportsAndLogs.
  ///
  /// In en, this message translates to:
  /// **'Reports & Logs'**
  String get reportsAndLogs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @exitPortal.
  ///
  /// In en, this message translates to:
  /// **'Exit Portal'**
  String get exitPortal;

  /// No description provided for @salonManagementCenter.
  ///
  /// In en, this message translates to:
  /// **'Salon Management Center'**
  String get salonManagementCenter;

  /// No description provided for @platformSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform Super Admin'**
  String get platformSuperAdmin;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get noShow;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password? 🔑'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentDescription.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a password reset link has been sent. Please check your inbox and follow the instructions.'**
  String get resetLinkSentDescription;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @verifyPhoneOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone / OTP'**
  String get verifyPhoneOtp;

  /// No description provided for @enterFourDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-Digit Code'**
  String get enterFourDigitCode;

  /// No description provided for @otpSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your registered mobile number.'**
  String get otpSentDescription;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @businessPortalLogin.
  ///
  /// In en, this message translates to:
  /// **'Business Portal Login'**
  String get businessPortalLogin;

  /// No description provided for @salonPartnerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Salon Partner Sign In'**
  String get salonPartnerSignIn;

  /// No description provided for @ownerLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage appointments, staff schedules & sales'**
  String get ownerLoginSubtitle;

  /// No description provided for @salonEmail.
  ///
  /// In en, this message translates to:
  /// **'Salon Email'**
  String get salonEmail;

  /// No description provided for @openPartnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Partner Dashboard'**
  String get openPartnerDashboard;

  /// No description provided for @ownerCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter salon email and password.'**
  String get ownerCredentialsRequired;

  /// No description provided for @partnerAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Partner authentication failed.'**
  String get partnerAuthenticationFailed;

  /// No description provided for @bookingsManagement.
  ///
  /// In en, this message translates to:
  /// **'Bookings Management'**
  String get bookingsManagement;

  /// No description provided for @newWalkIn.
  ///
  /// In en, this message translates to:
  /// **'New Walk-in'**
  String get newWalkIn;

  /// No description provided for @bookingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by customer, phone, or ID...'**
  String get bookingSearchHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noBookingsFound.
  ///
  /// In en, this message translates to:
  /// **'No Bookings Found'**
  String get noBookingsFound;

  /// No description provided for @noBookingsMatch.
  ///
  /// In en, this message translates to:
  /// **'No bookings match your current filter or search criteria.'**
  String get noBookingsMatch;

  /// No description provided for @newWalkInBooking.
  ///
  /// In en, this message translates to:
  /// **'New Walk-in Booking'**
  String get newWalkInBooking;

  /// No description provided for @bookingStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Booking status updated successfully.'**
  String get bookingStatusUpdated;

  /// No description provided for @bookingStatusUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update booking status.'**
  String get bookingStatusUpdateFailed;

  /// No description provided for @unableToLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Bookings'**
  String get unableToLoadBookings;

  /// No description provided for @bookingLoadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while retrieving bookings.'**
  String get bookingLoadError;

  /// No description provided for @businessManagementMenu.
  ///
  /// In en, this message translates to:
  /// **'Business Management Menu'**
  String get businessManagementMenu;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS'**
  String get business;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'TEAM'**
  String get team;

  /// No description provided for @marketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketing;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'FINANCE'**
  String get finance;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @photosAndGallery.
  ///
  /// In en, this message translates to:
  /// **'Photos & Gallery'**
  String get photosAndGallery;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get businessHours;

  /// No description provided for @employeesAndSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Employees & Specialists'**
  String get employeesAndSpecialists;

  /// No description provided for @employeeRostersAndTimeOff.
  ///
  /// In en, this message translates to:
  /// **'Employee Rosters & Time Off'**
  String get employeeRostersAndTimeOff;

  /// No description provided for @customerDatabaseCrm.
  ///
  /// In en, this message translates to:
  /// **'Customer Database & CRM'**
  String get customerDatabaseCrm;

  /// No description provided for @customerReviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews & Ratings'**
  String get customerReviewsAndRatings;

  /// No description provided for @offersAndPromotions.
  ///
  /// In en, this message translates to:
  /// **'Offers & Promotions'**
  String get offersAndPromotions;

  /// No description provided for @financeExpensesAndProfit.
  ///
  /// In en, this message translates to:
  /// **'Finance, Expenses & Profit'**
  String get financeExpensesAndProfit;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @upcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Bookings'**
  String get upcomingBookings;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @easyBookBusiness.
  ///
  /// In en, this message translates to:
  /// **'Easy Book Business'**
  String get easyBookBusiness;

  /// No description provided for @loadingBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading business details...'**
  String get loadingBusinessDetails;

  /// No description provided for @noBusinessProfileFound.
  ///
  /// In en, this message translates to:
  /// **'No Business Profile Found'**
  String get noBusinessProfileFound;

  /// No description provided for @completeBusinessRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete your business registration to manage bookings.'**
  String get completeBusinessRegistration;

  /// No description provided for @todaysBookings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Bookings'**
  String get todaysBookings;

  /// No description provided for @recognizedRevenue.
  ///
  /// In en, this message translates to:
  /// **'Recognized revenue'**
  String get recognizedRevenue;

  /// No description provided for @todaysExpenses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Expenses'**
  String get todaysExpenses;

  /// No description provided for @todaysNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Net Profit'**
  String get todaysNetProfit;

  /// No description provided for @customersToday.
  ///
  /// In en, this message translates to:
  /// **'Customers Today'**
  String get customersToday;

  /// No description provided for @pendingBookings.
  ///
  /// In en, this message translates to:
  /// **'Pending Bookings'**
  String get pendingBookings;

  /// No description provided for @walkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get walkIn;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @noBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'No Bookings Today'**
  String get noBookingsToday;

  /// No description provided for @noBookingsTodayDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re all clear for now. New bookings will appear here.'**
  String get noBookingsTodayDescription;

  /// No description provided for @createWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Create Walk-in'**
  String get createWalkIn;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnection;

  /// No description provided for @customerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Customer Registration'**
  String get customerRegistration;

  /// No description provided for @createCustomerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Customer Account'**
  String get createCustomerAccount;

  /// No description provided for @customerRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to discover and book services with Easy Book.'**
  String get customerRegistrationSubtitle;

  /// No description provided for @chooseProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo to choose an image from your phone.'**
  String get chooseProfilePhoto;

  /// No description provided for @uploadingProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading profile photo...'**
  String get uploadingProfilePhoto;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @registerAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Register & Go to Customer Home'**
  String get registerAndContinue;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @requiredRegistrationFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter name, email, and password.'**
  String get requiredRegistrationFields;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Full name must be 60 characters or less.'**
  String get nameTooLong;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email address must be 100 characters or less.'**
  String get emailTooLong;

  /// No description provided for @phoneTooLong.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 25 characters or less.'**
  String get phoneTooLong;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be 128 characters or less.'**
  String get passwordTooLong;

  /// No description provided for @imageSelectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select the image.'**
  String get imageSelectionFailed;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please verify your email.'**
  String get registrationSuccessful;

  /// No description provided for @registrationPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Account created. The profile photo could not be uploaded; you can add it later.'**
  String get registrationPhotoFailed;

  /// No description provided for @registrationAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check your details.'**
  String get registrationAuthFailed;

  /// No description provided for @registrationDatabaseFailed.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred during registration.'**
  String get registrationDatabaseFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @customerProfile.
  ///
  /// In en, this message translates to:
  /// **'Customer Profile'**
  String get customerProfile;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutQuestion;

  /// No description provided for @savedFavorites.
  ///
  /// In en, this message translates to:
  /// **'Saved Favorites'**
  String get savedFavorites;

  /// No description provided for @businessLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this business'**
  String get businessLoadFailed;

  /// No description provided for @searchAndExplore.
  ///
  /// In en, this message translates to:
  /// **'Search & Explore'**
  String get searchAndExplore;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @noCustomerBookings.
  ///
  /// In en, this message translates to:
  /// **'You have not scheduled any appointments yet.'**
  String get noCustomerBookings;

  /// No description provided for @bookingLoadFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings: {error}'**
  String bookingLoadFailedWithError(String error);

  /// No description provided for @specialistName.
  ///
  /// In en, this message translates to:
  /// **'Specialist: {name}'**
  String specialistName(String name);

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @businessUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Business no longer available'**
  String get businessUnavailable;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @favoritesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites. Please try again.'**
  String get favoritesUpdateFailed;

  /// No description provided for @signInToSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites'**
  String get signInToSaveFavorites;

  /// No description provided for @favoritesSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Your favorite salons and businesses will stay synced with your account.'**
  String get favoritesSyncDescription;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @saveFavoriteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a business to save it here.'**
  String get saveFavoriteHint;

  /// No description provided for @exploreBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Explore Businesses'**
  String get exploreBusinesses;

  /// No description provided for @favoritesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load favorites'**
  String get favoritesLoadFailed;

  /// No description provided for @superAdminCenter.
  ///
  /// In en, this message translates to:
  /// **'Super Admin Center'**
  String get superAdminCenter;

  /// No description provided for @platformRevenueMtd.
  ///
  /// In en, this message translates to:
  /// **'Platform Revenue MTD'**
  String get platformRevenueMtd;

  /// No description provided for @adminManagementControl.
  ///
  /// In en, this message translates to:
  /// **'Admin Management Control'**
  String get adminManagementControl;

  /// No description provided for @userAccountManagement.
  ///
  /// In en, this message translates to:
  /// **'User & Account Management'**
  String get userAccountManagement;

  /// No description provided for @salonVerificationApprovals.
  ///
  /// In en, this message translates to:
  /// **'Salon Verification & Approvals ({count})'**
  String salonVerificationApprovals(int count);

  /// No description provided for @payoutQueuesCommissions.
  ///
  /// In en, this message translates to:
  /// **'Payout Queues & Commissions'**
  String get payoutQueuesCommissions;

  /// No description provided for @platformTrafficAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Platform Traffic & Usage Analytics'**
  String get platformTrafficAnalytics;

  /// No description provided for @systemAuditLogsReports.
  ///
  /// In en, this message translates to:
  /// **'System Audit Logs & Reports'**
  String get systemAuditLogsReports;

  /// No description provided for @usersAccountsManagement.
  ///
  /// In en, this message translates to:
  /// **'Users & Accounts Management'**
  String get usersAccountsManagement;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @businessPartner.
  ///
  /// In en, this message translates to:
  /// **'Business Partner'**
  String get businessPartner;

  /// No description provided for @pendingSalonApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Salon Approvals'**
  String get pendingSalonApprovals;

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name} • {location}'**
  String ownerLabel(String name, String location);

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approvePartner.
  ///
  /// In en, this message translates to:
  /// **'Approve Partner'**
  String get approvePartner;

  /// No description provided for @pendingPayout.
  ///
  /// In en, this message translates to:
  /// **'Pending Payout: {amount}'**
  String pendingPayout(String amount);

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @monthlyActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Monthly Active Users (MAU)'**
  String get monthlyActiveUsers;

  /// No description provided for @usersGrowth.
  ///
  /// In en, this message translates to:
  /// **'{count} Users ({growth} growth)'**
  String usersGrowth(String count, String growth);

  /// No description provided for @systemAuditReports.
  ///
  /// In en, this message translates to:
  /// **'System Audit Reports'**
  String get systemAuditReports;

  /// No description provided for @securityDatabaseAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Security & Database Audit Log'**
  String get securityDatabaseAuditLog;

  /// No description provided for @systemOperatingNormally.
  ///
  /// In en, this message translates to:
  /// **'System operating normally. 0 breaches.'**
  String get systemOperatingNormally;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @bookingDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Booking details are unavailable.'**
  String get bookingDetailsUnavailable;

  /// No description provided for @backToMyBookings.
  ///
  /// In en, this message translates to:
  /// **'Back to My Bookings'**
  String get backToMyBookings;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Booking Ref: {reference}'**
  String bookingReference(String reference);

  /// No description provided for @showReferenceAtCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Show this booking reference at check-in'**
  String get showReferenceAtCheckIn;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @specialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get specialist;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @bookingIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unable to find booking ID to cancel.'**
  String get bookingIdNotFound;

  /// No description provided for @bookingCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully.'**
  String get bookingCancelledSuccessfully;

  /// No description provided for @bookingCancellationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel booking: {error}'**
  String bookingCancellationFailed(String error);

  /// No description provided for @confirmCancellationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get confirmCancellationQuestion;

  /// No description provided for @cancellationDescription.
  ///
  /// In en, this message translates to:
  /// **'The appointment will be cancelled and the time slot will become available again.'**
  String get cancellationDescription;

  /// No description provided for @confirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellation;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile: {error}'**
  String profileLoadFailed(String error);

  /// No description provided for @signInToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your profile.'**
  String get signInToViewProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @favoriteSalons.
  ///
  /// In en, this message translates to:
  /// **'Favorite Salons'**
  String get favoriteSalons;

  /// No description provided for @salonChatSupport.
  ///
  /// In en, this message translates to:
  /// **'Salon Chat Support'**
  String get salonChatSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @easyBookUser.
  ///
  /// In en, this message translates to:
  /// **'Easy Book User'**
  String get easyBookUser;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @guestAfterLogout.
  ///
  /// In en, this message translates to:
  /// **'You can continue browsing as a guest after logout.'**
  String get guestAfterLogout;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// No description provided for @searchBusinessesHint.
  ///
  /// In en, this message translates to:
  /// **'Search salons, spas or locations'**
  String get searchBusinessesHint;

  /// No description provided for @noBusinessesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No businesses available yet'**
  String get noBusinessesAvailable;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noSearchResults(String query);

  /// No description provided for @searchAgainHint.
  ///
  /// In en, this message translates to:
  /// **'Try another search or check again later.'**
  String get searchAgainHint;

  /// No description provided for @searchResultsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load search results'**
  String get searchResultsLoadFailed;

  /// No description provided for @selectServiceStep.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Select Service'**
  String get selectServiceStep;

  /// No description provided for @selectServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service to continue.'**
  String get selectServiceRequired;

  /// No description provided for @invalidSelectedService.
  ///
  /// In en, this message translates to:
  /// **'The selected service is not available.'**
  String get invalidSelectedService;

  /// No description provided for @servicesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load services: {error}'**
  String servicesLoadError(String error);

  /// No description provided for @noSalonServices.
  ///
  /// In en, this message translates to:
  /// **'No services are available at this salon.'**
  String get noSalonServices;

  /// No description provided for @nextSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Next: Select Date'**
  String get nextSelectDate;

  /// No description provided for @selectSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Select Specialist'**
  String get selectSpecialist;

  /// No description provided for @chooseSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialist'**
  String get chooseSpecialist;

  /// No description provided for @chooseSpecialistDescription.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred specialist or choose anyone available.'**
  String get chooseSpecialistDescription;

  /// No description provided for @anyAvailableSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Any Available Specialist'**
  String get anyAvailableSpecialist;

  /// No description provided for @specialistSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialist or select Any Available Specialist.'**
  String get specialistSelectionRequired;

  /// No description provided for @specialistsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load specialists: {error}'**
  String specialistsLoadError(String error);

  /// No description provided for @continueDateTime.
  ///
  /// In en, this message translates to:
  /// **'Continue: Select Date & Time'**
  String get continueDateTime;

  /// No description provided for @selectAppointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Select Appointment Date'**
  String get selectAppointmentDate;

  /// No description provided for @nextSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Next: Select Time'**
  String get nextSelectTime;

  /// No description provided for @selectAppointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Select Appointment Time'**
  String get selectAppointmentTime;

  /// No description provided for @timeSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Select an available time to continue.'**
  String get timeSelectionRequired;

  /// No description provided for @salonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Salon not found.'**
  String get salonNotFound;

  /// No description provided for @staffLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff: {error}'**
  String staffLoadError(String error);

  /// No description provided for @slotsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load available times: {error}'**
  String slotsLoadError(String error);

  /// No description provided for @reviewBookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Review Booking Summary'**
  String get reviewBookingSummary;

  /// No description provided for @incompleteBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking details are incomplete. Please select the service and specialist again.'**
  String get incompleteBookingDetails;

  /// No description provided for @easyBookCustomer.
  ///
  /// In en, this message translates to:
  /// **'Easy Book Customer'**
  String get easyBookCustomer;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @salon.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get salon;

  /// No description provided for @defaultSalonAddress.
  ///
  /// In en, this message translates to:
  /// **'Dubai, United Arab Emirates'**
  String get defaultSalonAddress;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get totalDuration;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesCount(int count);

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment details'**
  String get appointmentDetails;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @payAtVenue.
  ///
  /// In en, this message translates to:
  /// **'Pay at venue'**
  String get payAtVenue;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @bookingTimeRechecked.
  ///
  /// In en, this message translates to:
  /// **'The selected time will be checked again when you confirm the booking.'**
  String get bookingTimeRechecked;

  /// No description provided for @bookingCreated.
  ///
  /// In en, this message translates to:
  /// **'Booking created!'**
  String get bookingCreated;

  /// No description provided for @appointmentCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your appointment was created successfully.'**
  String get appointmentCreatedSuccessfully;

  /// No description provided for @bookingAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Your request at {businessName} is now awaiting confirmation.'**
  String bookingAwaitingConfirmation(String businessName);

  /// No description provided for @bookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Booking number'**
  String get bookingNumber;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointment;

  /// No description provided for @viewMyBookings.
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get viewMyBookings;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @financeAndProfit.
  ///
  /// In en, this message translates to:
  /// **'Finance & Profit'**
  String get financeAndProfit;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @manageExpenses.
  ///
  /// In en, this message translates to:
  /// **'Manage Expenses'**
  String get manageExpenses;

  /// No description provided for @expenseCadences.
  ///
  /// In en, this message translates to:
  /// **'Daily, monthly, annual and emergency expenses'**
  String get expenseCadences;

  /// No description provided for @financeRecognitionNote.
  ///
  /// In en, this message translates to:
  /// **'Revenue is recognized from completed bookings only. Expenses are actual recorded costs; classifications do not automatically repeat amounts.'**
  String get financeRecognitionNote;

  /// No description provided for @reportingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Reporting period'**
  String get reportingPeriod;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @completedBookings.
  ///
  /// In en, this message translates to:
  /// **'Completed bookings'**
  String get completedBookings;

  /// No description provided for @averagePerBooking.
  ///
  /// In en, this message translates to:
  /// **'Average / booking'**
  String get averagePerBooking;

  /// No description provided for @expenseFrequency.
  ///
  /// In en, this message translates to:
  /// **'Expense frequency'**
  String get expenseFrequency;

  /// No description provided for @expenseFrequencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Actual daily, monthly, annual and emergency costs'**
  String get expenseFrequencySubtitle;

  /// No description provided for @costStructure.
  ///
  /// In en, this message translates to:
  /// **'Cost structure'**
  String get costStructure;

  /// No description provided for @costStructureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses grouped by business cost area'**
  String get costStructureSubtitle;

  /// No description provided for @revenueByService.
  ///
  /// In en, this message translates to:
  /// **'Revenue by service'**
  String get revenueByService;

  /// No description provided for @revenueByServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed-booking revenue by service'**
  String get revenueByServiceSubtitle;

  /// No description provided for @detailedExpenseCategories.
  ///
  /// In en, this message translates to:
  /// **'Detailed expense categories'**
  String get detailedExpenseCategories;

  /// No description provided for @detailedExpenseCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Actual expense categories recorded by the owner'**
  String get detailedExpenseCategoriesSubtitle;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get netProfit;

  /// No description provided for @marginPercent.
  ///
  /// In en, this message translates to:
  /// **'Margin {percent}%'**
  String marginPercent(String percent);

  /// No description provided for @expenseShareWithDescription.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of expenses • {description}'**
  String expenseShareWithDescription(String percent, String description);

  /// No description provided for @expenseShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of expenses'**
  String expenseShare(String percent);

  /// No description provided for @revenueShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of revenue'**
  String revenueShare(String percent);

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses were recorded in this period.'**
  String get noExpensesInPeriod;

  /// No description provided for @noCompletedBookingRevenue.
  ///
  /// In en, this message translates to:
  /// **'There is no revenue from completed bookings in this period.'**
  String get noCompletedBookingRevenue;

  /// No description provided for @financeDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Finance data is unavailable'**
  String get financeDataUnavailable;

  /// No description provided for @businessExpenses.
  ///
  /// In en, this message translates to:
  /// **'Business Expenses'**
  String get businessExpenses;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet. Use Add Expense to record an actual cost.'**
  String get noExpensesYet;

  /// No description provided for @expenseClassification.
  ///
  /// In en, this message translates to:
  /// **'Expense Classification'**
  String get expenseClassification;

  /// No description provided for @expenseClassificationHelp.
  ///
  /// In en, this message translates to:
  /// **'Each record is an actual cost. Its type describes the expense cadence and does not automatically repeat the amount.'**
  String get expenseClassificationHelp;

  /// No description provided for @totalActiveExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total active expenses'**
  String get totalActiveExpenses;

  /// No description provided for @noExpensesOfType.
  ///
  /// In en, this message translates to:
  /// **'No {type} expenses recorded.'**
  String noExpensesOfType(String type);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveExpenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Archive expense?'**
  String get archiveExpenseQuestion;

  /// No description provided for @archiveExpenseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive “{description}”? It will be removed from active expense reports and retained as an archived financial record.'**
  String archiveExpenseConfirmation(String description);

  /// No description provided for @expenseArchived.
  ///
  /// In en, this message translates to:
  /// **'Expense archived.'**
  String get expenseArchived;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @expenseEditorHelp.
  ///
  /// In en, this message translates to:
  /// **'Record the actual amount, then classify it as daily, monthly, annual or emergency. Classification does not create recurring amounts.'**
  String get expenseEditorHelp;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense type'**
  String get expenseType;

  /// No description provided for @expenseTypeHelper.
  ///
  /// In en, this message translates to:
  /// **'Daily / Monthly / Annual / Emergency'**
  String get expenseTypeHelper;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get descriptionRequired;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @validPositiveAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero.'**
  String get validPositiveAmountRequired;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expenseDate;

  /// No description provided for @supplierOptional.
  ///
  /// In en, this message translates to:
  /// **'Supplier / payee (optional)'**
  String get supplierOptional;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @cheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get cheque;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @dailyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Daily Expenses'**
  String get dailyExpenses;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// No description provided for @annualExpenses.
  ///
  /// In en, this message translates to:
  /// **'Annual Expenses'**
  String get annualExpenses;

  /// No description provided for @emergencyOneTime.
  ///
  /// In en, this message translates to:
  /// **'Emergency / One-time'**
  String get emergencyOneTime;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @dailyExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Day-to-day operating costs actually paid'**
  String get dailyExpenseDescription;

  /// No description provided for @monthlyExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Regular monthly costs such as rent or salaries'**
  String get monthlyExpenseDescription;

  /// No description provided for @annualExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Annual costs such as licences or insurance'**
  String get annualExpenseDescription;

  /// No description provided for @emergencyExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Unexpected or one-off costs such as urgent repairs'**
  String get emergencyExpenseDescription;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @staffSalaries.
  ///
  /// In en, this message translates to:
  /// **'Staff salaries'**
  String get staffSalaries;

  /// No description provided for @staffCommissions.
  ///
  /// In en, this message translates to:
  /// **'Staff commissions'**
  String get staffCommissions;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @internetAndPhone.
  ///
  /// In en, this message translates to:
  /// **'Internet and phone'**
  String get internetAndPhone;

  /// No description provided for @productsAndSupplies.
  ///
  /// In en, this message translates to:
  /// **'Products and supplies'**
  String get productsAndSupplies;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @cleaningAndLaundry.
  ///
  /// In en, this message translates to:
  /// **'Cleaning and laundry'**
  String get cleaningAndLaundry;

  /// No description provided for @marketingAndAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Marketing and advertising'**
  String get marketingAndAdvertising;

  /// No description provided for @licensingAndGovernmentFees.
  ///
  /// In en, this message translates to:
  /// **'Licensing and government fees'**
  String get licensingAndGovernmentFees;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @paymentAndBankFees.
  ///
  /// In en, this message translates to:
  /// **'Payment and bank fees'**
  String get paymentAndBankFees;

  /// No description provided for @easyBookFees.
  ///
  /// In en, this message translates to:
  /// **'Easy Book fees'**
  String get easyBookFees;

  /// No description provided for @taxesAndVat.
  ///
  /// In en, this message translates to:
  /// **'Taxes / VAT'**
  String get taxesAndVat;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @staffCosts.
  ///
  /// In en, this message translates to:
  /// **'Staff costs'**
  String get staffCosts;

  /// No description provided for @occupancyAndUtilities.
  ///
  /// In en, this message translates to:
  /// **'Occupancy and utilities'**
  String get occupancyAndUtilities;

  /// No description provided for @operatingCosts.
  ///
  /// In en, this message translates to:
  /// **'Operating costs'**
  String get operatingCosts;

  /// No description provided for @feesInsuranceAndTaxes.
  ///
  /// In en, this message translates to:
  /// **'Fees, insurance and taxes'**
  String get feesInsuranceAndTaxes;

  /// No description provided for @otherCosts.
  ///
  /// In en, this message translates to:
  /// **'Other costs'**
  String get otherCosts;

  /// No description provided for @servicesMenuManagement.
  ///
  /// In en, this message translates to:
  /// **'Services Menu Management'**
  String get servicesMenuManagement;

  /// No description provided for @noServicesAdded.
  ///
  /// In en, this message translates to:
  /// **'No services added'**
  String get noServicesAdded;

  /// No description provided for @addFirstServiceHelp.
  ///
  /// In en, this message translates to:
  /// **'Add your first service so customers can book it.'**
  String get addFirstServiceHelp;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @servicesFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve the business services list.'**
  String get servicesFetchFailed;

  /// No description provided for @deleteServiceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete service?'**
  String get deleteServiceQuestion;

  /// No description provided for @deleteServiceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete “{serviceName}”? If it has active bookings, you can disable it instead.'**
  String deleteServiceConfirmation(String serviceName);

  /// No description provided for @serviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted'**
  String get serviceDeleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @hairServices.
  ///
  /// In en, this message translates to:
  /// **'Hair Services'**
  String get hairServices;

  /// No description provided for @hairSalon.
  ///
  /// In en, this message translates to:
  /// **'Hair Salon'**
  String get hairSalon;

  /// No description provided for @nails.
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get nails;

  /// No description provided for @massage.
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get massage;

  /// No description provided for @spa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get spa;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @addNewService.
  ///
  /// In en, this message translates to:
  /// **'Add New Service'**
  String get addNewService;

  /// No description provided for @serviceNameRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Name *'**
  String get serviceNameRequiredLabel;

  /// No description provided for @enterServiceName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the service name'**
  String get enterServiceName;

  /// No description provided for @serviceCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category (e.g. Hair, Beard, Facial, Massage)'**
  String get serviceCategoryHint;

  /// No description provided for @priceAedRequired.
  ///
  /// In en, this message translates to:
  /// **'Price (AED) *'**
  String get priceAedRequired;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @discountPrice.
  ///
  /// In en, this message translates to:
  /// **'Discount Price'**
  String get discountPrice;

  /// No description provided for @serviceDurationRequired.
  ///
  /// In en, this message translates to:
  /// **'Service Duration *'**
  String get serviceDurationRequired;

  /// No description provided for @serviceImage.
  ///
  /// In en, this message translates to:
  /// **'Service Image'**
  String get serviceImage;

  /// No description provided for @uploadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploadingPercent(int percent);

  /// No description provided for @availableForBooking.
  ///
  /// In en, this message translates to:
  /// **'Available for Booking'**
  String get availableForBooking;

  /// No description provided for @serviceAvailabilityHelp.
  ///
  /// In en, this message translates to:
  /// **'Disable to temporarily stop accepting new bookings for this service.'**
  String get serviceAvailabilityHelp;

  /// No description provided for @updateService.
  ///
  /// In en, this message translates to:
  /// **'Update Service'**
  String get updateService;

  /// No description provided for @saveAndPublishService.
  ///
  /// In en, this message translates to:
  /// **'Save & Publish Service'**
  String get saveAndPublishService;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed: {error}'**
  String imageUploadFailed(String error);

  /// No description provided for @imageDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete image: {error}'**
  String imageDeleteFailed(String error);

  /// No description provided for @serviceUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully!'**
  String get serviceUpdatedSuccessfully;

  /// No description provided for @serviceCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'New service created!'**
  String get serviceCreatedSuccessfully;

  /// No description provided for @serviceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save service: {error}'**
  String serviceSaveFailed(String error);

  /// No description provided for @teamAndEmployees.
  ///
  /// In en, this message translates to:
  /// **'Team & Employees'**
  String get teamAndEmployees;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees'**
  String get noEmployees;

  /// No description provided for @addFirstEmployeeHelp.
  ///
  /// In en, this message translates to:
  /// **'Add your first employee to start accepting staff-based bookings.'**
  String get addFirstEmployeeHelp;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'• {count} years of experience'**
  String yearsExperience(int count);

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit Employee'**
  String get editEmployee;

  /// No description provided for @workingHoursAndSchedule.
  ///
  /// In en, this message translates to:
  /// **'Working Hours & Schedule'**
  String get workingHoursAndSchedule;

  /// No description provided for @employeesFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve team members.'**
  String get employeesFetchFailed;

  /// No description provided for @addNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add New Employee'**
  String get addNewEmployee;

  /// No description provided for @employeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Employee Profile'**
  String get employeeProfile;

  /// No description provided for @employeeFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Employee Full Name *'**
  String get employeeFullNameRequired;

  /// No description provided for @enterEmployeeName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the employee name'**
  String get enterEmployeeName;

  /// No description provided for @jobTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Job Title / Specialty *'**
  String get jobTitleRequired;

  /// No description provided for @enterJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter the job title'**
  String get enterJobTitle;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// No description provided for @professionalBio.
  ///
  /// In en, this message translates to:
  /// **'Professional Bio'**
  String get professionalBio;

  /// No description provided for @activeAndBookable.
  ///
  /// In en, this message translates to:
  /// **'Active & Bookable'**
  String get activeAndBookable;

  /// No description provided for @inactiveEmployeeHelp.
  ///
  /// In en, this message translates to:
  /// **'Inactive employees will not be offered for new bookings.'**
  String get inactiveEmployeeHelp;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @employeePhotosHelp.
  ///
  /// In en, this message translates to:
  /// **'Use one clear profile photo and up to 8 portfolio photos.'**
  String get employeePhotosHelp;

  /// No description provided for @mainProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Main Profile Photo'**
  String get mainProfilePhoto;

  /// No description provided for @portfolioPhotos.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Photos'**
  String get portfolioPhotos;

  /// No description provided for @noPortfolioPhotos.
  ///
  /// In en, this message translates to:
  /// **'No portfolio photos yet.'**
  String get noPortfolioPhotos;

  /// No description provided for @workAndBreakHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours & Breaks'**
  String get workAndBreakHours;

  /// No description provided for @differentScheduleEachDay.
  ///
  /// In en, this message translates to:
  /// **'Set a different schedule for each day.'**
  String get differentScheduleEachDay;

  /// No description provided for @updateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Update Employee'**
  String get updateEmployee;

  /// No description provided for @addEmployeeToTeam.
  ///
  /// In en, this message translates to:
  /// **'Add Employee to Team'**
  String get addEmployeeToTeam;

  /// No description provided for @portfolioUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Portfolio photo upload failed: {error}'**
  String portfolioUploadFailed(String error);

  /// No description provided for @employeeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employee updated successfully.'**
  String get employeeUpdatedSuccessfully;

  /// No description provided for @employeeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Employee added successfully.'**
  String get employeeAddedSuccessfully;

  /// No description provided for @employeeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save employee: {error}'**
  String employeeSaveFailed(String error);

  /// No description provided for @employeeWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Employee Working Hours'**
  String get employeeWorkingHours;

  /// No description provided for @timeOffAndAbsence.
  ///
  /// In en, this message translates to:
  /// **'Time off and absence'**
  String get timeOffAndAbsence;

  /// No description provided for @addEmployeeBeforeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add an employee before configuring working hours.'**
  String get addEmployeeBeforeSchedule;

  /// No description provided for @staffMember.
  ///
  /// In en, this message translates to:
  /// **'Staff member'**
  String get staffMember;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @employeeScheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'These hours directly control when customers can book this employee.'**
  String get employeeScheduleHelp;

  /// No description provided for @saveEmployeeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save Employee Schedule'**
  String get saveEmployeeSchedule;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;

  /// No description provided for @dayOff.
  ///
  /// In en, this message translates to:
  /// **'Day Off'**
  String get dayOff;

  /// No description provided for @shiftStarts.
  ///
  /// In en, this message translates to:
  /// **'Shift starts'**
  String get shiftStarts;

  /// No description provided for @shiftEnds.
  ///
  /// In en, this message translates to:
  /// **'Shift ends'**
  String get shiftEnds;

  /// No description provided for @breakStarts.
  ///
  /// In en, this message translates to:
  /// **'Break starts'**
  String get breakStarts;

  /// No description provided for @breakEnds.
  ///
  /// In en, this message translates to:
  /// **'Break ends'**
  String get breakEnds;

  /// No description provided for @employeeScheduleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Schedule updated for {name}.'**
  String employeeScheduleUpdated(String name);

  /// No description provided for @employeeScheduleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save employee schedule: {error}'**
  String employeeScheduleSaveFailed(String error);

  /// No description provided for @businessWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Business Working Hours'**
  String get businessWorkingHours;

  /// No description provided for @operatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operatingHours;

  /// No description provided for @businessHoursHelp.
  ///
  /// In en, this message translates to:
  /// **'Set opening and closing times precisely. Customer booking availability depends on these hours.'**
  String get businessHoursHelp;

  /// No description provided for @saveWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Save Working Hours'**
  String get saveWorkingHours;

  /// No description provided for @workingHoursLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load working hours: {error}'**
  String workingHoursLoadFailed(String error);

  /// No description provided for @opens.
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get opens;

  /// No description provided for @closes.
  ///
  /// In en, this message translates to:
  /// **'Closes'**
  String get closes;

  /// No description provided for @selectOpeningTime.
  ///
  /// In en, this message translates to:
  /// **'Select opening time'**
  String get selectOpeningTime;

  /// No description provided for @selectClosingTime.
  ///
  /// In en, this message translates to:
  /// **'Select closing time'**
  String get selectClosingTime;

  /// No description provided for @businessHoursUpdated.
  ///
  /// In en, this message translates to:
  /// **'Business working hours updated.'**
  String get businessHoursUpdated;

  /// No description provided for @businessHoursUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update working hours: {error}'**
  String businessHoursUpdateFailed(String error);

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @dubaiUaeLocation.
  ///
  /// In en, this message translates to:
  /// **'Dubai, UAE 📍'**
  String get dubaiUaeLocation;

  /// No description provided for @searchSalonsAndServices.
  ///
  /// In en, this message translates to:
  /// **'Search salons and services...'**
  String get searchSalonsAndServices;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @barbers.
  ///
  /// In en, this message translates to:
  /// **'Barbers'**
  String get barbers;

  /// No description provided for @barber.
  ///
  /// In en, this message translates to:
  /// **'Barber'**
  String get barber;

  /// No description provided for @hairSalons.
  ///
  /// In en, this message translates to:
  /// **'Hair Salons'**
  String get hairSalons;

  /// No description provided for @hair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get hair;

  /// No description provided for @spaAndRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Spa & Relaxation'**
  String get spaAndRelaxation;

  /// No description provided for @nailsAndBeauty.
  ///
  /// In en, this message translates to:
  /// **'Nails & Beauty'**
  String get nailsAndBeauty;

  /// No description provided for @featuredBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Featured Businesses'**
  String get featuredBusinesses;

  /// No description provided for @noBusinessesYet.
  ///
  /// In en, this message translates to:
  /// **'No businesses are available yet'**
  String get noBusinessesYet;

  /// No description provided for @newBusinessesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'New salons and services will appear here.'**
  String get newBusinessesAppearHere;

  /// No description provided for @availableToBook.
  ///
  /// In en, this message translates to:
  /// **'Available to book'**
  String get availableToBook;

  /// No description provided for @currentlyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Currently unavailable'**
  String get currentlyUnavailable;

  /// No description provided for @businessesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load businesses'**
  String get businessesLoadFailed;

  /// No description provided for @allServiceCategories.
  ///
  /// In en, this message translates to:
  /// **'All Service Categories'**
  String get allServiceCategories;

  /// No description provided for @barberSalons.
  ///
  /// In en, this message translates to:
  /// **'Barber Shops'**
  String get barberSalons;

  /// No description provided for @spaAndMassage.
  ///
  /// In en, this message translates to:
  /// **'Spa & Massage'**
  String get spaAndMassage;

  /// No description provided for @nailAndBeautyCare.
  ///
  /// In en, this message translates to:
  /// **'Nail & Beauty Care'**
  String get nailAndBeautyCare;

  /// No description provided for @skinAndFacialClinics.
  ///
  /// In en, this message translates to:
  /// **'Skin & Facial Clinics'**
  String get skinAndFacialClinics;

  /// No description provided for @tattooAndPiercing.
  ///
  /// In en, this message translates to:
  /// **'Tattoo & Piercing'**
  String get tattooAndPiercing;

  /// No description provided for @salonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} salons'**
  String salonsCount(int count);

  /// No description provided for @centersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} centers'**
  String centersCount(int count);

  /// No description provided for @studiosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} studios'**
  String studiosCount(int count);

  /// No description provided for @clinicsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} clinics'**
  String clinicsCount(int count);

  /// No description provided for @shopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shops'**
  String shopsCount(int count);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @selectedServicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 service selected} other{{count} services selected}}'**
  String selectedServicesCount(int count);

  /// No description provided for @selectServiceOrBookNow.
  ///
  /// In en, this message translates to:
  /// **'Select a service or tap Book Now'**
  String get selectServiceOrBookNow;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get bookingSummary;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @specialists.
  ///
  /// In en, this message translates to:
  /// **'Specialists'**
  String get specialists;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @checkingAvailableSlots.
  ///
  /// In en, this message translates to:
  /// **'Checking available appointments...'**
  String get checkingAvailableSlots;

  /// No description provided for @noSlotsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No times are available on this date.'**
  String get noSlotsOnDate;

  /// No description provided for @chooseAnotherDateOrSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Choose another date or any available specialist.'**
  String get chooseAnotherDateOrSpecialist;

  /// No description provided for @morningAppointments.
  ///
  /// In en, this message translates to:
  /// **'Morning appointments'**
  String get morningAppointments;

  /// No description provided for @afternoonAppointments.
  ///
  /// In en, this message translates to:
  /// **'Afternoon appointments'**
  String get afternoonAppointments;

  /// No description provided for @eveningAppointments.
  ///
  /// In en, this message translates to:
  /// **'Evening appointments'**
  String get eveningAppointments;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @callingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}: {phone}'**
  String callingBusiness(String name, String phone);

  /// No description provided for @sharingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Sharing {name}...'**
  String sharingBusiness(String name);

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @driving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get driving;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @googleMapsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps: {error}'**
  String googleMapsOpenFailed(String error);

  /// No description provided for @selectedServices.
  ///
  /// In en, this message translates to:
  /// **'Selected services'**
  String get selectedServices;

  /// No description provided for @totalDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total duration: {count} min'**
  String totalDurationMinutes(int count);

  /// No description provided for @subtotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: {amount}'**
  String subtotalAmount(String amount);

  /// No description provided for @noServicesAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'No services are currently available.'**
  String get noServicesAvailableNow;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @anySpecialistAvailabilityHint.
  ///
  /// In en, this message translates to:
  /// **'The widest availability across all specialists'**
  String get anySpecialistAvailabilityHint;

  /// No description provided for @selectedWithCheck.
  ///
  /// In en, this message translates to:
  /// **'Selected ✓'**
  String get selectedWithCheck;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo gallery'**
  String get photoGallery;

  /// No description provided for @noReviewsYetPrompt.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.\nBe the first to review after your appointment.'**
  String get noReviewsYetPrompt;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer reviews'**
  String get customerReviews;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @salonLiveSupport.
  ///
  /// In en, this message translates to:
  /// **'Salon live support'**
  String get salonLiveSupport;

  /// No description provided for @chatSampleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Hi! Can I request Marcus for my 10 AM appointment?'**
  String get chatSampleCustomer;

  /// No description provided for @chatSampleSalon.
  ///
  /// In en, this message translates to:
  /// **'Hi Ahmed! Yes, Marcus has been assigned to your booking.'**
  String get chatSampleSalon;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessageHint;

  /// No description provided for @bookingConfirmedNotification.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get bookingConfirmedNotification;

  /// No description provided for @haircutTomorrowNotification.
  ///
  /// In en, this message translates to:
  /// **'Your haircut appointment is tomorrow at 10 AM.'**
  String get haircutTomorrowNotification;

  /// No description provided for @twoHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Two hours ago'**
  String get twoHoursAgo;

  /// No description provided for @loyaltyPointsNotification.
  ///
  /// In en, this message translates to:
  /// **'You earned 150 loyalty points'**
  String get loyaltyPointsNotification;

  /// No description provided for @reviewThanksNotification.
  ///
  /// In en, this message translates to:
  /// **'Thank you for reviewing the service.'**
  String get reviewThanksNotification;

  /// No description provided for @oneDayAgo.
  ///
  /// In en, this message translates to:
  /// **'One day ago'**
  String get oneDayAgo;

  /// No description provided for @sampleReviewOne.
  ///
  /// In en, this message translates to:
  /// **'Excellent haircut and wonderful hot-towel service!'**
  String get sampleReviewOne;

  /// No description provided for @sampleReviewTwo.
  ///
  /// In en, this message translates to:
  /// **'Very relaxing atmosphere and friendly staff.'**
  String get sampleReviewTwo;

  /// No description provided for @twoDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Two days ago'**
  String get twoDaysAgo;

  /// No description provided for @oneWeekAgo.
  ///
  /// In en, this message translates to:
  /// **'One week ago'**
  String get oneWeekAgo;

  /// No description provided for @professionalBarberStylist.
  ///
  /// In en, this message translates to:
  /// **'Professional barber and hair stylist'**
  String get professionalBarberStylist;

  /// No description provided for @hairColorSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Hair color specialist'**
  String get hairColorSpecialist;

  /// No description provided for @massageSpaTherapist.
  ///
  /// In en, this message translates to:
  /// **'Massage and spa therapist'**
  String get massageSpaTherapist;

  /// No description provided for @staffAndSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Staff and specialists'**
  String get staffAndSpecialists;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @paymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The payment gateway will be enabled in phase three.'**
  String get paymentComingSoon;

  /// No description provided for @checkoutAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Checkout and payment'**
  String get checkoutAndPayment;

  /// No description provided for @creditDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / debit card'**
  String get creditDebitCard;

  /// No description provided for @easyBookWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Easy Book Wallet ({balance})'**
  String easyBookWalletBalance(String balance);

  /// No description provided for @payNowAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} now'**
  String payNowAmount(String amount);

  /// No description provided for @salonLocationDirections.
  ///
  /// In en, this message translates to:
  /// **'Salon location and directions'**
  String get salonLocationDirections;

  /// No description provided for @salonMapLocation.
  ///
  /// In en, this message translates to:
  /// **'Salon location on the map'**
  String get salonMapLocation;

  /// No description provided for @startDirections.
  ///
  /// In en, this message translates to:
  /// **'Start directions'**
  String get startDirections;

  /// No description provided for @salonsAndSpas.
  ///
  /// In en, this message translates to:
  /// **'Salons and spas'**
  String get salonsAndSpas;

  /// No description provided for @businessesLoadFailedSentence.
  ///
  /// In en, this message translates to:
  /// **'Could not load businesses.'**
  String get businessesLoadFailedSentence;

  /// No description provided for @noBusinessesAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No businesses are available yet.'**
  String get noBusinessesAvailableYet;

  /// No description provided for @serviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Service information'**
  String get serviceInformation;

  /// No description provided for @serviceBenefits.
  ///
  /// In en, this message translates to:
  /// **'Service benefits:'**
  String get serviceBenefits;

  /// No description provided for @continueToBooking.
  ///
  /// In en, this message translates to:
  /// **'Continue to booking'**
  String get continueToBooking;

  /// No description provided for @signInToCompleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to complete your booking.'**
  String get signInToCompleteBooking;

  /// No description provided for @verifyEmailToBook.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before continuing with the booking.'**
  String get verifyEmailToBook;

  /// No description provided for @completeBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Please select all booking details before confirming.'**
  String get completeBookingDetails;

  /// No description provided for @dearCustomer.
  ///
  /// In en, this message translates to:
  /// **'Dear customer'**
  String get dearCustomer;

  /// No description provided for @confirmBookingStep.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Confirm booking'**
  String get confirmBookingStep;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @dateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @chooseDifferentDateOrTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different date or time.'**
  String get chooseDifferentDateOrTime;

  /// No description provided for @rescheduledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your appointment was rescheduled successfully.'**
  String get rescheduledSuccessfully;

  /// No description provided for @rescheduleBooking.
  ///
  /// In en, this message translates to:
  /// **'Reschedule booking'**
  String get rescheduleBooking;

  /// No description provided for @bookingDetailsNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Booking details were not provided.'**
  String get bookingDetailsNotProvided;

  /// No description provided for @serviceAndSpecialist.
  ///
  /// In en, this message translates to:
  /// **'{service} • Specialist: {specialist}'**
  String serviceAndSpecialist(String service, String specialist);

  /// No description provided for @currentAppointment.
  ///
  /// In en, this message translates to:
  /// **'Current appointment: {dateTime}'**
  String currentAppointment(String dateTime);

  /// No description provided for @selectNewDate.
  ///
  /// In en, this message translates to:
  /// **'Select a new date'**
  String get selectNewDate;

  /// No description provided for @selectNewTime.
  ///
  /// In en, this message translates to:
  /// **'Select a new time'**
  String get selectNewTime;

  /// No description provided for @slotsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load times: {error}'**
  String slotsLoadFailed(String error);

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @confirmReschedule.
  ///
  /// In en, this message translates to:
  /// **'Confirm reschedule'**
  String get confirmReschedule;

  /// No description provided for @inactiveSalonNotice.
  ///
  /// In en, this message translates to:
  /// **'This salon is currently inactive or is not accepting online bookings.'**
  String get inactiveSalonNotice;

  /// No description provided for @distanceKilometers.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distanceKilometers(String distance);

  /// No description provided for @staffInformationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Staff information is not available yet.'**
  String get staffInformationUnavailable;

  /// No description provided for @salonDataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this salon\'s data.'**
  String get salonDataLoadFailed;

  /// No description provided for @requestedBusinessUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The requested business profile is no longer available.'**
  String get requestedBusinessUnavailable;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @imageSelectionFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not select image: {error}'**
  String imageSelectionFailedWithError(String error);

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String profileUpdateFailed(String error);

  /// No description provided for @profileLoadFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile: {error}'**
  String profileLoadFailedWithError(String error);

  /// No description provided for @signInAgainToEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to edit your profile.'**
  String get signInAgainToEditProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @emailChangeDisabledHelp.
  ///
  /// In en, this message translates to:
  /// **'Changing email requires separate verification, so it is disabled here.'**
  String get emailChangeDisabledHelp;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @reviewsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews'**
  String get reviewsLoadFailed;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @reviewsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Customer reviews will appear here after they are submitted.'**
  String get reviewsAppearHere;

  /// No description provided for @customerFeedback.
  ///
  /// In en, this message translates to:
  /// **'Customer feedback'**
  String get customerFeedback;

  /// No description provided for @reviewTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewTotal(int count);

  /// No description provided for @repliedReviewsProgress.
  ///
  /// In en, this message translates to:
  /// **'Replied to {replied} of {total} reviews'**
  String repliedReviewsProgress(int replied, int total);

  /// No description provided for @businessReply.
  ///
  /// In en, this message translates to:
  /// **'Business reply'**
  String get businessReply;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @editReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get editReply;

  /// No description provided for @replyToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String replyToCustomer(String name);

  /// No description provided for @replyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a professional reply on behalf of the business...'**
  String get replyHint;

  /// No description provided for @saveReply.
  ///
  /// In en, this message translates to:
  /// **'Save reply'**
  String get saveReply;

  /// No description provided for @replySaved.
  ///
  /// In en, this message translates to:
  /// **'Reply saved successfully.'**
  String get replySaved;

  /// No description provided for @replySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save reply: {error}'**
  String replySaveFailed(String error);

  /// No description provided for @allPhotos.
  ///
  /// In en, this message translates to:
  /// **'All photos'**
  String get allPhotos;

  /// No description provided for @interior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get interior;

  /// No description provided for @exterior.
  ///
  /// In en, this message translates to:
  /// **'Exterior'**
  String get exterior;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @beforeAndAfter.
  ///
  /// In en, this message translates to:
  /// **'Before and after'**
  String get beforeAndAfter;

  /// No description provided for @businessGallery.
  ///
  /// In en, this message translates to:
  /// **'Business photos and gallery'**
  String get businessGallery;

  /// No description provided for @uploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload photos'**
  String get uploadPhotos;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @uploadRealPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Upload real photos so customers can see the venue and work.'**
  String get uploadRealPhotosHint;

  /// No description provided for @galleryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load gallery'**
  String get galleryLoadFailed;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @uploadBusinessPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload business photos'**
  String get uploadBusinessPhotos;

  /// No description provided for @photoCategory.
  ///
  /// In en, this message translates to:
  /// **'Photo category'**
  String get photoCategory;

  /// No description provided for @photoDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo description (optional)'**
  String get photoDescriptionOptional;

  /// No description provided for @photoDescriptionBatchHelp.
  ///
  /// In en, this message translates to:
  /// **'The description will apply to the uploaded photo set.'**
  String get photoDescriptionBatchHelp;

  /// No description provided for @photoSelectionLimit.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 10 photos at a time.'**
  String get photoSelectionLimit;

  /// No description provided for @choosePhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose photos'**
  String get choosePhotos;

  /// No description provided for @choosePhotosFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose photos from your device...'**
  String get choosePhotosFromDevice;

  /// No description provided for @uploadingPhotoProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo {current} of {total} • {percent}%'**
  String uploadingPhotoProgress(int current, int total, int percent);

  /// No description provided for @photosUploaded.
  ///
  /// In en, this message translates to:
  /// **'{count} photos uploaded successfully.'**
  String photosUploaded(int count);

  /// No description provided for @photosUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photos: {error}'**
  String photosUploadFailed(String error);

  /// No description provided for @deletePhotoQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get deletePhotoQuestion;

  /// No description provided for @deletePhotoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the photo from the business gallery.'**
  String get deletePhotoConfirmation;

  /// No description provided for @photoDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete photo: {error}'**
  String photoDeleteFailed(String error);

  /// No description provided for @manageBusiness.
  ///
  /// In en, this message translates to:
  /// **'Manage business'**
  String get manageBusiness;

  /// No description provided for @saveBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Save business profile'**
  String get saveBusinessProfile;

  /// No description provided for @businessProfileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load business profile: {error}'**
  String businessProfileLoadFailed(Object error);

  /// No description provided for @onlineBookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Online booking status'**
  String get onlineBookingStatus;

  /// No description provided for @customersCanBookNow.
  ///
  /// In en, this message translates to:
  /// **'Customers can currently book your services.'**
  String get customersCanBookNow;

  /// No description provided for @onlineBookingsPaused.
  ///
  /// In en, this message translates to:
  /// **'New online bookings are temporarily paused.'**
  String get onlineBookingsPaused;

  /// No description provided for @businessMainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Business main photo'**
  String get businessMainPhoto;

  /// No description provided for @uploadCoverPhotoHelp.
  ///
  /// In en, this message translates to:
  /// **'Upload a real cover photo from your device.'**
  String get uploadCoverPhotoHelp;

  /// No description provided for @logoOrMainCover.
  ///
  /// In en, this message translates to:
  /// **'Logo / main cover photo'**
  String get logoOrMainCover;

  /// No description provided for @uploadProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploadProgressPercent(Object percent);

  /// No description provided for @manageMultipleBusinessPhotos.
  ///
  /// In en, this message translates to:
  /// **'Manage multiple business photos'**
  String get manageMultipleBusinessPhotos;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get businessDetails;

  /// No description provided for @publicBusinessInfoHelp.
  ///
  /// In en, this message translates to:
  /// **'Information customers see on your public profile.'**
  String get publicBusinessInfoHelp;

  /// No description provided for @businessNameRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Business name *'**
  String get businessNameRequiredLabel;

  /// No description provided for @enterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Enter the business name'**
  String get enterBusinessName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contactPhone;

  /// No description provided for @websiteContactLink.
  ///
  /// In en, this message translates to:
  /// **'Website / contact link'**
  String get websiteContactLink;

  /// No description provided for @businessDescription.
  ///
  /// In en, this message translates to:
  /// **'Business description'**
  String get businessDescription;

  /// No description provided for @businessLocation.
  ///
  /// In en, this message translates to:
  /// **'Business location'**
  String get businessLocation;

  /// No description provided for @locationGoogleMapsHelp.
  ///
  /// In en, this message translates to:
  /// **'Save the address and mark the entrance precisely on Google Maps.'**
  String get locationGoogleMapsHelp;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get fullAddress;

  /// No description provided for @exactLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Exact location saved'**
  String get exactLocationSaved;

  /// No description provided for @setExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Set exact location'**
  String get setExactLocation;

  /// No description provided for @editSalonLocationHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit the salon location on Google Maps.'**
  String get editSalonLocationHelp;

  /// No description provided for @placeEntrancePinHelp.
  ///
  /// In en, this message translates to:
  /// **'Open the map and place the marker precisely at the entrance.'**
  String get placeEntrancePinHelp;

  /// No description provided for @amenitiesAndFeatures.
  ///
  /// In en, this message translates to:
  /// **'Amenities and features'**
  String get amenitiesAndFeatures;

  /// No description provided for @selectAmenitiesHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the amenities available at your business.'**
  String get selectAmenitiesHelp;

  /// No description provided for @additionalManagement.
  ///
  /// In en, this message translates to:
  /// **'Additional management'**
  String get additionalManagement;

  /// No description provided for @manageCustomerSectionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Manage the sections customers interact with most.'**
  String get manageCustomerSectionsHelp;

  /// No description provided for @employeesAndHours.
  ///
  /// In en, this message translates to:
  /// **'Employees and their working hours'**
  String get employeesAndHours;

  /// No description provided for @businessPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Business photo gallery'**
  String get businessPhotoGallery;

  /// No description provided for @imageUploadFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed: {error}'**
  String imageUploadFailedWithError(Object error);

  /// No description provided for @storageImageDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete image from storage: {error}'**
  String storageImageDeleteFailed(Object error);

  /// No description provided for @businessProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Business profile updated.'**
  String get businessProfileUpdated;

  /// No description provided for @businessProfileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update business profile: {error}'**
  String businessProfileUpdateFailed(Object error);

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @valetParking.
  ///
  /// In en, this message translates to:
  /// **'Valet parking'**
  String get valetParking;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card payment'**
  String get cardPayment;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash payment'**
  String get cashPayment;

  /// No description provided for @wheelchairAccess.
  ///
  /// In en, this message translates to:
  /// **'Wheelchair access'**
  String get wheelchairAccess;

  /// No description provided for @privateRooms.
  ///
  /// In en, this message translates to:
  /// **'Private rooms'**
  String get privateRooms;

  /// No description provided for @womenOnly.
  ///
  /// In en, this message translates to:
  /// **'Women only'**
  String get womenOnly;

  /// No description provided for @coffeeAndDrinks.
  ///
  /// In en, this message translates to:
  /// **'Coffee and drinks'**
  String get coffeeAndDrinks;

  /// No description provided for @prayerSpace.
  ///
  /// In en, this message translates to:
  /// **'Prayer space'**
  String get prayerSpace;

  /// No description provided for @quickWalkInBooking.
  ///
  /// In en, this message translates to:
  /// **'Quick Walk-in Booking'**
  String get quickWalkInBooking;

  /// No description provided for @receptionWalkInEntry.
  ///
  /// In en, this message translates to:
  /// **'Reception Walk-in Entry'**
  String get receptionWalkInEntry;

  /// No description provided for @receptionWalkInDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a booking for on-site clients arriving without the customer app.'**
  String get receptionWalkInDescription;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @existingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Existing Customer'**
  String get existingCustomer;

  /// No description provided for @customerNameRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name *'**
  String get customerNameRequiredLabel;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter customer name'**
  String get enterCustomerName;

  /// No description provided for @selectServiceRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Service *'**
  String get selectServiceRequiredLabel;

  /// No description provided for @assignSpecialistRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign Specialist *'**
  String get assignSpecialistRequiredLabel;

  /// No description provided for @walkInNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Notes (Optional)'**
  String get walkInNotesOptional;

  /// No description provided for @createWalkInBooking.
  ///
  /// In en, this message translates to:
  /// **'Create Walk-in Booking'**
  String get createWalkInBooking;

  /// No description provided for @selectServiceAndSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Please select both a service and a specialist.'**
  String get selectServiceAndSpecialist;

  /// No description provided for @walkInCreated.
  ///
  /// In en, this message translates to:
  /// **'Walk-in booking created successfully!'**
  String get walkInCreated;

  /// No description provided for @walkInCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create walk-in: {error}'**
  String walkInCreateFailed(Object error);

  /// No description provided for @offersPromotionalDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Offers & Promotional Discounts'**
  String get offersPromotionalDiscounts;

  /// No description provided for @createOffer.
  ///
  /// In en, this message translates to:
  /// **'Create Offer'**
  String get createOffer;

  /// No description provided for @marketingPromotions.
  ///
  /// In en, this message translates to:
  /// **'Marketing Promotions'**
  String get marketingPromotions;

  /// No description provided for @marketingPromotionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create promotional offers to boost bookings during off-peak hours.'**
  String get marketingPromotionsDescription;

  /// No description provided for @activePromotions.
  ///
  /// In en, this message translates to:
  /// **'Active Promotions'**
  String get activePromotions;

  /// No description provided for @newOffer.
  ///
  /// In en, this message translates to:
  /// **'New Offer'**
  String get newOffer;

  /// No description provided for @noActiveOffers.
  ///
  /// In en, this message translates to:
  /// **'No Active Offers'**
  String get noActiveOffers;

  /// No description provided for @createFirstOfferDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first promotional offer to attract more clients.'**
  String get createFirstOfferDescription;

  /// No description provided for @unableToLoadOffers.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Offers'**
  String get unableToLoadOffers;

  /// No description provided for @offersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve promotional offers.'**
  String get offersLoadFailed;

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{value}% OFF'**
  String percentOff(Object value);

  /// No description provided for @amountOff.
  ///
  /// In en, this message translates to:
  /// **'AED {value} OFF'**
  String amountOff(Object value);

  /// No description provided for @validDateRange.
  ///
  /// In en, this message translates to:
  /// **'Valid: {start} – {end}'**
  String validDateRange(Object start, Object end);

  /// No description provided for @createSpecialOffer.
  ///
  /// In en, this message translates to:
  /// **'Create Special Offer'**
  String get createSpecialOffer;

  /// No description provided for @offerTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Offer Title (e.g. Summer Weekend Deal)'**
  String get offerTitleHint;

  /// No description provided for @discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount Percentage (%)'**
  String get discountPercentage;

  /// No description provided for @publishOffer.
  ///
  /// In en, this message translates to:
  /// **'Publish Offer'**
  String get publishOffer;

  /// No description provided for @offerPublished.
  ///
  /// In en, this message translates to:
  /// **'Offer published successfully!'**
  String get offerPublished;

  /// No description provided for @searchClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search clients by name or phone...'**
  String get searchClientsHint;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No Customers Found'**
  String get noCustomersFound;

  /// No description provided for @noCustomersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No customer records match your current search query.'**
  String get noCustomersMatchSearch;

  /// No description provided for @customerVisits.
  ///
  /// In en, this message translates to:
  /// **'{count} visits'**
  String customerVisits(Object count);

  /// No description provided for @customerNoShows.
  ///
  /// In en, this message translates to:
  /// **'{count} No-Shows'**
  String customerNoShows(Object count);

  /// No description provided for @unableToLoadCustomers.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Customers'**
  String get unableToLoadCustomers;

  /// No description provided for @customerDatabaseLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve customer CRM database.'**
  String get customerDatabaseLoadFailed;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visits;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @noShows.
  ///
  /// In en, this message translates to:
  /// **'No-Shows'**
  String get noShows;

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last Visit: {date}'**
  String lastVisit(Object date);

  /// No description provided for @favoriteServices.
  ///
  /// In en, this message translates to:
  /// **'Favorite Services'**
  String get favoriteServices;

  /// No description provided for @privateOwnerNotes.
  ///
  /// In en, this message translates to:
  /// **'Private Owner Notes (Internal Only)'**
  String get privateOwnerNotes;

  /// No description provided for @privateNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Likes espresso, sensitive skin, prefers Ahmed.'**
  String get privateNotesHint;

  /// No description provided for @savePrivateNotes.
  ///
  /// In en, this message translates to:
  /// **'Save Private Notes'**
  String get savePrivateNotes;

  /// No description provided for @privateNotesSaved.
  ///
  /// In en, this message translates to:
  /// **'Private customer notes saved!'**
  String get privateNotesSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
