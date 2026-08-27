import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_drawer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_text.dart';
import '../../l10n/l10n.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/welcome');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10nOf(context).superAdminCenter),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: const AppDrawer(portalType: 'admin'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10nOf(context).platformRevenueMtd,
                            style: const TextStyle(
                                color: AppColors.textMutedDark, fontSize: 13)),
                        const SizedBox(height: 4),
                        const GradientText('\$124,500',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.shield_rounded,
                        size: 40, color: AppColors.error),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(l10nOf(context).adminManagementControl,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _adminTile(context, l10nOf(context).userAccountManagement,
                  Icons.group_rounded, '/users-management'),
              _adminTile(context, l10nOf(context).salonVerificationApprovals(3),
                  Icons.verified_user_rounded, '/salon-approval'),
              _adminTile(context, l10nOf(context).payoutQueuesCommissions,
                  Icons.payments_rounded, '/payment-management'),
              _adminTile(context, l10nOf(context).platformTrafficAnalytics,
                  Icons.bar_chart_rounded, '/analytics'),
              _adminTile(context, l10nOf(context).systemAuditLogsReports,
                  Icons.summarize_rounded, '/reports'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
      BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: AppColors.error),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMutedDark),
        ),
      ),
    );
  }
}
