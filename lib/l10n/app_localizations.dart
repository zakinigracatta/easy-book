import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('ru'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Localizations.localeOf(context));
  }

  String tr(
    String source, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {
    final languageCode = locale.languageCode.toLowerCase();
    final translations = switch (languageCode) {
      'ru' => _ru,
      _ => const <String, String>{},
    };

    var value = translations[source] ?? source;
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return value;
  }

  static const Map<String, String> _ru = {
    // Common
    'Easy Book': 'Easy Book',
    'Back': 'Назад',
    'Go Back': 'Назад',
    'Home': 'Главная',
    'Back to Home': 'На главную',
    'Continue': 'Продолжить',
    'Next': 'Далее',
    'Done': 'Готово',
    'Cancel': 'Отмена',
    'Close': 'Закрыть',
    'Save': 'Сохранить',
    'Edit': 'Изменить',
    'Delete': 'Удалить',
    'Retry': 'Повторить',
    'Try Again': 'Попробовать снова',
    'Loading...': 'Загрузка...',
    'Search': 'Поиск',
    'Settings': 'Настройки',
    'Notifications': 'Уведомления',
    'Profile': 'Профиль',
    'Help': 'Помощь',
    'About': 'О приложении',
    'Logout': 'Выйти',
    'Active': 'Активно',
    'Inactive': 'Неактивно',
    'Unavailable': 'Недоступно',
    'Available': 'Доступно',
    'Select': 'Выбрать',
    'Selected': 'Выбрано',
    'All': 'Все',
    'Today': 'Сегодня',
    'Tomorrow': 'Завтра',
    'Date': 'Дата',
    'Time': 'Время',
    'Specialist': 'Специалист',
    'Service': 'Услуга',
    'Services': 'Услуги',
    'Salon': 'Салон',
    'Customer': 'Клиент',
    'Business Owner': 'Владелец бизнеса',
    'Admin': 'Администратор',
    'Error': 'Ошибка',
    'Success': 'Успешно',
    'Required': 'Обязательно',
    'Optional': 'Необязательно',
    'AED': 'AED',
    'minutes': 'минут',
    'min': 'мин',

    // Authentication
    'Sign In': 'Войти',
    'Welcome Back 👋': 'С возвращением 👋',
    'Sign in to access your portal': 'Войдите, чтобы открыть свой аккаунт',
    'Email / Phone': 'Эл. почта / Телефон',
    'Email': 'Эл. почта',
    'Password': 'Пароль',
    'Forgot Password?': 'Забыли пароль?',
    'Customer Register': 'Регистрация клиента',
    'Owner Register': 'Регистрация владельца',
    'Register as Customer? ': 'Зарегистрироваться как клиент? ',
    'Register as Partner? ': 'Зарегистрироваться как партнёр? ',
    'Please enter your email and password.':
        'Введите адрес электронной почты и пароль.',
    'Invalid email or password.': 'Неверная электронная почта или пароль.',
    'Authentication failed.': 'Не удалось выполнить вход.',
    'Too many sign-in attempts. Please wait and try again.':
        'Слишком много попыток входа. Подождите и попробуйте снова.',
    'Network connection failed. Check your connection and try again.':
        'Ошибка сети. Проверьте подключение и попробуйте снова.',
    'Create Account': 'Создать аккаунт',
    'Create your Easy Book account': 'Создайте аккаунт Easy Book',
    'Full Name': 'Полное имя',
    'Phone Number': 'Номер телефона',
    'Confirm Password': 'Подтвердите пароль',
    'Already have an account?': 'Уже есть аккаунт?',
    'Already have an account? ': 'Уже есть аккаунт? ',
    'Create Customer Account': 'Создать аккаунт клиента',
    'Business Portal Login': 'Вход для бизнеса',
    'Salon Partner Sign In': 'Вход партнёра салона',
    'Manage appointments, staff schedules & sales':
        'Управляйте записями, графиками сотрудников и продажами',
    'Salon Email': 'Эл. почта салона',
    'Open Partner Dashboard': 'Открыть панель партнёра',
    'Please enter salon email and password.':
        'Введите электронную почту салона и пароль.',
    'This account is not registered as a business owner.':
        'Этот аккаунт не зарегистрирован как владелец бизнеса.',
    'Invalid business email or password.':
        'Неверная электронная почта или пароль бизнеса.',
    'Partner authentication failed. Please try again.':
        'Не удалось войти в аккаунт партнёра. Попробуйте снова.',
    'Partner sign in is unavailable right now. Please try again.':
        'Вход для партнёров сейчас недоступен. Попробуйте позже.',
    'Admin Portal Login': 'Вход администратора',
    'Super Admin Sign In': 'Вход главного администратора',
    'Platform management, partner verification & payouts':
        'Управление платформой, проверка партнёров и выплаты',
    'Admin Email': 'Эл. почта администратора',
    'Enter Admin Center': 'Открыть центр администратора',
    'This account does not have administrator access.':
        'У этого аккаунта нет прав администратора.',
    'Verify Email Address': 'Подтвердите электронную почту',
    'Verify Your Email': 'Подтвердите электронную почту',
    'We sent a verification link to:\n{email}':
        'Мы отправили ссылку для подтверждения на:\n{email}',
    'Please check your email inbox and click the verification link before proceeding.':
        'Проверьте входящие сообщения и перейдите по ссылке подтверждения, прежде чем продолжить.',
    "I've verified my email": 'Я подтвердил(а) электронную почту',
    'Resend verification email': 'Отправить письмо повторно',
    'Verification email sent! Please check your inbox.':
        'Письмо отправлено. Проверьте входящие сообщения.',
    'Email verified successfully!': 'Электронная почта успешно подтверждена!',
    'Email is not verified yet. Please check your inbox or spam folder.':
        'Электронная почта ещё не подтверждена. Проверьте входящие сообщения и папку «Спам».',
    'Logout / Use another account': 'Выйти / Использовать другой аккаунт',
    'Forgot Password': 'Восстановление пароля',
    'Reset Password': 'Сбросить пароль',
    'Send Reset Link': 'Отправить ссылку для сброса',
    'Enter your email address and we will send you a password reset link.':
        'Введите электронную почту, и мы отправим ссылку для сброса пароля.',
    'OTP Verification': 'Подтверждение кода',
    'Verify Code': 'Подтвердить код',

    // Customer discovery
    'Discover': 'Обзор',
    'Search salons, spas & services': 'Поиск салонов, спа и услуг',
    'Categories': 'Категории',
    'Popular Near You': 'Популярное рядом',
    'Recommended for You': 'Рекомендуем для вас',
    'View All': 'Смотреть все',
    'Favorites': 'Избранное',
    'My Favorites': 'Моё избранное',
    'No favorites yet': 'В избранном пока ничего нет',
    'No salons found': 'Салоны не найдены',
    'No results found': 'Ничего не найдено',
    'Reviews': 'Отзывы',
    'Gallery': 'Галерея',
    'About Salon': 'О салоне',
    'Location': 'Местоположение',
    'Directions': 'Маршрут',
    'Call': 'Позвонить',
    'Website': 'Сайт',
    'Book Now': 'Записаться',
    'Select a service or tap Book Now':
        'Выберите услугу или нажмите «Записаться»',
    'Online booking is currently unavailable':
        'Онлайн-запись сейчас недоступна',
    'This salon is currently inactive or not accepting online bookings.':
        'Этот салон сейчас неактивен или не принимает онлайн-записи.',
    'Salon Not Found': 'Салон не найден',
    'The requested business profile is no longer available.':
        'Запрошенный профиль бизнеса больше недоступен.',
    "We couldn't load this salon.": 'Не удалось загрузить салон.',
    'Please check your network connection and try again.':
        'Проверьте подключение к интернету и попробуйте снова.',
    'Specialist information is not available yet.':
        'Информация о специалистах пока недоступна.',

    // Booking
    'Step 1: Select Service': 'Шаг 1: Выберите услугу',
    'Select Service': 'Выберите услугу',
    'Please select a service to proceed.':
        'Выберите услугу, чтобы продолжить.',
    'Invalid service selected.': 'Выбрана недопустимая услуга.',
    'No services available for this salon.':
        'В этом салоне сейчас нет доступных услуг.',
    'Next: Select Date': 'Далее: выбрать специалиста',
    'Select Specialist': 'Выберите специалиста',
    'Choose a Specialist': 'Выберите специалиста',
    'Select your preferred specialist or choose anyone available.':
        'Выберите специалиста или любого доступного сотрудника.',
    'Any Available Specialist': 'Любой доступный специалист',
    'Please choose a specialist or select Any Available Specialist.':
        'Выберите специалиста или вариант «Любой доступный специалист».',
    'Continue: Select Date & Time': 'Продолжить: дата и время',
    'Select Appointment Date': 'Выберите дату записи',
    'Select Date': 'Выберите дату',
    'Next: Select Time Slot': 'Далее: выбрать время',
    'Select Appointment Time': 'Выберите время записи',
    'Please select an available time slot to continue.':
        'Выберите доступное время, чтобы продолжить.',
    'Salon not found.': 'Салон не найден.',
    'Review Booking Summary': 'Проверить запись',
    'Booking Summary': 'Детали записи',
    'Appointment': 'Запись',
    'Appointment Info': 'Информация о записи',
    'Total duration': 'Общая длительность',
    'Total Duration': 'Общая длительность',
    'Total': 'Итого',
    'Amount due': 'К оплате',
    'Continue to Confirmation': 'Перейти к подтверждению',
    'Please complete the service, specialist, date and time first.':
        'Сначала выберите услугу, специалиста, дату и время.',
    'Not selected': 'Не выбрано',
    'Step 4: Confirm Booking': 'Шаг 4: Подтверждение записи',
    'Confirm Booking': 'Подтвердить запись',
    'Date & Time': 'Дата и время',
    'Duration': 'Длительность',
    'Total Price': 'Итоговая стоимость',
    'Please sign in to complete your booking.':
        'Войдите, чтобы завершить запись.',
    'Please verify your email address to proceed with booking.':
        'Подтвердите электронную почту, чтобы продолжить запись.',
    'Please select all booking details before confirming.':
        'Выберите все параметры записи перед подтверждением.',
    'Please select a valid appointment time.':
        'Выберите корректное время записи.',
    'Please select a future appointment time.':
        'Выберите время записи в будущем.',
    'This time slot was just booked by another customer. Please select another available time.':
        'Это время только что занял другой клиент. Выберите другое доступное время.',
    'The business is currently closed or not accepting online bookings.':
        'Салон сейчас закрыт или не принимает онлайн-записи.',
    'The selected time is outside the business operating hours.':
        'Выбранное время находится вне часов работы салона.',
    'The selected specialist is unavailable during this time slot.':
        'Выбранный специалист недоступен в это время.',
    'The selected service is currently unavailable.':
        'Выбранная услуга сейчас недоступна.',
    'Please verify your email address before booking.':
        'Подтвердите электронную почту перед записью.',
    'This appointment can no longer be cancelled.':
        'Эту запись больше нельзя отменить.',
    'This appointment can no longer be rescheduled.':
        'Эту запись больше нельзя перенести.',
    'We could not complete the booking. Please try again.':
        'Не удалось завершить запись. Попробуйте снова.',
    'Booking Confirmed!': 'Запись подтверждена!',
    'Your appointment has been successfully scheduled. You can review all details in My Bookings.':
        'Ваша запись успешно создана. Все детали доступны в разделе «Мои записи».',
    'View My Bookings': 'Мои записи',
    'My Bookings': 'Мои записи',
    'Upcoming': 'Предстоящие',
    'Past': 'Прошедшие',
    'Cancelled': 'Отменённые',
    'Cancel Booking': 'Отменить запись',
    'Reschedule': 'Перенести',
    'Reschedule Booking': 'Перенести запись',
    'Booking Details': 'Детали записи',
    'No bookings yet': 'Записей пока нет',
    'Checkout & Payment (Future Phase)': 'Оплата (будущий этап)',
    'Payment integration will be enabled in Phase 3.':
        'Оплата будет подключена на этапе 3.',
    'Credit / Debit Card': 'Кредитная / дебетовая карта',
    'Apple Pay': 'Apple Pay',

    // Settings/help
    'App Settings': 'Настройки приложения',
    'Push Notifications': 'Push-уведомления',
    'Dark Theme Mode': 'Тёмная тема',
    'Language': 'Язык',
    'English': 'Английский',
    'Arabic': 'Арабский',
    'Russian': 'Русский',
    'Help & Support': 'Помощь и поддержка',
    'About Easy Book': 'О Easy Book',

    // Owner
    'Owner Dashboard': 'Панель владельца',
    'Business Dashboard': 'Панель бизнеса',
    'Bookings': 'Записи',
    'Employees': 'Сотрудники',
    'Customers': 'Клиенты',
    'Finance': 'Финансы',
    'Expenses': 'Расходы',
    'Promotions': 'Акции',
    'Business Hours': 'Часы работы',
    'Manage Services': 'Управление услугами',
    'Employee Management': 'Управление сотрудниками',
    'Add Employee': 'Добавить сотрудника',
    'Add New Employee': 'Добавить сотрудника',
    'Edit Employee': 'Изменить сотрудника',
    'Employee Profile': 'Профиль сотрудника',
    'Employee Full Name *': 'Полное имя сотрудника *',
    'Job Title / Specialty *': 'Должность / Специализация *',
    'Years of Experience': 'Опыт работы (лет)',
    'Professional Bio': 'Профессиональное описание',
    'Active & Bookable': 'Активен и доступен для записи',
    'Inactive employees will not be offered for new bookings.':
        'Неактивные сотрудники не будут доступны для новых записей.',
    'Photos': 'Фотографии',
    'Main Profile Photo': 'Основное фото профиля',
    'Portfolio Photos': 'Фото портфолио',
    'Employee Time Off & Leave': 'Отпуска и выходные сотрудников',
    'Staff Leave Manager': 'Управление отсутствиями',
    'Scheduled leave blocks customer booking slots for the selected employee.':
        'Запланированное отсутствие блокирует время записи выбранного сотрудника.',
    'Scheduled Leave Periods': 'Запланированные отсутствия',
    'Add Leave': 'Добавить отсутствие',
    'No Time Off Scheduled': 'Отсутствия не запланированы',
    'Schedule Leave': 'Запланировать отсутствие',
    'Schedule Employee Time Off': 'Запланировать отсутствие сотрудника',
    'Select Employee': 'Выберите сотрудника',
    'Reason (Vacation, Sick Leave, Day Off)':
        'Причина (отпуск, больничный, выходной)',
    'Start': 'Начало',
    'End': 'Окончание',
    'Save Leave Period': 'Сохранить период отсутствия',
    'Employee leave scheduled successfully.':
        'Отсутствие сотрудника успешно запланировано.',
    'Unable to schedule employee leave. Please try again.':
        'Не удалось запланировать отсутствие. Попробуйте снова.',
    'Sales Report': 'Отчёт о продажах',
    'Profit & Loss': 'Прибыли и убытки',
    'Revenue': 'Выручка',
    'Net Profit': 'Чистая прибыль',
    'Total Expenses': 'Общие расходы',
    'Add Expense': 'Добавить расход',
    'One-time': 'Разовый',
    'Monthly': 'Ежемесячно',
    'Annual': 'Ежегодно',
    'Frequency': 'Периодичность',

    // Admin
    'Admin Dashboard': 'Панель администратора',
    'Users & Accounts Management': 'Пользователи и аккаунты',
    'Salon Approval': 'Проверка салонов',
    'Payment Management': 'Управление платежами',
    'Analytics': 'Аналитика',
    'Reports': 'Отчёты',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationContext on BuildContext {
  String tr(
    String source, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {
    return AppLocalizations.of(this).tr(source, params: params);
  }
}
