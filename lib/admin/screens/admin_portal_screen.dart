import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../models/admin_models.dart';
import '../permissions/admin_permissions.dart';
import '../providers/admin_providers.dart';
import 'business_management_screen.dart';

enum AdminSection {
  dashboard('لوحة التحكم', Icons.dashboard_outlined, '/admin'),
  businesses(
      'الأنشطة التجارية', Icons.storefront_outlined, '/admin/businesses'),
  customers('العملاء', Icons.people_outline, '/admin/customers'),
  bookings('الحجوزات', Icons.calendar_month_outlined, '/admin/bookings'),
  services('الخدمات', Icons.design_services_outlined, '/admin/services'),
  staff('الموظفون', Icons.badge_outlined, '/admin/staff'),
  finance('المالية', Icons.account_balance_wallet_outlined, '/admin/finance'),
  reviews('التقييمات', Icons.star_outline, '/admin/reviews'),
  notifications('الإشعارات', Icons.notifications_none, '/admin/notifications'),
  reports('التقارير', Icons.bar_chart_outlined, '/admin/reports'),
  support('الدعم', Icons.support_agent_outlined, '/admin/support'),
  settings('الإعدادات', Icons.settings_outlined, '/admin/settings');

  const AdminSection(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}

class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({required this.section, super.key});
  final AdminSection section;

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen> {
  bool collapsed = false;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 980;
    return Scaffold(
      drawer: narrow ? Drawer(child: _navigation(false)) : null,
      body: Row(children: [
        if (!narrow) _navigation(collapsed),
        Expanded(
          child: Column(children: [
            _TopBar(
              title: widget.section.title,
              showMenu: narrow,
              onMenu: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(narrow ? 16 : 28),
                  child: widget.section == AdminSection.dashboard
                      ? const _Dashboard()
                      : _CollectionPage(section: widget.section),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _navigation(bool isCollapsed) => Container(
        width: isCollapsed ? 80 : 250,
        color: const Color(0xFF172554),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.auto_stories, color: Color(0xFF2563EB)),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Easy Book',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final item in AdminSection.values)
                    _NavItem(
                      item: item,
                      selected: item == widget.section,
                      collapsed: isCollapsed,
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: isCollapsed
                  ? null
                  : const Text('تسجيل الخروج',
                      style: TextStyle(color: Colors.white70)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (mounted) context.go('/admin-login');
              },
            ),
            if (MediaQuery.sizeOf(context).width >= 980)
              IconButton(
                color: Colors.white70,
                tooltip: isCollapsed ? 'توسيع القائمة' : 'طي القائمة',
                onPressed: () => setState(() => collapsed = !collapsed),
                icon: Icon(isCollapsed
                    ? Icons.keyboard_double_arrow_left
                    : Icons.keyboard_double_arrow_right),
              ),
          ]),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.collapsed,
  });
  final AdminSection item;
  final bool selected;
  final bool collapsed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          selected: selected,
          selectedTileColor: Colors.white.withValues(alpha: .14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading:
              Icon(item.icon, color: selected ? Colors.white : Colors.white70),
          title: collapsed
              ? null
              : Text(item.title,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
          onTap: () => context.go(item.route),
        ),
      );
}

class _TopBar extends ConsumerWidget {
  const _TopBar(
      {required this.title, required this.showMenu, required this.onMenu});
  final String title;
  final bool showMenu;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider)!;
    return Material(
      elevation: 1,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            if (showMenu)
              IconButton(onPressed: onMenu, icon: const Icon(Icons.menu)),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (MediaQuery.sizeOf(context).width > 760)
              const SizedBox(
                width: 260,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'بحث في لوحة الإدارة',
                  elevation: WidgetStatePropertyAll(0),
                ),
              ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.notifications_none)),
            const SizedBox(width: 8),
            CircleAvatar(
                child: Text(user.fullName.isEmpty ? 'A' : user.fullName[0])),
            if (MediaQuery.sizeOf(context).width > 700) ...[
              const SizedBox(width: 10),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                        user.role == UserRole.superAdmin
                            ? 'Super Admin'
                            : 'Admin',
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(adminDashboardProvider).when(
          loading: () => const _LoadingGrid(),
          error: (error, _) => _ErrorState(
              onRetry: () => ref.invalidate(adminDashboardProvider)),
          data: (data) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 16, runSpacing: 16, children: [
              _Kpi('إجمالي العملاء', data.totalCustomers, Icons.people_outline),
              _Kpi('إجمالي الأنشطة', data.totalBusinesses,
                  Icons.storefront_outlined),
              _Kpi('إجمالي الحجوزات', data.totalBookings,
                  Icons.calendar_month_outlined),
              _Kpi('بانتظار الموافقة', data.pendingBusinesses.length,
                  Icons.pending_actions_outlined),
            ]),
            const SizedBox(height: 28),
            _RecordsCard(title: 'أحدث الحجوزات', records: data.recentBookings),
            const SizedBox(height: 20),
            _RecordsCard(
                title: 'طلبات الأنشطة المعلقة',
                records: data.pendingBusinesses),
          ]),
        );
  }
}

class _CollectionPage extends ConsumerWidget {
  const _CollectionPage({required this.section});
  final AdminSection section;

  String? get collection => switch (section) {
        AdminSection.businesses => 'businesses',
        AdminSection.customers => 'users',
        AdminSection.bookings => 'bookings',
        AdminSection.services => 'services',
        AdminSection.staff => 'staff',
        AdminSection.reviews => 'reviews',
        _ => null,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (section == AdminSection.businesses) {
      return const BusinessManagementScreen();
    }
    if (section == AdminSection.finance ||
        section == AdminSection.notifications ||
        section == AdminSection.reports ||
        section == AdminSection.support ||
        section == AdminSection.settings) {
      return _FutureReady(section: section);
    }
    if (section == AdminSection.customers) {
      return ref.watch(adminCustomersProvider).when(
            loading: () => const _LoadingGrid(),
            error: (error, _) => _ErrorState(
                onRetry: () => ref.invalidate(adminCustomersProvider)),
            data: (records) => _RecordsCard(
                title: section.title, records: records, showSearch: true),
          );
    }
    if (section == AdminSection.services ||
        section == AdminSection.staff ||
        section == AdminSection.reviews) {
      return _FutureReady(section: section);
    }
    final name = collection!;
    return ref.watch(adminCollectionProvider(name)).when(
          loading: () => const _LoadingGrid(),
          error: (error, _) => _ErrorState(
              onRetry: () => ref.invalidate(adminCollectionProvider(name))),
          data: (records) => _RecordsCard(
              title: section.title, records: records, showSearch: true),
        );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 230,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(NumberFormat.decimalPattern().format(value),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ]),
            ]),
          ),
        ),
      );
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard(
      {required this.title, required this.records, this.showSearch = false});
  final String title;
  final List<AdminRecord> records;
  final bool showSearch;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold))),
              if (showSearch)
                const SizedBox(
                    width: 260,
                    child: TextField(
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'بحث وتصفية'))),
            ]),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const AdminEmptyState()
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('المعرّف')),
                    DataColumn(label: Text('الاسم / الوصف')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('التاريخ'))
                  ],
                  rows: records
                      .map((record) => DataRow(cells: [
                            DataCell(SelectableText(record.id)),
                            DataCell(Text(record.text([
                              'name',
                              'full_name',
                              'business_name',
                              'service_name',
                              'comment'
                            ]))),
                            DataCell(Text(record.text(
                                ['status', 'account_status'],
                                fallback: '—'))),
                            DataCell(Text(record.date([
                                      'created_at',
                                      'createdAt',
                                      'date_time'
                                    ]) ==
                                    null
                                ? '—'
                                : DateFormat.yMMMd().format(record.date([
                                    'created_at',
                                    'createdAt',
                                    'date_time'
                                  ])!))),
                          ]))
                      .toList(),
                ),
              ),
          ]),
        ),
      );
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 180,
        child: Center(child: Text('لا توجد بيانات متاحة حاليًا.')),
      );
}

class _FutureReady extends ConsumerWidget {
  const _FutureReady({required this.section});
  final AdminSection section;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider)!;
    final restricted = section == AdminSection.settings &&
        !AdminPermissions.allows(
            user.role, AdminPermission.changePlatformSettings);
    return Card(
        child: SizedBox(
            height: 300,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(restricted ? Icons.lock_outline : section.icon, size: 52),
                const SizedBox(height: 16),
                Text(
                    restricted
                        ? 'يتطلب هذا القسم صلاحية Super Admin'
                        : 'القسم جاهز للربط بالبنية الخلفية',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                    restricted
                        ? 'لا يملك حساب Admin صلاحية تغيير إعدادات المنصة.'
                        : 'لن تُعرض بيانات أو عمليات وهمية. سيظهر المحتوى عند توفر البنية والبيانات الفعلية.',
                    textAlign: TextAlign.center),
              ]),
            ))));
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  @override
  Widget build(BuildContext context) => const SizedBox(
      height: 300, child: Center(child: CircularProgressIndicator()));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 300,
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_outlined, size: 52),
        const SizedBox(height: 12),
        const Text('تعذر تحميل البيانات. تحقق من الاتصال والصلاحيات.'),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ])));
}
