import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/service_model.dart';

class ServicesManagementScreen extends ConsumerWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(ownerServicesProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/owner-dashboard');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: const Text('Services Menu Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Add Service',
              onPressed: () => context.push('/add-service'),
            ),
          ],
        ),
        body: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return OwnerEmptyStateWidget(
                icon: Icons.design_services_rounded,
                title: 'No Services Added',
                description: 'Create your first service so customers can book.',
                actionLabel: 'Add Service',
                onActionTap: () => context.push('/add-service'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                image: (s.imageUrl != null &&
                                        s.imageUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(s.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (s.imageUrl == null || s.imageUrl!.isEmpty)
                                  ? const Icon(Icons.design_services_rounded,
                                      color: AppColors.primaryLight)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimaryDark,
                                          ),
                                        ),
                                      ),
                                      // Active / Disabled status chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: s.isActive
                                              ? AppColors.success
                                                  .withValues(alpha: 0.15)
                                              : AppColors.error
                                                  .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          s.isActive ? 'Available' : 'Disabled',
                                          style: TextStyle(
                                            color: s.isActive
                                                ? AppColors.success
                                                : AppColors.error,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${s.categoryName} • ${s.durationMinutes} min',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMutedDark,
                                    ),
                                  ),
                                  if (s.description != null &&
                                      s.description!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      s.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(
                            color: AppColors.glassBorderDark, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AED ${s.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: s.discountPrice != null
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: s.discountPrice != null
                                        ? AppColors.textMutedDark
                                        : AppColors.primaryLight,
                                  ),
                                ),
                                if (s.discountPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'AED ${s.discountPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Actions: Toggle Active, Edit, Delete
                            Row(
                              children: [
                                Switch(
                                  value: s.isActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) {
                                    ref
                                        .read(ownerServicesProvider.notifier)
                                        .toggleServiceActive(s);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      size: 18, color: AppColors.accent),
                                  onPressed: () => context.push(
                                    '/add-service',
                                    extra: s,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 18, color: AppColors.error),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, s),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => const OwnerEmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Unable to Load Services',
            description: 'Could not fetch business services menu.',
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 3),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Delete Service',
            style: TextStyle(color: AppColors.textPrimaryDark)),
        content: Text(
          'Are you sure you want to delete "${service.name}"? If this service has existing bookings, consider disabling it instead.',
          style: const TextStyle(color: AppColors.textMutedDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(ownerServicesProvider.notifier)
                  .deleteService(service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
