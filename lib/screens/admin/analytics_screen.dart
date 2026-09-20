import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_localization.dart';
import '../../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<_AdminStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_AdminStats> _loadStats() async {
    final db = FirebaseFirestore.instance;
    final users = await db.collection('users').count().get();
    final businesses = await db.collection('businesses').count().get();
    final pending = await db
        .collection('businesses')
        .where('is_verified', isEqualTo: false)
        .where('is_active', isEqualTo: true)
        .count()
        .get();
    final bookings = await db.collection('bookings').count().get();

    return _AdminStats(
      users: users.count ?? 0,
      businesses: businesses.count ?? 0,
      pendingApprovals: pending.count ?? 0,
      bookings: bookings.count ?? 0,
    );
  }

  void _refresh() {
    setState(() => _statsFuture = _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop()
              ? context.pop()
              : context.go('/admin/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/admin/dashboard'),
          ),
          title: Text(adminText(context, 'Platform analytics', 'تحليلات المنصة')),
          actions: [
            IconButton(
              tooltip: adminText(context, 'Refresh', 'تحديث'),
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: FutureBuilder<_AdminStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 52),
                      const SizedBox(height: 12),
                      Text(
                        adminText(
                          context,
                          'Unable to load live platform metrics.',
                          'تعذر تحميل مؤشرات المنصة المباشرة.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(adminText(context, 'Try again', 'إعادة المحاولة')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stats = snapshot.data!;
            final cards = [
              _Metric(
                Icons.people_alt_rounded,
                adminText(context, 'Users', 'المستخدمون'),
                stats.users,
              ),
              _Metric(
                Icons.storefront_rounded,
                adminText(context, 'Businesses', 'الأنشطة التجارية'),
                stats.businesses,
              ),
              _Metric(
                Icons.verified_user_rounded,
                adminText(context, 'Pending approvals', 'طلبات الاعتماد'),
                stats.pendingApprovals,
              ),
              _Metric(
                Icons.calendar_month_rounded,
                adminText(context, 'Bookings', 'الحجوزات'),
                stats.bookings,
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 520
                        ? 2
                        : 1;
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 2.8 : 1.6,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) =>
                      _MetricCard(metric: cards[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(metric.icon, size: 34),
            const SizedBox(height: 12),
            Text(
              metric.value.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(metric.label, textAlign: TextAlign.center),
          ],
        ),
      );
}

class _Metric {
  const _Metric(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final int value;
}

class _AdminStats {
  const _AdminStats({
    required this.users,
    required this.businesses,
    required this.pendingApprovals,
    required this.bookings,
  });

  final int users;
  final int businesses;
  final int pendingApprovals;
  final int bookings;
}
