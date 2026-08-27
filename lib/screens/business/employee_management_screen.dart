import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../l10n/l10n.dart';

class EmployeeManagementScreen extends ConsumerWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nOf(context);
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
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-dashboard');
              }
            },
          ),
          title: Text(l10n.teamAndEmployees),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add_alt_1_rounded),
              tooltip: l10n.addEmployee,
              onPressed: () => context.push('/add-employee'),
            ),
          ],
        ),
        body: employeesAsync.when(
          data: (staffList) {
            if (staffList.isEmpty) {
              return OwnerEmptyStateWidget(
                icon: Icons.people_rounded,
                title: l10n.noEmployees,
                description: l10n.addFirstEmployeeHelp,
                actionLabel: l10n.addEmployee,
                onActionTap: () => context.push('/add-employee'),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final st = staffList[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: EdgeInsets.all(16),
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
                              ? Icon(Icons.person_rounded,
                                  color: AppColors.primaryLight, size: 24)
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
                                      st.name,
                                      style: TextStyle(
                                        fontSize: 16,
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
                                      color: st.isActive
                                          ? AppColors.success
                                              .withValues(alpha: 0.15)
                                          : AppColors.warning
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      st.isActive
                                          ? l10n.available
                                          : l10n.unavailable,
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
                              SizedBox(height: 2),
                              Text(
                                st.roleTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      size: 14, color: AppColors.gold),
                                  SizedBox(width: 4),
                                  Text(
                                    '${st.rating} (${l10n.reviewsCount(st.reviewCount)})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    l10n.yearsExperience(st.experienceYears),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (value) {
                            if (value == 'schedule') {
                              context.push('/employee-schedule');
                            } else {
                              context.push('/add-employee', extra: st);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: const Icon(Icons.edit_rounded),
                                title: Text(l10n.editEmployee),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'schedule',
                              child: ListTile(
                                leading:
                                    const Icon(Icons.calendar_month_rounded),
                                title: Text(l10n.workingHoursAndSchedule),
                                contentPadding: EdgeInsets.zero,
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
          },
          loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => OwnerEmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: l10n.employeesFetchFailed,
            description: l10n.employeesFetchFailed,
          ),
        ),
        bottomNavigationBar: BusinessBottomNav(currentIndex: 4),
      ),
    );
  }
}
