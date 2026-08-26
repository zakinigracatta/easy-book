import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/app_localizations.dart';

class EmployeeManagementScreen extends ConsumerWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(ownerEmployeesProvider);

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
          title: Text(context.tr('Team & Employees')),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              tooltip: 'Add Employee',
              onPressed: () => context.push('/add-employee'),
            ),
          ],
        ),
        body: employeesAsync.when(
          data: (staffList) {
            if (staffList.isEmpty) {
              return OwnerEmptyStateWidget(
                icon: Icons.people_rounded,
                title: 'No Team Members',
                description:
                    'Add your first team member to start accepting staff-based bookings.',
                actionLabel: 'Add Employee',
                onActionTap: () => context.push('/add-employee'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final st = staffList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundImage: (st.avatarUrl.isNotEmpty)
                              ? NetworkImage(st.avatarUrl)
                              : null,
                          child: st.avatarUrl.isEmpty
                              ? const Icon(Icons.person_rounded,
                                  color: AppColors.primaryLight, size: 24)
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
                                      st.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: st.isActive
                                          ? AppColors.success
                                              .withValues(alpha: 0.15)
                                          : AppColors.warning
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      st.isActive ? 'Available' : 'Off',
                                      style: TextStyle(
                                        color: st.isActive
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                st.roleTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: AppColors.gold),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${st.rating} (${st.reviewCount} reviews)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${st.experienceYears} yrs exp',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded,
                              color: AppColors.primaryLight, size: 20),
                          tooltip: 'Working Hours & Schedule',
                          onPressed: () => context.push('/employee-schedule'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              color: AppColors.accent, size: 20),
                          onPressed: () =>
                              context.push('/add-employee', extra: st),
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
            title: 'Unable to Load Employees',
            description: 'Could not retrieve team members.',
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }
}
