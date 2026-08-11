import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_providers.dart';
import '../../widgets/luxury_badge.dart';
import '../../widgets/rating_stars.dart';
import '../../services/auth_guard.dart';

class SalonDetailScreen extends ConsumerWidget {
  final String salonId;

  const SalonDetailScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salonAsync = ref.watch(businessDetailProvider(salonId));
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(salonId);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        body: salonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading salon: $err')),
          data: (salon) {
            if (salon == null) {
              return const Center(child: Text('Salon not found'));
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black45,
                      child:
                          Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                        ),
                      ),
                      onPressed: () {
                        final currentFavs =
                            Set<String>.from(ref.read(favoritesProvider));
                        if (isFav) {
                          currentFavs.remove(salonId);
                        } else {
                          currentFavs.add(salonId);
                        }
                        ref.read(favoritesProvider.notifier).state =
                            currentFavs;
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: salon.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              salon.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 24),
                            ),
                            if (salon.isVerified)
                              const LuxuryBadge(
                                  text: 'VERIFIED', icon: Icons.verified),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          salon.address,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            RatingStars(rating: salon.rating),
                            const SizedBox(width: 8),
                            Text(
                              '${salon.rating} (${salon.reviewCount} reviews)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Services Menu',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ref.watch(servicesProvider(salon.id)).when(
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (err, _) => Text(
                                  'Error loading services: $err',
                                  style: const TextStyle(color: Colors.red)),
                              data: (services) {
                                if (services.isEmpty) {
                                  return const Text(
                                      'No services listed for this salon.',
                                      style: TextStyle(color: Colors.grey));
                                }
                                return Column(
                                  children: services.map((svc) {
                                    return _buildServiceItem(
                                      context: context,
                                      name: svc.name,
                                      duration: svc.duration,
                                      price: svc.price,
                                      onBook: () async {
                                        final allowed =
                                            await requireLogin(context);
                                        if (allowed && context.mounted) {
                                          ref
                                                  .read(bookingDraftProvider
                                                      .notifier)
                                                  .state =
                                              ref
                                                  .read(bookingDraftProvider)
                                                  .copyWith(
                                                    businessId: salon.id,
                                                    businessName: salon.name,
                                                    serviceId: svc.id,
                                                    serviceName: svc.name,
                                                    servicePrice: svc.price,
                                                    serviceDuration:
                                                        svc.duration,
                                                    serviceDurationMinutes:
                                                        svc.durationMinutes,
                                                  );
                                          context.push('/booking-service');
                                        }
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required String name,
    required String duration,
    required double price,
    required VoidCallback onBook,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(duration,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '\$$price',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}
