import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/service_model.dart';
import '../../providers/owner_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/glass_card.dart';

class ServicesManagementScreen extends ConsumerWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(ownerServicesProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.canPop() ? context.pop() : context.go('/owner-dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/owner-dashboard'),
          ),
          title: Text(context.tr('Services Menu Management')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: context.tr('Add Service'),
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
                final service = services[index];
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
                                image: service.imageUrl?.isNotEmpty == true
                                    ? DecorationImage(
                                        image: NetworkImage(service.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: service.imageUrl?.isNotEmpty == true
                                  ? null
                                  : const Icon(
                                      Icons.design_services_rounded,
                                      color: AppColors.primaryLight,
                                    ),
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
                                          service.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (service.isActive
                                                  ? AppColors.success
                                                  : AppColors.error)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          context.tr(
                                            service.isActive
                                                ? 'Available'
                                                : 'Disabled',
                                          ),
                                          style: TextStyle(
                                            color: service.isActive
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
                                    '${service.categoryName} • ${service.durationMinutes} ${context.tr('min')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (service.description?.isNotEmpty == true) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      service.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          height: 1,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      CurrencyFormatter.format(
                                        service.price,
                                        currency: service.currency,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: service.discountPrice != null
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: service.discountPrice != null
                                            ? Theme.of(context).colorScheme.onSurfaceVariant
                                            : AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                  if (service.discountPrice != null) ...[
                                    const SizedBox(width: 8),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        CurrencyFormatter.format(
                                          service.discountPrice!,
                                          currency: service.currency,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: service.isActive,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (_) => ref
                                      .read(ownerServicesProvider.notifier)
                                      .toggleServiceActive(service),
                                ),
                                IconButton(
                                  tooltip: context.tr('Edit'),
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                  onPressed: () => context.push(
                                    '/add-service',
                                    extra: service,
                                  ),
                                ),
                                IconButton(
                                  tooltip: context.tr('Delete'),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, service),
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
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
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
    BuildContext context,
    WidgetRef ref,
    ServiceModel service,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.tr('Delete Service'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          context.tr(
            'Are you sure you want to delete this service? If it has existing bookings, consider disabling it instead.',
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.tr('Cancel'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(ownerServicesProvider.notifier)
                  .deleteService(service.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('Service deleted')),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              context.tr('Delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
