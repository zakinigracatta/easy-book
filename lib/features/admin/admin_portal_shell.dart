import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

String adminText(BuildContext context, String english, String arabic) =>
    Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;

class AdminPortalShell extends ConsumerWidget {
  const AdminPortalShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const _items = <_AdminDestination>[
    _AdminDestination(
      '/admin/dashboard',
      Icons.dashboard_rounded,
      'Dashboard',
      'لوحة التحكم',
    ),
    _AdminDestination(
      '/admin/businesses',
      Icons.storefront_rounded,
      'Businesses',
      'الأنشطة التجارية',
    ),
    _AdminDestination(
      '/admin/users',
      Icons.people_alt_rounded,
      'Users',
      'المستخدمون',
    ),
    _AdminDestination(
      '/admin/approvals',
      Icons.verified_user_rounded,
      'Approvals',
      'طلبات الاعتماد',
    ),
    _AdminDestination(
      '/admin/payments',
      Icons.account_balance_wallet_rounded,
      'Payments',
      'المدفوعات',
    ),
    _AdminDestination(
      '/admin/analytics',
      Icons.insights_rounded,
      'Analytics',
      'التحليلات',
    ),
    _AdminDestination(
      '/admin/reports',
      Icons.summarize_rounded,
      'Reports',
      'التقارير',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    if (locale.languageCode != 'ar' && locale.languageCode != 'en') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(localeProvider.notifier).setLocale(const Locale('en'));
      });
    }

    final wide = MediaQuery.sizeOf(context).width >= 1050;
    if (!wide) return child;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Row(
        textDirection: Directionality.of(context),
        children: [
          _Sidebar(
            location: location,
            locale: locale.languageCode == 'ar' ? 'ar' : 'en',
            onLocaleChanged: (code) =>
                ref.read(localeProvider.notifier).setLocale(Locale(code)),
            onLogout: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/admin/login');
            },
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.locale,
    required this.onLocaleChanged,
    required this.onLogout,
  });

  final String location;
  final String locale;
  final ValueChanged<String> onLocaleChanged;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final isArabic = locale == 'ar';
    return Container(
      width: 272,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111A35), Color(0xFF172554)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Easy Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'ADMIN PORTAL',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x22FFFFFF), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: AdminPortalShell._items.length,
                itemBuilder: (context, index) {
                  final item = AdminPortalShell._items[index];
                  final selected = item.route == '/admin/dashboard'
                      ? location == '/admin' || location == item.route
                      : location.startsWith(item.route);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Material(
                      color: selected
                          ? Colors.white.withValues(alpha: .12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Icon(
                          item.icon,
                          color: selected
                              ? Colors.white
                              : const Color(0xFFCBD5E1),
                        ),
                        title: Text(
                          isArabic ? item.arabic : item.english,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFCBD5E1),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        onTap: () => context.go(item.route),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _LanguageButton(
                          label: 'English',
                          selected: locale == 'en',
                          onTap: () => onLocaleChanged('en'),
                        ),
                        _LanguageButton(
                          label: 'العربية',
                          selected: locale == 'ar',
                          onTap: () => onLocaleChanged('ar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFFCA5A5),
                    ),
                    title: Text(
                      isArabic ? 'تسجيل الخروج' : 'Sign out',
                      style: const TextStyle(color: Color(0xFFFCA5A5)),
                    ),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF172554) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _AdminDestination {
  const _AdminDestination(this.route, this.icon, this.english, this.arabic);
  final String route;
  final IconData icon;
  final String english;
  final String arabic;
}
