import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import 'customer_profile_modal.dart';
import '../../l10n/app_localizations.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(ownerCustomersProvider);

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
          title: Text(context.tr('Customer Database & CRM')),
        ),
        body: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search clients by name or phone...',
                  hintStyle: TextStyle(
                      fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
            ),

            // Customers List
            Expanded(
              child: customersAsync.when(
                data: (customers) {
                  final filtered = customers.where((c) {
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        c.phone.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const OwnerEmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: 'No Customers Found',
                      description:
                          'No customer records match your current search query.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) =>
                                  CustomerProfileModal(customer: c),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                c.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                            title: Text(
                              c.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                            subtitle: Text(
                              context.tr('{phone} • {count} visits', params: {'phone': c.phone, 'count': c.completedVisits}),
                              style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'AED ${c.totalSpent.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                    fontSize: 14,
                                  ),
                                ),
                                if (c.noShowCount > 0) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    context.tr('{count} No-Shows', params: {'count': c.noShowCount}),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
                  title: 'Unable to Load Customers',
                  description: 'Failed to retrieve customer CRM database.',
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }
}
