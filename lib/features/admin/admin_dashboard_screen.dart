import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _activeTab = 'Overview';
  final List<String> _tabs = ['Overview', 'Salons', 'Finance', 'Users'];

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/welcome');
              }
            },
          ),
          title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tabs.map((t) {
                    final isSelected = _activeTab == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        selectedColor: AppColors.error,
                        backgroundColor: AppColors.glassBgDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMutedDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _activeTab = t);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Revenue Metric
              GlassCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Platform Revenue (MTD)', style: TextStyle(color: AppColors.textMutedDark, fontSize: 13)),
                        SizedBox(height: 4),
                        GradientText('\$124,500', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('+18% from last month', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Icon(Icons.attach_money_rounded, size: 48, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people_rounded, size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Users', style: TextStyle(fontSize: 13, color: AppColors.textMutedDark)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('15,243', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('+120 today', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.storefront_rounded, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Salons', style: TextStyle(fontSize: 13, color: AppColors.textMutedDark)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('342', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Active Partners', style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // System Health
              const Text('System Health', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text('API Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text('100% Uptime', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.query_stats_rounded, size: 20, color: AppColors.accent),
                            SizedBox(width: 10),
                            Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('1,204', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Admin Actions
              const Text('Admin Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () => context.push('/user-management'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Manage Salons & Users'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/business-approval'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Review Pending Approvals (3)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/payouts'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Approve Payout Requests'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
