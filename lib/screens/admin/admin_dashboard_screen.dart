import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_portal_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _items = <_Destination>[
    _Destination(
        'Businesses',
        'الأنشطة التجارية',
        'Review business profiles and operational status',
        'مراجعة ملفات الأنشطة وحالتها التشغيلية',
        Icons.storefront_rounded,
        Color(0xFF2563EB),
        '/admin/businesses'),
    _Destination(
        'Users',
        'المستخدمون',
        'Manage customer and partner accounts',
        'إدارة حسابات العملاء والشركاء',
        Icons.people_alt_rounded,
        Color(0xFF7C3AED),
        '/admin/users'),
    _Destination(
        'Approvals',
        'طلبات الاعتماد',
        'Verify and process pending applications',
        'التحقق من الطلبات المعلّقة ومعالجتها',
        Icons.verified_user_rounded,
        Color(0xFF059669),
        '/admin/approvals'),
    _Destination(
        'Payments',
        'المدفوعات',
        'Monitor payouts and platform transactions',
        'متابعة التحويلات ومعاملات المنصة',
        Icons.account_balance_wallet_rounded,
        Color(0xFFEA580C),
        '/admin/payments'),
    _Destination(
        'Analytics',
        'التحليلات',
        'Explore platform activity and performance',
        'استعراض نشاط المنصة ومؤشرات الأداء',
        Icons.insights_rounded,
        Color(0xFF0891B2),
        '/admin/analytics'),
    _Destination(
        'Reports',
        'التقارير',
        'Access operational reports and audit records',
        'الوصول إلى التقارير وسجلات التدقيق',
        Icons.summarize_rounded,
        Color(0xFF475569),
        '/admin/reports'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(28, 30, 28, 16),
                sliver: SliverToBoxAdapter(child: _Header()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 36),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 1050
                        ? 3
                        : width >= 620
                            ? 2
                            : 1;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: columns == 1 ? 2.05 : 1.55,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _DestinationCard(item: _items[index]),
                        childCount: _items.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D0F172A), blurRadius: 24, offset: Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.dashboard_customize_rounded,
                  color: Color(0xFF2563EB), size: 29),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      adminText(
                          context, 'Admin workspace', 'مساحة عمل الإدارة'),
                      style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.4)),
                  const SizedBox(height: 6),
                  Text(
                      adminText(
                          context,
                          'Manage Easy Book operations from one secure place.',
                          'أدِر عمليات إيزي بوك من مكان واحد وآمن.'),
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.item});
  final _Destination item;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.go(item.route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EDF5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: item.color.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(item.icon, color: item.color)),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF94A3B8)),
                  ],
                ),
                const Spacer(),
                Text(adminText(context, item.english, item.arabic),
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Text(
                    adminText(context, item.englishDescription,
                        item.arabicDescription),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF64748B), height: 1.45, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
}

class _Destination {
  const _Destination(this.english, this.arabic, this.englishDescription,
      this.arabicDescription, this.icon, this.color, this.route);
  final String english;
  final String arabic;
  final String englishDescription;
  final String arabicDescription;
  final IconData icon;
  final Color color;
  final String route;
}
