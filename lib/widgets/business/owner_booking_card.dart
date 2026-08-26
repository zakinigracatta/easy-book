import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../glass_card.dart';
import 'booking_status_chip.dart';
import '../../l10n/app_localizations.dart';

class OwnerBookingCard extends StatelessWidget {
  final BookingModel booking;
  final Function(BookingStatus newStatus)? onStatusChanged;
  final VoidCallback? onRescheduleTap;

  const OwnerBookingCard({
    super.key,
    required this.booking,
    this.onStatusChanged,
    this.onRescheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(booking.startDateTime);
    final dateStr = DateFormat('EEE, MMM d').format(booking.startDateTime);
    final isWalkIn = booking.bookingSource == 'walkIn';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Time, Date & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    '$timeStr • $dateStr',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isWalkIn) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Text(context.tr('Walk-in'),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  BookingStatusChip(status: booking.status, isCompact: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 12),

          // Main Info: Customer, Service, Employee & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  booking.customerName.isNotEmpty
                      ? booking.customerName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (booking.customerPhone != null &&
                        booking.customerPhone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        booking.customerPhone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined,
                            size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('Staff: {name}', params: {'name': booking.staffName}),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'AED ${booking.servicePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded,
                      size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Contextual Action Buttons depending on status
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.pending:
        return Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Confirm',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.primary,
                onPressed: () => onStatusChanged?.call(BookingStatus.confirmed),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                label: 'Cancel',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                onPressed: () => _confirmAction(
                  context,
                  title: 'Cancel Booking',
                  message: 'Are you sure you want to cancel this booking?',
                  onConfirm: () =>
                      onStatusChanged?.call(BookingStatus.cancelled),
                ),
              ),
            ),
          ],
        );

      case BookingStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Mark Arrived',
                icon: Icons.hail_rounded,
                color: AppColors.accent,
                onPressed: () => onStatusChanged?.call(BookingStatus.arrived),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                label: 'Start Service',
                icon: Icons.play_circle_outline_rounded,
                color: AppColors.info,
                onPressed: () =>
                    onStatusChanged?.call(BookingStatus.inProgress),
              ),
            ),
            const SizedBox(width: 8),
            _iconActionButton(
              context,
              icon: Icons.more_vert_rounded,
              onPressed: () => _showMoreActionsMenu(context),
            ),
          ],
        );

      case BookingStatus.arrived:
        return Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Start Service',
                icon: Icons.play_circle_fill_rounded,
                color: AppColors.accent,
                onPressed: () =>
                    onStatusChanged?.call(BookingStatus.inProgress),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                label: 'Complete',
                icon: Icons.task_alt_rounded,
                color: AppColors.success,
                onPressed: () => onStatusChanged?.call(BookingStatus.completed),
              ),
            ),
          ],
        );

      case BookingStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: _actionButton(
                label: 'Mark Complete',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                onPressed: () => onStatusChanged?.call(BookingStatus.completed),
              ),
            ),
          ],
        );

      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return const SizedBox.shrink();
    }
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _iconActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      icon: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
      onPressed: onPressed,
    );
  }

  void _showMoreActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_repeat_rounded,
                  color: AppColors.primary),
              title: Text(context.tr('Reschedule Booking'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                onRescheduleTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off_rounded,
                  color: AppColors.warning),
              title: Text(context.tr('Mark No Show'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmAction(
                  context,
                  title: 'Mark as No Show',
                  message: 'Mark customer as No Show for this appointment?',
                  onConfirm: () => onStatusChanged?.call(BookingStatus.noShow),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: Text(context.tr('Cancel Booking'),
                  style: const TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmAction(
                  context,
                  title: 'Cancel Booking',
                  message: 'Are you sure you want to cancel this booking?',
                  onConfirm: () =>
                      onStatusChanged?.call(BookingStatus.cancelled),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(title,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('Back'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(context.tr('Confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
