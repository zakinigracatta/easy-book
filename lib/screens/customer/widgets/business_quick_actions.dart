import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/business_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/favorites_provider.dart';
import '../../../theme/app_colors.dart';

class BusinessQuickActions extends ConsumerWidget {
  final BusinessModel business;
  final VoidCallback? onDirectionsTap;
  final VoidCallback? onShareTap;

  const BusinessQuickActions({
    super.key,
    required this.business,
    this.onDirectionsTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final savedFavorites = ref.watch(savedFavoritesProvider);
    final isFavorite =
        savedFavorites.asData?.value.contains(business.id) ?? false;

    final hasPhone =
        business.phone != null && business.phone!.trim().isNotEmpty;
    final hasLocation = business.address.isNotEmpty ||
        (business.latitude != 0 && business.longitude != 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (hasPhone)
          _actionBtn(
            context,
            icon: Icons.phone_outlined,
            label: context.tr('Phone'),
            onTap: () async {
              final phone = business.phone!.trim();
              await Clipboard.setData(ClipboardData(text: phone));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('Phone number copied')),
                ),
              );
            },
          ),
        if (hasLocation)
          _actionBtn(
            context,
            icon: Icons.directions_outlined,
            label: context.tr('Directions'),
            onTap: onDirectionsTap ??
                () => context.push('/location', extra: business.id),
          ),
        _actionBtn(
          context,
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isFavorite ? Colors.redAccent : null,
          label: context.tr(isFavorite ? 'Saved' : 'Favorite'),
          onTap: () async {
            if (user == null || user.id.trim().isEmpty) {
              context.push('/login');
              return;
            }

            try {
              await ref.read(favoritesRepositoryProvider).setFavorite(
                    userId: user.id,
                    businessId: business.id,
                    isFavorite: !isFavorite,
                  );
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr('Could not update favorites. Please try again.'),
                  ),
                ),
              );
            }
          },
        ),
        _actionBtn(
          context,
          icon: Icons.share_outlined,
          label: context.tr('Share'),
          onTap: onShareTap ??
              () async {
                final details = [
                  business.name,
                  if (business.address.trim().isNotEmpty)
                    business.address.trim(),
                  if (business.phone?.trim().isNotEmpty == true)
                    business.phone!.trim(),
                ].join('\n');
                await Clipboard.setData(ClipboardData(text: details));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('Business details copied')),
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final activeColor = iconColor ?? AppColors.primaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: activeColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
