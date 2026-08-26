import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  Color _mutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final displayName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : context.tr('Customer');
    final phone = user?.phone.trim() ?? '';
    final email = user?.email.trim() ?? '';
    final secondaryText = phone.isNotEmpty ? phone : email;
    final avatarUrl = user?.avatarUrl?.trim() ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E';
    final mutedColor = _mutedColor(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Customer Profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.18),
                    backgroundImage:
                        avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (secondaryText.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              secondaryText,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        if (phone.isNotEmpty && email.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              email,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _profileOption(
              context,
              Icons.chat_rounded,
              'Salon Chat Support',
              () => context.push('/chat'),
            ),
            _profileOption(
              context,
              Icons.notifications_rounded,
              'Notifications',
              () => context.push('/notifications'),
            ),
            _profileOption(
              context,
              Icons.settings_rounded,
              'Settings',
              () => context.push('/settings'),
            ),
            _profileOption(
              context,
              Icons.help_outline_rounded,
              'Help & Support',
              () => context.push('/help'),
            ),
            _profileOption(
              context,
              Icons.info_outline_rounded,
              'About App',
              () => context.push('/about'),
            ),
            const SizedBox(height: 16),
            GlassCard(
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/welcome');
              },
              borderColor: AppColors.error,
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error),
                  const SizedBox(width: 14),
                  Text(
                    context.tr('Logout'),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
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
                Text(
                  context.tr(title),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _mutedColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
