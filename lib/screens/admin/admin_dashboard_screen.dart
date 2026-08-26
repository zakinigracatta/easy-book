import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

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
          title: Text(context.tr('Super Admin Center')),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: AppDrawer(portalType: 'admin'),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: EdgeInsets.all(20),
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('Platform Revenue MTD'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        GradientText(
                          '\$124,500',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.shield_rounded,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                context.tr('Admin Management Control'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _adminTile(
                context,
                'User & Account Management',
                Icons.group_rounded,
                '/users-management',
              ),
              _adminTile(
                context,
                'Salon Verification & Approvals (3)',
                Icons.verified_user_rounded,
                '/salon-approval',
              ),
              _adminTile(
                context,
                'Payout Queues & Commissions',
                Icons.payments_rounded,
                '/payment-management',
              ),
              _adminTile(
                context,
                'Platform Traffic & Usage Analytics',
                Icons.bar_chart_rounded,
                '/analytics',
              ),
              _adminTile(
                context,
                'System Audit Logs & Reports',
                Icons.summarize_rounded,
                '/reports',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push(route),
        child: ListTile(
          leading: Icon(icon, color: AppColors.error),
          title: Text(
            context.tr(title),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
