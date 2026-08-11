import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_model.dart';
import '../../../providers/app_providers.dart';
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
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(business.id);

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
            label: 'Call',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Calling ${business.name}: ${business.phone}')),
              );
            },
          ),
        if (hasLocation)
          _actionBtn(
            context,
            icon: Icons.directions_outlined,
            label: 'Directions',
            onTap: onDirectionsTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Opening map for ${business.name}...')),
                  );
                },
          ),
        _actionBtn(
          context,
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: isFavorite ? Colors.redAccent : null,
          label: isFavorite ? 'Saved' : 'Favorite',
          onTap: () {
            final set = Set<String>.from(ref.read(favoritesProvider));
            if (isFavorite) {
              set.remove(business.id);
            } else {
              set.add(business.id);
            }
            ref.read(favoritesProvider.notifier).state = set;
          },
        ),
        _actionBtn(
          context,
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: onShareTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sharing ${business.name}...')),
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
