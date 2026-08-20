import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/glass_card.dart';
import 'edit_customer_profile_screen.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(customerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ProfileErrorState(
          message: 'Unable to load your profile: $error',
          onRetry: () => ref.invalidate(customerProfileProvider),
        ),
        data: (user) {
          if (user == null) {
            return _ProfileErrorState(
              message: 'Please sign in to view your profile.',
              buttonLabel: 'Sign In',
              onRetry: () => context.go('/login'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customerProfileProvider);
              await ref.read(customerProfileProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserCard(context, ref, user),
                  const SizedBox(height: 16),
                  _buildAccountSummary(user),
                  const SizedBox(height: 20),
                  _profileOption(
                    context,
                    Icons.edit_rounded,
                    'Edit Profile',
                    () => _openEditProfile(context, ref),
                  ),
                  _profileOption(
                    context,
                    Icons.calendar_month_rounded,
                    'My Bookings',
                    () => context.push('/my-bookings'),
                  ),
                  _profileOption(
                    context,
                    Icons.favorite_rounded,
                    'Favorite Salons',
                    () => context.push('/favorites'),
                  ),
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
                    onTap: () => _confirmLogout(context, ref),
                    borderColor: AppColors.error,
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error),
                        SizedBox(width: 14),
                        Text(
                          'Logout',
                          style: TextStyle(
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
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 4),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserModel user) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CustomerAvatar(imageUrl: user.avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.trim().isEmpty ? 'Easy Book User' : user.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (user.phone.trim().isNotEmpty)
                  Text(
                    user.phone,
                    style: const TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 13,
                    ),
                  ),
                if (user.email.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _openEditProfile(context, ref),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummary(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  user.favoriteBusinessIds.length.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  user.walletBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMutedDark,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const EditCustomerProfileScreen()),
    );
    if (context.mounted) {
      ref.invalidate(customerProfileProvider);
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You can continue browsing as a guest after logout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authProvider.notifier).logout();
      ref.invalidate(customerProfileProvider);
      if (context.mounted) context.go('/home');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.trim().isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.glassBgDark,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 38,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({
    required this.message,
    required this.onRetry,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 44,
              color: AppColors.textMutedDark,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
