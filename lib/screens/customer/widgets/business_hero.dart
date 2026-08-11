import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/business_model.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';

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
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(business.id);

    const fallbackUrl =
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80';
    final imageUrl =
        business.imageUrl.isNotEmpty ? business.imageUrl : fallbackUrl;

    return Stack(
      children: [
        // Cover Image
        AspectRatio(
          aspectRatio: 16 / 10,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.cardDark,
              child: const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient Overlay for Readability
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

        // Top Action Bar Buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
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
                // Right Buttons (Favorite + Share)
                Row(
                  children: [
                    _circleIconButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFavorite ? Colors.redAccent : Colors.white,
                      onTap: () {
                        final set =
                            Set<String>.from(ref.read(favoritesProvider));
                        if (isFavorite) {
                          set.remove(business.id);
                        } else {
                          set.add(business.id);
                        }
                        ref.read(favoritesProvider.notifier).state = set;
                      },
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(
                      icon: Icons.share_rounded,
                      onTap: onShare ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Sharing ${business.name}...')),
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
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
