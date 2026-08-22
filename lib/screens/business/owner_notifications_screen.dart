import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/business_bottom_nav.dart';
import '../../widgets/business/owner_empty_state.dart';
import '../../providers/owner_providers.dart';
import '../../models/owner_notification_model.dart';

class OwnerNotificationsScreen extends ConsumerWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(ownerNotificationsProvider);

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
          title: const Text('Owner Notifications'),
        ),
        body: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const OwnerEmptyStateWidget(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications',
                description:
                    'You have no new alerts or business notifications.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final iconData = _getNotificationIcon(n.type);
                final iconColor = _getNotificationColor(n.type);
                final timeAgo = DateFormat('hh:mm a').format(n.createdAt);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    onTap: () async {
                      final bizId =
                          ref.read(currentBusinessIdProvider).value ?? '';
                      await ref
                          .read(ownerRepositoryProvider)
                          .markNotificationRead(bizId, n.id);
                      ref.invalidate(ownerNotificationsProvider);

                      if (context.mounted && n.relatedBookingId != null) {
                        context.push('/owner-bookings');
                      }
                    },
                    backgroundColor: n.isRead
                        ? null
                        : AppColors.primary.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.2),
                        child: Icon(iconData, color: iconColor, size: 20),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: n.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                          ),
                          if (!n.isRead) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMutedDark,
                            ),
                          ),
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
            title: 'Unable to Load Notifications',
            description: 'Could not fetch notification inbox.',
          ),
        ),
        bottomNavigationBar: const BusinessBottomNav(currentIndex: 4),
      ),
    );
  }

  IconData _getNotificationIcon(OwnerNotificationType type) {
    switch (type) {
      case OwnerNotificationType.newBooking:
        return Icons.calendar_month_rounded;
      case OwnerNotificationType.bookingCancelled:
        return Icons.event_busy_rounded;
      case OwnerNotificationType.bookingRescheduled:
        return Icons.event_repeat_rounded;
      case OwnerNotificationType.newReview:
        return Icons.star_rounded;
      case OwnerNotificationType.customerArrived:
        return Icons.hail_rounded;
      case OwnerNotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color _getNotificationColor(OwnerNotificationType type) {
    switch (type) {
      case OwnerNotificationType.newBooking:
        return AppColors.primaryLight;
      case OwnerNotificationType.bookingCancelled:
        return AppColors.error;
      case OwnerNotificationType.bookingRescheduled:
        return AppColors.warning;
      case OwnerNotificationType.newReview:
        return AppColors.gold;
      case OwnerNotificationType.customerArrived:
        return AppColors.accent;
      case OwnerNotificationType.system:
        return AppColors.info;
    }
  }
}
