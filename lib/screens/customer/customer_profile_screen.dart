import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../theme/app_colors.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي للعميل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('أحمد محمد',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('+1 (555) 123-4567',
                          style: TextStyle(
                              color: AppColors.textMutedDark, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('عضو VIP ذهبي',
                            style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _profileOption(context, Icons.chat_rounded, 'دعم محادثة الصالون',
                () => context.push('/chat')),
            _profileOption(context, Icons.notifications_rounded, 'الإشعارات',
                () => context.push('/notifications')),
            _profileOption(context, Icons.settings_rounded, 'الإعدادات',
                () => context.push('/settings')),
            _profileOption(context, Icons.help_outline_rounded,
                'المساعدة والدعم', () => context.push('/help')),
            _profileOption(context, Icons.info_outline_rounded, 'حول التطبيق',
                () => context.push('/about')),
            const SizedBox(height: 16),
            GlassCard(
              onTap: () => context.go('/welcome'),
              borderColor: AppColors.error,
              child: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error),
                  SizedBox(width: 14),
                  Text('تسجيل الخروج',
                      style: TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 4),
    );
  }

  Widget _profileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 14),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }
}
