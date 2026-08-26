import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.favorite_rounded,
        'label': 'Favorite Salons',
        'route': '/favorites'
      },
      {
        'icon': Icons.credit_card_rounded,
        'label': 'Payment Methods',
        'route': '/payment-methods'
      },
      {
        'icon': Icons.notifications_rounded,
        'label': 'Notifications',
        'badge': '2',
        'route': '/notifications'
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'label': 'Rewards & Loyalty',
        'route': '/rewards'
      },
      {
        'icon': Icons.wallet_membership_rounded,
        'label': 'Mobile Wallet Passes',
        'route': '/wallet-pass'
      },
      {
        'icon': Icons.help_outline_rounded,
        'label': 'Help & Support',
        'route': '/help'
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'App Settings',
        'route': '/settings'
      },
    ];

    final recentActivities = [
      {'text': 'Booked Haircut at Elegance Men Salon', 'time': '2 hours ago'},
      {'text': 'Earned "Loyal Customer" Badge', 'time': '1 day ago'},
      {'text': 'Reviewed Spa & Relax', 'time': '3 days ago'},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // User Info Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.primary, width: 3),
                          ),
                          child: const ClipOval(
                            child: Image(
                              image: NetworkImage(
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ahmed Mohamed',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text('+1 (555) 123-4567',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMutedDark)),
                            const SizedBox(height: 2),
                            const Text('📍 Dubai, UAE',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMutedDark)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Gold Member',
                                  style: TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        onPressed: () => context.push('/edit-profile'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () => context.push('/wallet'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Column(
                        children: [
                          Text('\$120',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          SizedBox(height: 4),
                          Text('Wallet',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMutedDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      onTap: () => context.push('/bookings'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Column(
                        children: [
                          Text('12',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          SizedBox(height: 4),
                          Text('Bookings',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMutedDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      onTap: () => context.push('/deals'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Column(
                        children: [
                          Text('3',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          SizedBox(height: 4),
                          Text('Coupons',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMutedDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Badges / Achievements
              const Text('My Badges',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 28, color: AppColors.primary),
                          SizedBox(height: 6),
                          Text('Top Reviewer',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Icon(Icons.military_tech_rounded,
                              size: 28, color: AppColors.error),
                          SizedBox(height: 6),
                          Text('Early Bird',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              size: 28, color: AppColors.textMutedDark),
                          SizedBox(height: 6),
                          Text('Locked',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMutedDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              const Text('Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: recentActivities
                      .map((act) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(act['text']!,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(act['time']!,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMutedDark)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Settings & Menu Items
              const Text('Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...menuItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      onTap: () => context.push(item['route'] as String),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(item['icon'] as IconData,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 14),
                              Text(item['label'] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Row(
                            children: [
                              if (item.containsKey('badge'))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(item['badge'] as String,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textMutedDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 10),

              // Logout Button
              GlassCard(
                onTap: () => context.go('/welcome'),
                borderColor: AppColors.error.withValues(alpha: 0.4),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20),
                    SizedBox(width: 14),
                    Text('Logout',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
