import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/business_model.dart';
import '../../../providers/app_providers.dart';
import '../../../services/google_maps_service.dart';
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
    final hasLocation = business.address.trim().isNotEmpty ||
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
                  content: Text('Calling ${business.name}: ${business.phone}'),
                ),
              );
            },
          ),
        if (hasLocation)
          _actionBtn(
            context,
            icon: Icons.directions_rounded,
            label: 'Directions',
            onTap: onDirectionsTap ?? () => _showDirectionsSheet(context),
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

  Future<void> _showDirectionsSheet(BuildContext context) async {
    final selectedMode = await showModalBottomSheet<MapsTravelMode>(
      context: context,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (sheetContext) {
        final locationText = business.address.trim().isNotEmpty
            ? business.address.trim()
            : '${business.latitude}, ${business.longitude}';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Open in Google Maps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  business.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  locationText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _travelModeButton(
                        sheetContext,
                        icon: Icons.directions_car_filled_rounded,
                        label: 'Driving',
                        mode: MapsTravelMode.driving,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _travelModeButton(
                        sheetContext,
                        icon: Icons.directions_walk_rounded,
                        label: 'Walking',
                        mode: MapsTravelMode.walking,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMode == null || !context.mounted) return;

    try {
      await const GoogleMapsService().openDirections(
        business,
        travelMode: selectedMode,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Google Maps: $error'),
        ),
      );
    }
  }

  Widget _travelModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required MapsTravelMode mode,
  }) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(mode),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 26),
              const SizedBox(height: 7),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
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
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
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
