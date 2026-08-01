import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_text.dart';
import '../../core/constants/app_colors.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  String _activeTab = 'Overview';

  final List<String> _tabs = [
    'Overview', 'Schedule', 'Requests', 'Staff', 'Clients', 'Services', 'Marketing', 'Reviews'
  ];

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/welcome');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Salon Portal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            Text('Easy Book Business Center', style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                          ],
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=150&q=80'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Action Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _actionButton('POS Register', Icons.point_of_sale_rounded, AppColors.primary, () => context.push('/pos')),
                      _actionButton('Verified Seal', Icons.verified_user_rounded, AppColors.success, () => context.push('/verify-partner')),
                      _actionButton('Staff Payroll', Icons.people_rounded, AppColors.glassBgDark, () => context.push('/payroll')),
                      _actionButton('Inventory', Icons.inventory_2_rounded, AppColors.glassBgDark, () => context.push('/inventory')),
                      _actionButton('Campaigns', Icons.campaign_rounded, AppColors.glassBgDark, () => context.push('/campaigns')),
                      _actionButton('Subscribers', Icons.star_rounded, AppColors.glassBgDark, () => context.push('/subscribe')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation Tabs
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
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.glassBgDark,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMutedDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _activeTab = t);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                if (_activeTab == 'Overview') ...[
                  // Revenue Bar Chart Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Revenue (This Week)', style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                                SizedBox(height: 4),
                                GradientText('\$4,250.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.trending_up_rounded, color: AppColors.success, size: 16),
                                  SizedBox(width: 4),
                                  Text('+12%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [40, 70, 45, 90, 60, 100, 80].map((h) => Container(
                              width: 24,
                              height: h.toDouble(),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(child: _metricCard('Bookings', '142', '+18%', Icons.calendar_month_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _metricCard('Active Staff', '8', 'Full Team', Icons.badge_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _metricCard('Rating', '4.9 ★', '328 reviews', Icons.star_rounded)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('Today\'s Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _appointmentTile('Sarah Jenkins', 'Royal Haircut & Beard Trim', '2:30 PM', '\$65.00', 'Confirmed'),
                  _appointmentTile('Michael Chang', 'Deep Tissue Spa Massage', '4:00 PM', '\$90.00', 'Pending'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color bg, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _metricCard(String label, String val, String sub, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
        ],
      ),
    );
  }

  Widget _appointmentTile(String name, String service, String time, String price, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$service • $time'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(status, style: TextStyle(fontSize: 11, color: status == 'Confirmed' ? AppColors.success : AppColors.warning)),
            ],
          ),
        ),
      ),
    );
  }
}
