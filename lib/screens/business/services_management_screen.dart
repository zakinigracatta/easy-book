import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/service_model.dart';
import '../../l10n/l10n.dart';

class ServicesManagementScreen extends ConsumerWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(l10n.servicesMenuManagement),
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded),
              tooltip: l10n.addService,
              onPressed: () => context.push('/add-service'),
            ),
          ],
        ),
        body: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return OwnerEmptyStateWidget(
                icon: Icons.design_services_rounded,
                title: l10n.noServicesAdded,
                description: l10n.addFirstServiceHelp,
                actionLabel: l10n.addService,
                onActionTap: () => context.push('/add-service'),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: EdgeInsets.all(16),
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
                                  ? Icon(Icons.design_services_rounded,
                                      color: AppColors.primaryLight)
                                  : null,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
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
                                          s.isActive
                                              ? l10n.available
                                              : l10n.disabled,
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
                                  SizedBox(height: 4),
                                  Text(
                                    '${_localizedServiceCategory(context, s.categoryName)} • ${l10n.minutesCount(s.durationMinutes)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  if (s.description != null &&
                                      s.description!.isNotEmpty) ...[
                                    SizedBox(height: 6),
                                    Text(
                                      s.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(
                            color: Theme.of(context).colorScheme.outline,
                            height: 1),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
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
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                          : AppColors.primaryLight,
                                    ),
                                  ),
                                  if (s.discountPrice != null) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      'AED ${s.discountPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.82,
                                  child: Switch(
                                    value: s.isActive,
                                    onChanged: (_) {
                                      ref
                                          .read(ownerServicesProvider.notifier)
                                          .toggleServiceActive(s);
                                    },
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      context.push('/add-service', extra: s);
                                    } else {
                                      _confirmDelete(context, ref, s);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(l10n.editService),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(l10n.deleteService),
                                    ),
                                  ],
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
          loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => OwnerEmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: l10n.servicesFetchFailed,
            description: l10n.servicesFetchFailed,
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 3),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10nOf(context).deleteServiceQuestion,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          l10nOf(context).deleteServiceConfirmation(service.name),
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10nOf(context).cancel,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(ownerServicesProvider.notifier)
                  .deleteService(service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10nOf(context).serviceDeleted),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(l10nOf(context).delete,
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

String _localizedServiceCategory(BuildContext context, String value) {
  final l10n = l10nOf(context);
  return switch (value) {
    'Hair Services' => l10n.hairServices,
    'Hair Salon' => l10n.hairSalon,
    'Nails' => l10n.nails,
    'Massage' => l10n.massage,
    'Spa' => l10n.spa,
    'Beauty' => l10n.beauty,
    _ => value,
  };
}
