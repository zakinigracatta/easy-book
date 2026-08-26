import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/business_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../services/auth_guard.dart';
import '../../../l10n/app_localizations.dart';

class BusinessHero extends ConsumerWidget {
  final BusinessModel business;
  final VoidCallback? onShare;

  const BusinessHero({
    super.key,
    required this.business,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(savedFavoritesProvider);
    final favorites = favoritesAsync.asData?.value ?? <String>{};
    final isFavorite = favorites.contains(business.id);
    final imageUrl = business.imageUrl.trim();

    final logicalWidth = MediaQuery.sizeOf(context).width;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final heroCacheWidth = (logicalWidth * devicePixelRatio)
        .round()
        .clamp(1, 1440)
        .toInt();

    return Stack(
      children: [
        RepaintBoundary(
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: imageUrl.isEmpty
                ? _coverPlaceholder(context)
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: heroCacheWidth,
                    maxWidthDiskCache: heroCacheWidth,
                    fadeInDuration: const Duration(milliseconds: 120),
                    fadeOutDuration: Duration.zero,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    errorWidget: (context, url, error) => _coverPlaceholder(context),
                  ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                Row(
                  children: [
                    _circleIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFavorite ? Colors.redAccent : Colors.white,
                      onTap: () async {
                        final allowed = await requireLogin(
                          context,
                          targetRoute: '/salon/${business.id}',
                        );
                        if (!allowed || !context.mounted) return;

                        final user = ref.read(authProvider);
                        if (user == null || user.id.trim().isEmpty) return;

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
                              content: Text(context.tr('Could not update favorites. Please try again.'),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(
                      icon: Icons.share_rounded,
                      onTap: onShare ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sharing ${business.name}...'),
                              ),
                            );
                          },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 64,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
